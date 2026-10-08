import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:cms_app/pages/home/home_page.dart';
import 'package:cms_app/providers/channel_provider.dart';
import 'package:cms_app/providers/live_content_provider.dart';
import 'package:cms_app/services/streaming/streaming_engine.dart';
import 'package:cms_app/services/streaming/streaming_permission_service.dart';
import 'package:cms_app/services/streaming/streaming_recovery_service.dart';
import 'package:cms_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Camera live-streaming page, shared by Android and iOS.
///
/// Platform differences live behind [StreamingEngine]. Every way of leaving
/// the page (STOP, close, back, app backgrounded, widget disposed, stream
/// dropped) funnels into one idempotent [_shutdown], which stops the stream,
/// releases the camera, stops the channel and removes the live schedule.
class GoLivePage extends StatefulWidget {
  final String rtmpUrl;
  final String channelName;
  final String channelId;
  final String contentId;
  final String contentType;

  const GoLivePage({
    super.key,
    required this.rtmpUrl,
    required this.channelName,
    required this.channelId,
    required this.contentId,
    required this.contentType,
  });

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> with WidgetsBindingObserver {
  static const Duration _heartbeatInterval = Duration(seconds: 15);

  late final ChannelProvider _channels;
  late final LiveContentProvider _liveContent;

  StreamingEngine? _engine;
  StreamSubscription<StreamEvent>? _engineSub;
  Timer? _heartbeat;

  /// null while permissions are still being checked.
  StreamingPermissionStatus? _permission;
  String? _initError;

  bool isLoading = true;
  bool isStreaming = false;
  bool isPreparing = false;
  bool isStopping = false;
  bool isSwitching = false;
  bool userSelectedLandscape = false;
  int countdown = 3;
  String streamStatus = "Ready to stream";

  int _countdownToken = 0;
  Future<void>? _shutdownFuture;
  bool _disposing = false;
  bool _exiting = false;
  bool _exitedInBackground = false;

  /// While a system permission dialog / the Settings app is up, the app is
  /// not "exited" even though lifecycle callbacks fire.
  bool _requestingPermission = false;
  bool _openingSettings = false;

  bool _shuttingDown = false;
  bool get _isShuttingDown => _shuttingDown;
  bool get _engineReady => _engine?.isReady.value ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _channels = context.read<ChannelProvider>();
    _liveContent = context.read<LiveContentProvider>();

    StreamingRecoveryService.sessionActive = true;
    StreamingRecoveryService.markPending(
      channelId: widget.channelId,
      contentId: widget.contentId,
      contentType: widget.contentType,
    );
    _startHeartbeat();
    _bootstrap();
  }

  @override
  void dispose() {
    _disposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _heartbeat?.cancel();
    _countdownToken++;
    // Last resort when the page is removed by something other than our own
    // exit paths. No-op if a shutdown already ran.
    _shutdown(reason: 'dispose');
    super.dispose();
  }

  void _set(VoidCallback fn) {
    if (mounted && !_disposing) setState(fn);
  }

  // ─── LIFECYCLE ──────────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        // Permission dialogs and the Settings app are not an exit.
        if (_requestingPermission || _openingSettings) return;
        if (_isShuttingDown) return;
        // The camera is not available in the background and a stream cannot
        // be kept alive, so end the session instead of leaving the channel
        // live with a dead feed.
        _exitedInBackground = true;
        _shutdown(reason: 'background');
        break;

