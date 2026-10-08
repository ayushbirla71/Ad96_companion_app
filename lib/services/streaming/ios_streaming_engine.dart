import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'streaming_engine.dart';

/// iOS implementation, backed by the native HaishinKit code in
/// `ios/Runner/StreamManager.swift`.
///
/// MethodChannel `streaming_channel`:
///   startPreview {isFront, isLandscape}  -> completes after permission + preview running
///   switchCamera {isFront}
///   setOrientation {isLandscape}
///   startStream {url, key}               -> completes after RTMP connect + publish
///   stopStream                           -> completes after everything is released
/// EventChannel `streaming_events`: {event: connecting|live|failed|stopped|interrupted, reason}
class IosStreamingEngine implements StreamingEngine {
  static const MethodChannel _method = MethodChannel('streaming_channel');
  static const EventChannel _eventChannel = EventChannel('streaming_events');

  final StreamController<StreamEvent> _events = StreamController.broadcast();
  final ValueNotifier<bool> _ready = ValueNotifier(false);
  StreamSubscription<dynamic>? _nativeSub;

  bool _front = false;
  bool _landscape = false;
  bool _disposed = false;
  bool _streaming = false;
  bool _stopping = false;

  @override
  Stream<StreamEvent> get events => _events.stream;

  @override
  ValueNotifier<bool> get isReady => _ready;

  @override
  bool get isFrontCamera => _front;

  @override
  bool get isLandscape => _landscape;

  @override
  Future<void> init({bool front = false, bool landscape = false}) async {
    _front = front;
    _landscape = landscape;

    _nativeSub = _eventChannel.receiveBroadcastStream().listen(
      _onNativeEvent,
      onError: (Object e) => debugPrint('Streaming event error: $e'),
    );

    try {
      await _method.invokeMethod('startPreview', {
        'isFront': _front,
        'isLandscape': _landscape,
      });
      if (!_disposed) _ready.value = true;
    } on PlatformException catch (e) {
      throw _map(e);
    }
  }

  void _onNativeEvent(dynamic raw) {
    if (_disposed || _stopping || raw is! Map) return;
    final reason = raw['reason'] as String?;
    switch (raw['event']) {
      case 'connecting':
        _emit(StreamEvent(StreamEventType.connecting, reason));
        break;
      case 'live':
        _emit(StreamEvent(StreamEventType.live, reason));
        break;
      case 'failed':
        // Start failures are reported through startStream's exception; only
        // forward drops of an already-live stream.
        if (_streaming) {
          _streaming = false;
          _emit(StreamEvent(StreamEventType.failed, reason));
        }
        break;
      case 'stopped':
        if (_streaming) {
          _streaming = false;
          _emit(StreamEvent(StreamEventType.stopped, reason));
        }
        break;
      case 'interrupted':
        if (_streaming || _ready.value) {
          _streaming = false;
          _emit(StreamEvent(StreamEventType.cameraLost, reason));
        }
        break;
    }
  }

  @override
  Future<void> switchCamera() async {
    if (_streaming) return;
    final next = !_front;
    try {
      await _method.invokeMethod('switchCamera', {'isFront': next});
      _front = next;
    } on PlatformException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> setOrientation({required bool landscape}) async {
    if (_streaming) return;
    try {
      await _method.invokeMethod('setOrientation', {'isLandscape': landscape});
      _landscape = landscape;
    } on PlatformException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> startStream(String rtmpUrl) async {
    if (_streaming) return;
    _stopping = false;

    final uri = Uri.tryParse(rtmpUrl);
    if (uri == null || uri.pathSegments.isEmpty) {
      throw const StreamingException('invalid_url', 'Invalid RTMP URL');
    }
    final segments = uri.pathSegments;
    final streamKey = segments.last;
    final basePath = segments.sublist(0, segments.length - 1).join('/');
    final port = uri.hasPort ? ':${uri.port}' : '';
    final baseUrl = '${uri.scheme}://${uri.host}$port/$basePath';

    _emit(const StreamEvent(StreamEventType.connecting));
    try {
      await _method.invokeMethod('startStream', {
        'url': baseUrl,
        'key': streamKey,
      });
      _streaming = true;
      _emit(const StreamEvent(StreamEventType.live));
    } on PlatformException catch (e) {
      _streaming = false;
      throw _map(e);
    }
  }

  @override
  Future<void> stopStream() async {
    _stopping = true;
    final wasStreaming = _streaming;
    _streaming = false;
    try {
      // A dead network can make the native close hang; never block teardown.
      await _method
          .invokeMethod('stopStream')
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('Stop stream error: $e');
    }
    _ready.value = false;
    if (wasStreaming) _emit(const StreamEvent(StreamEventType.stopped));
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    await stopStream();
    _disposed = true;
    await _nativeSub?.cancel();
    _nativeSub = null;
    await _events.close();
  }

  StreamingException _map(PlatformException e) =>
      StreamingException(e.code, e.message);

  void _emit(StreamEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  @override
  Widget buildPreview() => const UiKitView(viewType: 'camera_preview');
}
