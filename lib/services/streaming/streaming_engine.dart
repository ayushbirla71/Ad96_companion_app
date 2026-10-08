import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';

import 'android_streaming_engine.dart';
import 'ios_streaming_engine.dart';

enum StreamEventType {
  /// Connecting to the RTMP ingest.
  connecting,

  /// Publishing to the RTMP ingest.
  live,

  /// Connection dropped, the engine is retrying.
  reconnecting,

  /// Could not connect / publish, or the connection was lost for good.
  failed,

  /// Stream ended (by us or by the system).
  stopped,

  /// The camera was taken away (interruption, background, other app).
  cameraLost,
}

class StreamEvent {
  final StreamEventType type;
  final String? reason;

  const StreamEvent(this.type, [this.reason]);

  @override
  String toString() => 'StreamEvent($type, $reason)';
}

class StreamingException implements Exception {
  final String code;
  final String? message;

  const StreamingException(this.code, [this.message]);

  @override
  String toString() => 'StreamingException($code, $message)';
}

/// One interface for camera preview + RTMP publishing on both platforms.
/// Android is backed by the `rtmp_streaming` plugin, iOS by the native
/// HaishinKit code reached over the `streaming_channel` MethodChannel.
abstract class StreamingEngine {
  factory StreamingEngine.create() =>
      Platform.isIOS ? IosStreamingEngine() : AndroidStreamingEngine();

  /// Engine-level events (connection state). Broadcast stream.
  Stream<StreamEvent> get events;

  /// True once the camera preview is ready.
  ValueNotifier<bool> get isReady;

  bool get isFrontCamera;
  bool get isLandscape;

  /// Camera + microphone permissions must already be granted.
  Future<void> init({bool front = false, bool landscape = false});

  Future<void> switchCamera();

  Future<void> setOrientation({required bool landscape});

  /// Completes only when the RTMP publish is confirmed. Throws
  /// [StreamingException] on failure.
  Future<void> startStream(String rtmpUrl);

  /// Idempotent. Never throws.
  Future<void> stopStream();

  /// Stops the stream (if any) and releases camera/mic. Idempotent. Never throws.
  Future<void> dispose();

  Widget buildPreview();
}