      case AppLifecycleState.resumed:
        if (_exitedInBackground) {
          _exitSession(
            message: 'Stream stopped because the app went to the background.',
          );
        } else if (_openingSettings) {
          _openingSettings = false;
          if (_engine == null && !_isShuttingDown) _bootstrap();
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  // ─── SETUP ──────────────────────────────────────────────────────────────────

  Future<void> _bootstrap() async {
    if (_isShuttingDown) return;
    _set(() {
      isLoading = true;
      _initError = null;
    });

    var status = await StreamingPermissionService.check();
    if (status != StreamingPermissionStatus.granted && !_isShuttingDown) {
      _requestingPermission = true;
      try {
        status = await StreamingPermissionService.request();
      } finally {
        _requestingPermission = false;
      }
    }
    if (_isShuttingDown) return;

    if (status != StreamingPermissionStatus.granted) {
      _set(() {
        _permission = status;
        isLoading = false;
      });
      return;
    }
    _set(() => _permission = status);

    await _initEngine();
  }

  Future<void> _initEngine() async {
    final engine = StreamingEngine.create();
    _engine = engine;
    _engineSub = engine.events.listen(_onEngineEvent);

    try {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      userSelectedLandscape = false;
      await engine.init();

      if (_isShuttingDown) {
        // The user left while the camera was starting.
        await engine.dispose();
        return;
      }
      try {
        await WakelockPlus.enable();
      } catch (e) {
        debugPrint('Wakelock enable failed: $e');
      }
    } on StreamingException catch (e) {
      debugPrint('Streaming init failed: $e');
      await _discardEngine();
      if (e.code == 'permission_denied') {
        _set(() => _permission = StreamingPermissionStatus.permanentlyDenied);
      } else {
        _set(() => _initError = 'Could not start the camera. Please try again.');
      }
    } catch (e) {
      debugPrint('Streaming init failed: $e');
      await _discardEngine();
      _set(() => _initError = 'Could not start the camera. Please try again.');
    } finally {
      _set(() => isLoading = false);
    }
  }

  Future<void> _discardEngine() async {
    final engine = _engine;
    _engine = null;
    await _engineSub?.cancel();
    _engineSub = null;
    await engine?.dispose();
  }

  Future<void> _retryInit() async {
    await _discardEngine();
    await _bootstrap();
  }

  Future<void> _openSettings() async {
    _openingSettings = true;
    final opened = await StreamingPermissionService.openSettings();
    if (!opened) _openingSettings = false;
  }

  // ─── ENGINE EVENTS ──────────────────────────────────────────────────────────

  void _onEngineEvent(StreamEvent event) {
    if (_isShuttingDown || _disposing) return;

    switch (event.type) {
      case StreamEventType.connecting:
        _set(() => streamStatus = "Connecting...");
        break;
      case StreamEventType.live:
        _set(() {
          isStreaming = true;
          isPreparing = false;
          streamStatus = "LIVE";
        });
        break;
      case StreamEventType.reconnecting:
        _set(() => streamStatus = "Reconnecting...");
        break;
      case StreamEventType.failed:
      case StreamEventType.stopped:
      case StreamEventType.cameraLost:
        // Only reachable when we did not ask for the stop.
        _exitSession(message: 'The live stream was interrupted and has been stopped.');
        break;
    }
  }

  // ─── CAMERA CONTROLS ────────────────────────────────────────────────────────

  bool get _controlsLocked =>
      isStreaming || isPreparing || isSwitching || isStopping || !_engineReady;

  Future<void> _switchCamera() async {
    final engine = _engine;
    if (engine == null || _controlsLocked) return;

    _set(() => isSwitching = true);
    try {
      await engine.switchCamera();
    } on StreamingException catch (e) {
      debugPrint('Switch camera failed: $e');
      _showMessage('Could not switch camera.');
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _set(() => isSwitching = false);
    }
  }

  Future<void> _toggleOrientation() async {
    final engine = _engine;
    if (engine == null || _controlsLocked) return;

    final landscape = !userSelectedLandscape;
    _set(() {
      isSwitching = true;
      userSelectedLandscape = landscape;
    });

    try {
      await SystemChrome.setPreferredOrientations(
        landscape
            ? (Platform.isIOS
                  ? [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]
                  : [DeviceOrientation.landscapeLeft])
            : [DeviceOrientation.portraitUp],
      );
      await engine.setOrientation(landscape: landscape);
    } on StreamingException catch (e) {
      debugPrint('Orientation change failed: $e');
      _showMessage('Could not change orientation.');
    } finally {
      _set(() => isSwitching = false);
    }
  }

  // ─── START STREAM ───────────────────────────────────────────────────────────

  Future<void> _startCountdownFlow() async {
    final engine = _engine;
    if (engine == null ||
        !_engineReady ||
        isPreparing ||
        isStreaming ||
        _isShuttingDown) {
      return;
    }

    final token = ++_countdownToken;
    _set(() {
      isPreparing = true;
      streamStatus = "Starting...";
    });

    try {
      final channel = _channels.selectedChannel;
      if (channel != null && channel.status != "live") {
        await _channels.startChannel(channel.channelId);
      }

      for (var i = 3; i > 0; i--) {
        if (!mounted || token != _countdownToken || _isShuttingDown) return;
        _set(() => countdown = i);
        await Future.delayed(const Duration(seconds: 1));
      }
      if (!mounted || token != _countdownToken || _isShuttingDown) return;

      await _startStream(engine);
    } catch (e) {
      debugPrint('Start flow failed: $e');
      if (token == _countdownToken && !_isShuttingDown) {
        _exitSession(message: 'Failed to start the live stream.');
      }
    }
  }

  Future<void> _startStream(StreamingEngine engine) async {
    try {
      _set(() => streamStatus = "Connecting...");
      await engine.startStream(widget.rtmpUrl);
      if (_isShuttingDown) return;
      _set(() {
        isStreaming = true;
        isPreparing = false;
        streamStatus = "LIVE";
      });
    } on StreamingException catch (e) {
      debugPrint('Stream start failed: $e');
      if (_isShuttingDown) return;
      _set(() => streamStatus = "Stream Failed");
      // The channel was already started for this session; roll it back so the
      // screens do not keep showing a dead stream.
      _exitSession(message: 'Could not connect to the live stream. Please try again.');
    }
  }

  // ─── STOP / EXIT ────────────────────────────────────────────────────────────

  /// Runs the shutdown, then returns to Home and optionally shows [message].
  Future<void> _exitSession({String? message}) async {
    if (_exiting) return;
    _exiting = true;

    final messenger = mounted ? ScaffoldMessenger.maybeOf(context) : null;
    await _shutdown(reason: 'exit');
    _navToHome();
    if (message != null) {
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _navToHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  /// Idempotent: every caller shares the same run.
  Future<void> _shutdown({required String reason}) {
    _shuttingDown = true;
    return _shutdownFuture ??= _runShutdown(reason);
  }

  Future<void> _runShutdown(String reason) async {
    debugPrint('Go live shutdown: $reason');
    _countdownToken++;
    _heartbeat?.cancel();
    _set(() {
      isStopping = true;
      isPreparing = false;
      streamStatus = "Stopping...";
    });

    // 1. Stop publishing and release camera + mic.
    try {
      await _engine?.dispose();
    } catch (e) {
      debugPrint('Engine dispose error: $e');
    }
    await _engineSub?.cancel();
    _engineSub = null;

    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('Wakelock error: $e');
    }
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      debugPrint('Orientation reset error: $e');
    }

    // 2. Tell the backend. A failure keeps the pending marker so the next
    //    launch (or the backend watchdog) finishes the job.
    var stopped = true;
    try {
      if (widget.channelId.isNotEmpty) {
        stopped = await _channels.stopChannelWithRetry(widget.channelId);
      }
      if (widget.contentId.isNotEmpty) {
        await _liveContent.deleteSchedules(widget.contentId, widget.contentType);
      }
    } catch (e) {
      stopped = false;
      debugPrint('Teardown error: $e');
    }
    if (stopped) await StreamingRecoveryService.clear();
    StreamingRecoveryService.sessionActive = false;

    _set(() {
      isStreaming = false;
      isPreparing = false;
      isStopping = false;
      streamStatus = "Stopped";
    });
  }

  // ─── HEARTBEAT ──────────────────────────────────────────────────────────────

  /// Lets the backend know this phone is still driving the channel. If the app
  /// is killed the pings stop and the backend stops the channel itself.
  void _startHeartbeat() {
    if (widget.channelId.isEmpty) return;

    Future<void> beat() async {
      if (_isShuttingDown) return;
      final supported = await _channels.heartbeat(widget.channelId);
      // An older backend has no heartbeat endpoint: stop asking for this session.
      if (!supported) _heartbeat?.cancel();
    }

    beat();
    _heartbeat = Timer.periodic(_heartbeatInterval, (_) => beat());
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ─── UI COMPONENTS ──────────────────────────────────────────────────────────

  Widget _buildPreview() {
    final engine = _engine;
    if (engine == null || !_engineReady || isSwitching) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }
    return engine.buildPreview();
  }

  Widget _glassContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double borderRadius = 20,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _controlButton({
    required Widget icon,
    required VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: _glassContainer(
          borderRadius: 30,
          padding: const EdgeInsets.all(12),
          child: icon,
        ),
      ),
    );
  }

