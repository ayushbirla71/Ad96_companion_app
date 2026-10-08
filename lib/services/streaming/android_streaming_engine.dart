import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rtmp_streaming/camera.dart';

import 'streaming_engine.dart';

/// Android implementation, backed by the `rtmp_streaming` plugin.
class AndroidStreamingEngine implements StreamingEngine {
  /// The plugin does not report "connected", only failures. If no failure
  /// event arrives in this window after start, the publish is treated as live.
  static const Duration _connectGrace = Duration(seconds: 3);
  static const int _maxInitAttempts = 2;

  final StreamController<StreamEvent> _events = StreamController.broadcast();
  final ValueNotifier<bool> _ready = ValueNotifier(false);

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  CameraDescription? _current;

  bool _front = false;
  bool _landscape = false;
  bool _disposed = false;
  bool _streaming = false;
  bool _stopping = false;
  Map<dynamic, dynamic>? _lastHandledEvent;
  Completer<void>? _startCompleter;

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

    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      throw StreamingException('camera_unavailable', e.description);
    }
    if (_cameras.isEmpty) {
      throw const StreamingException('camera_unavailable', 'No camera found');
    }
    _current = _pickCamera();
    await _setupController();
  }

  CameraDescription _pickCamera() {
    final wanted = _front ? CameraLensDirection.front : CameraLensDirection.back;
    return _cameras.firstWhere(
      (c) => c.lensDirection == wanted,
      orElse: () => _cameras.first,
    );
  }

  Future<void> _setupController() async {
    _ready.value = false;
    await _releaseController();
    if (_disposed) return;

    Object? lastError;
    for (var attempt = 1; attempt <= _maxInitAttempts; attempt++) {
      final controller = CameraController(
        ResolutionPreset.medium,
        enableAudio: true,
        androidUseOpenGL: true,
      );
      try {
        await controller.initialize(_current!);
        if (_disposed) {
          await _safeDispose(controller);
          return;
        }
        controller.addListener(_onControllerValue);
        _controller = controller;
        _ready.value = true;
        return;
      } on CameraException catch (e) {
        lastError = e;
        await _safeDispose(controller);
        if (e.code == 'cameraPermission') {
          throw StreamingException('permission_denied', e.description);
        }
        debugPrint('Camera init attempt $attempt failed: ${e.code}');
      } catch (e) {
        lastError = e;
        await _safeDispose(controller);
        debugPrint('Camera init attempt $attempt failed: $e');
      }
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    throw StreamingException('camera_init_failed', '$lastError');
  }

  Future<void> _releaseController() async {
    final old = _controller;
    _controller = null;
    if (old != null) {
      old.removeListener(_onControllerValue);
      await _safeDispose(old);
    }
  }

  Future<void> _safeDispose(CameraController c) async {
    try {
      await c.dispose();
    } catch (e) {
      debugPrint('Camera dispose error: $e');
    }
  }

  @override
  Future<void> switchCamera() async {
    if (_streaming || _cameras.isEmpty) return;
    _front = !_front;
    _current = _pickCamera();
    await Future.delayed(const Duration(milliseconds: 400));
    await _setupController();
  }

  @override
  Future<void> setOrientation({required bool landscape}) async {
    if (_streaming) return;
    _landscape = landscape;
    // Gives the OS time to allocate the flipped buffer before re-creating.
    await Future.delayed(const Duration(milliseconds: 600));
    await _setupController();
  }

  void _onControllerValue() {
    final event = _controller?.value.event;
    if (event == null || identical(event, _lastHandledEvent)) return;
    _lastHandledEvent = event;
    if (_stopping || _disposed) return;

    final type = event['eventType'] as String?;
    final reason = event['errorDescription'] as String?;

    switch (type) {
      case 'rtmp_retry':
        if (_startCompleter != null && !_startCompleter!.isCompleted) {
          _startCompleter!.completeError(
            StreamingException('connect_failed', reason),
          );
        } else if (_streaming) {
          _emit(StreamEvent(StreamEventType.reconnecting, reason));
        }
        break;
      case 'rtmp_stopped':
      case 'error':
        if (_startCompleter != null && !_startCompleter!.isCompleted) {
          _startCompleter!.completeError(
            StreamingException('connect_failed', reason),
          );
        } else if (_streaming) {
          _streaming = false;
          _emit(StreamEvent(StreamEventType.failed, reason ?? type));
        }
        break;
      case 'camera_closing':
        if (_streaming) {
          _streaming = false;
          _emit(StreamEvent(StreamEventType.cameraLost, reason));
        }
        break;
      default:
        break;
    }
  }

  @override
  Future<void> startStream(String rtmpUrl) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized!) {
      throw const StreamingException('not_ready', 'Camera not initialized');
    }
    if (_streaming) return;

    _stopping = false;
    _emit(const StreamEvent(StreamEventType.connecting));
    final completer = Completer<void>();
    // The error may land before we start awaiting; we still await it below.
    completer.future.ignore();
    _startCompleter = completer;
    final grace = Timer(_connectGrace, () {
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await controller.startVideoStreaming(rtmpUrl);
      _streaming = true;
      await completer.future;
      _emit(const StreamEvent(StreamEventType.live));
    } on CameraException catch (e) {
      _streaming = false;
      throw StreamingException(e.code, e.description);
    } catch (e) {
      _streaming = false;
      await _stopQuietly();
      if (e is StreamingException) rethrow;
      throw StreamingException('start_failed', '$e');
    } finally {
      grace.cancel();
      _startCompleter = null;
    }
  }

  Future<void> _stopQuietly() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      if (controller.value.isStreamingVideoRtmp ?? false) {
        await controller.stopVideoStreaming();
      }
    } catch (e) {
      debugPrint('Stop stream error: $e');
    }
  }

  @override
  Future<void> stopStream() async {
    _stopping = true;
    final wasStreaming = _streaming;
    _streaming = false;
    await _stopQuietly();
    if (wasStreaming) _emit(const StreamEvent(StreamEventType.stopped));
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    await stopStream();
    _disposed = true;
    _ready.value = false;
    await _releaseController();
    await _events.close();
  }

  void _emit(StreamEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  @override
  Widget buildPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized!) {
      return const SizedBox.shrink();
    }
    return Center(
      key: ValueKey('preview_${_current?.name}_$_landscape'),
      child: CameraPreview(controller),
    );
  }
}