  /// Full-screen message with actions, used for permission / camera problems.
  Widget _buildBlockedView({
    required IconData icon,
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 56),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 28),
            ...actions,
          ],
        ),
      ),
    );
  }

  Widget _blockedButton(String label, VoidCallback onTap, {bool primary = true}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: primary ? appColors.accent : Colors.white12,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget? _buildBlockedState() {
    if (isLoading) return null;

    if (_permission != null && _permission != StreamingPermissionStatus.granted) {
      final permanent = _permission == StreamingPermissionStatus.permanentlyDenied;
      return _buildBlockedView(
        icon: Icons.videocam_off_rounded,
        title: 'Camera & microphone access needed',
        message: permanent
            ? 'Access was turned off for this app. Open Settings and allow Camera and Microphone to go live.'
            : 'Allow Camera and Microphone so you can broadcast live.',
        actions: [
          if (permanent)
            _blockedButton('Open Settings', _openSettings)
          else
            _blockedButton('Allow Access', _bootstrap),
          const SizedBox(height: 12),
          _blockedButton('Cancel', () => _exitSession(), primary: false),
        ],
      );
    }

    if (_initError != null) {
      return _buildBlockedView(
        icon: Icons.error_outline_rounded,
        title: 'Camera unavailable',
        message: _initError!,
        actions: [
          _blockedButton('Try Again', _retryInit),
          const SizedBox(height: 12),
          _blockedButton('Cancel', () => _exitSession(), primary: false),
        ],
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady = _engineReady;
    final bool lockControls = _controlsLocked;
    final blocked = _buildBlockedState();
    final front = _engine?.isFrontCamera ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitSession();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: blocked != null
            ? SafeArea(child: blocked)
            : Stack(
                children: [
                  // Camera Background
                  Positioned.fill(child: _buildPreview()),

                  if (isLoading)
                    Container(
                      color: Colors.black87,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),

                  // Top Gradient Overlay (for text readability)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Stack(
                      children: [
                        // Top Bar
                        Positioned(
                          top: 16,
                          left: 20,
                          right: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Close Button & Channel Name
                              _glassContainer(
                                borderRadius: 30,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _exitSession(),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 1,
                                      height: 16,
                                      color: Colors.white30,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.channelName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // LIVE Badge
                              if (isStreaming)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appColors.red.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: appColors.red.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "LIVE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Status Text
                        Positioned(
                          top: 70,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _glassContainer(
                              borderRadius: 20,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Text(
                                streamStatus,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Camera Controls
                        if (!isStreaming && !isPreparing)
                          Positioned(
                            right: 20,
                            top: MediaQuery.of(context).size.height * 0.35,
                            child: Column(
                              children: [
                                _controlButton(
                                  icon: Icon(
                                    front
                                        ? Icons.camera_front_rounded
                                        : Icons.camera_rear_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  disabled: lockControls,
                                  onTap: _switchCamera,
                                ),
                                const SizedBox(height: 20),
                                _controlButton(
                                  icon: Icon(
                                    userSelectedLandscape
                                        ? Icons.screen_lock_landscape_rounded
                                        : Icons.screen_lock_portrait_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  disabled: lockControls,
                                  onTap: _toggleOrientation,
                                ),
                              ],
                            ),
                          ),

                        // Main Action Button (Go Live / Stop)
                        Positioned(
                          bottom: 40,
                          left: 24,
                          right: 24,
                          child: GestureDetector(
                            onTap: (isStopping || isSwitching || !isReady)
                                ? null
                                : () {
                                    if (isStreaming) {
                                      _exitSession();
                                    } else {
                                      _startCountdownFlow();
                                    }
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                gradient: LinearGradient(
                                  colors: isStreaming
                                      ? [appColors.red, const Color(0xFF991B1B)]
                                      : [appColors.accent, const Color(0xFF1E40AF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isStreaming ? appColors.red : appColors.accent)
                                        .withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: isStopping
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        isStreaming ? "STOP STREAM" : "GO LIVE",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        // Countdown Overlay
                        if (isPreparing)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text(
                                  "$countdown",
                                  style: const TextStyle(
                                    fontSize: 120,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
