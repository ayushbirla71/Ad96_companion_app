// import 'package:cms_app/pages/home/home_page.dart';
// import 'package:cms_app/providers/live_content_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rtmp_broadcaster/camera.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// import '../../providers/channel_provider.dart';

// class GoLivePage extends StatefulWidget {
//   final String rtmpUrl;
//   final String channelName;
//   final String channelId;
//   final String contentId;

//   const GoLivePage({
//     super.key,
//     required this.rtmpUrl,
//     required this.channelName,
//     required this.channelId,
//     required this.contentId,
//   });

//   @override
//   State<GoLivePage> createState() => _GoLivePageState();
// }

// class _GoLivePageState extends State<GoLivePage>
//     with WidgetsBindingObserver {
//   CameraController? controller;
//   List<CameraDescription> cameras = [];

//   bool isStreaming = false;
//   bool isLoading = true;
//   bool _isCleaned = false;
//   bool isStopping = false; // ✅ loader state

//   bool isPreparing = true;
//   int countdown = 3;

//   late LiveContentProvider liveProvider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     liveProvider = context.read<LiveContentProvider>();

//     initCamera();
//     startCountdownFlow();
//   }

//   /// ✅ APP LIFECYCLE
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!_isCleaned &&
//         (state == AppLifecycleState.paused ||
//             state == AppLifecycleState.detached)) {
//       _cleanupOnExit();
//     }
//   }

//   void _goToHome() {
//     if (!mounted) return;

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const HomePage()),
//       (route) => false,
//     );
//   }

//   /// INIT CAMERA
//   Future<void> initCamera() async {
//     try {
//       cameras = await availableCameras();
//       if (cameras.isNotEmpty) {
//         controller = CameraController(
//           cameras.first,
//           ResolutionPreset.medium,
//           enableAudio: true,
//           androidUseOpenGL: true,
//         );
//         await controller!.initialize();
//       }
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }

//     if (mounted) {
//       setState(() => isLoading = false);
//     }
//   }

//   /// ✅ CLEANUP (SAFE + API AWAIT)
//   Future<void> _cleanupOnExit() async {
//     if (_isCleaned) return;
//     _isCleaned = true;

//     debugPrint("🧹 Cleaning up...");

//     /// 🔴 STOP STREAM
//     try {
//       if (controller != null) {
//         await controller!.stopVideoStreaming();
//       }
//     } catch (e) {
//       debugPrint("⚠️ stop stream error: $e");
//     }

//     /// 🔴 RELEASE CAMERA + MIC
//     try {
//       await controller?.dispose();
//       controller = null;
//     } catch (e) {
//       debugPrint("⚠️ dispose error: $e");
//     }

//     /// 🔴 DISABLE WAKELOCK
//     try {
//       await WakelockPlus.disable();
//     } catch (_) {}

//     if (mounted) {
//       setState(() {
//         isStreaming = false;
//       });
//     }

//     /// 🔴 API CALL (WAIT + TIMEOUT)
//     try {
//        liveProvider
//           .deleteSchedules(widget.contentId);
//           // .timeout(const Duration(seconds: 5));

//       debugPrint("✅ API success");
//     } catch (e) {
//       debugPrint("❌ API failed or timeout: $e");
//     }
//   }

//   /// FLOW
//   Future<void> startCountdownFlow() async {
//     final provider = context.read<ChannelProvider>();

//     try {
//       final channel = provider.selectedChannel;

//       if (channel != null && channel.status != "live") {
//         await provider.startChannel(channel.channelId);
//         await provider.fetchChannelDetails(channel.channelId);
//       }

//       for (int i = 3; i > 0; i--) {
//         if (!mounted) return;
//         setState(() => countdown = i);
//         await Future.delayed(const Duration(seconds: 1));
//       }

//       await startStream();
//     } catch (e) {
//       debugPrint("Countdown flow error: $e");
//     } finally {
//       if (mounted) {
//         setState(() => isPreparing = false);
//       }
//     }
//   }

//   /// START STREAM
//   Future<void> startStream() async {
//     if (controller == null || isStreaming) return;

//     try {
//       await controller!.startVideoStreaming(widget.rtmpUrl);
//       await WakelockPlus.enable();

//       if (mounted) {
//         setState(() {
//           isStreaming = true;
//         });
//       }
//     } catch (e) {
//       debugPrint("Start stream error: $e");
//     }
//   }

//   /// SWITCH CAMERA
//   Future<void> switchCamera() async {
//     if (cameras.length < 2 || controller == null) return;

//     final currentCamera = controller!.description;
//     final newCamera = cameras.firstWhere((c) => c != currentCamera);

//     final wasStreaming = isStreaming;

//     if (wasStreaming) {
//       try {
//         await controller!.stopVideoStreaming();
//       } catch (_) {}
//     }

//     await controller!.dispose();

//     controller = CameraController(
//       newCamera,
//       ResolutionPreset.medium,
//       enableAudio: true,
//       androidUseOpenGL: true,
//     );

//     await controller!.initialize();

//     if (mounted) setState(() {});

//     if (wasStreaming) {
//       await startStream();
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);

//     _cleanupOnExit(); // safe

//     super.dispose();
//   }

//   Widget liveBadge() {
//     if (!isStreaming) return const SizedBox();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.red,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: const Text(
//         "LIVE",
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading ||
//         controller == null ||
//         !(controller!.value.isInitialized ?? false)) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return WillPopScope(
//       onWillPop: () async {
//         setState(() => isStopping = true);
//         await _cleanupOnExit();
//         _goToHome();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.channelName),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: Center(child: liveBadge()),
//             )
//           ],
//         ),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Expanded(child: CameraPreview(controller!)),
//                 const SizedBox(height: 20),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.cameraswitch),
//                       iconSize: 36,
//                       onPressed:
//                           isPreparing || isStopping ? null : switchCamera,
//                     ),
//                     const SizedBox(width: 30),

//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             isStreaming ? Colors.red : Colors.green,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 30, vertical: 15),
//                       ),
//                       onPressed: isPreparing || isStopping
//                           ? null
//                           : () async {
//                               setState(() => isStopping = true);

//                               await _cleanupOnExit();

//                               if (mounted) {
//                                 _goToHome();
//                               }
//                             },
//                       child: isStopping
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child:
//                                   CircularProgressIndicator(strokeWidth: 2),
//                             )
//                           : Text(
//                               isStreaming ? "STOP LIVE" : "GO LIVE",
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),

//             /// COUNTDOWN
//             if (isPreparing)
//               Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: Center(
//                   child: Text(
//                     countdown > 0 ? "$countdown" : "Starting...",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 80,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//   after one live testing .....

// import 'package:cms_app/pages/home/home_page.dart';
// import 'package:cms_app/providers/live_content_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rtmp_broadcaster/camera.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// import '../../providers/channel_provider.dart';

// class GoLivePage extends StatefulWidget {
//   final String rtmpUrl;
//   final String channelName;
//   final String channelId;
//   final String contentId;

//   const GoLivePage({
//     super.key,
//     required this.rtmpUrl,
//     required this.channelName,
//     required this.channelId,
//     required this.contentId,
//   });

//   @override
//   State<GoLivePage> createState() => _GoLivePageState();
// }

// class _GoLivePageState extends State<GoLivePage>
//     with WidgetsBindingObserver {
//   CameraController? controller;
//   List<CameraDescription> cameras = [];

//   bool isStreaming = false;
//   bool isLoading = true;
//   bool _isCleaned = false;
//   bool isStopping = false;

//   bool isPreparing = false; // ✅ FIXED (was true)
//   int countdown = 3;

//   late LiveContentProvider liveProvider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     liveProvider = context.read<LiveContentProvider>();

//     initCamera(); // ✅ ONLY camera init (no countdown here)
//   }

//   /// APP LIFECYCLE
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!_isCleaned &&
//         (state == AppLifecycleState.paused ||
//             state == AppLifecycleState.detached)) {
//       _cleanupOnExit();
//     }
//   }

//   void _goToHome() {
//     if (!mounted) return;

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const HomePage()),
//       (route) => false,
//     );
//   }

//   /// INIT CAMERA
//   Future<void> initCamera() async {
//     try {
//       cameras = await availableCameras();
//       if (cameras.isNotEmpty) {
//         controller = CameraController(
//           cameras.first,
//           ResolutionPreset.medium,
//           enableAudio: true,
//           androidUseOpenGL: true,
//         );
//         await controller!.initialize();
//       }
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }

//     if (mounted) {
//       setState(() => isLoading = false);
//     }
//   }

//   /// CLEANUP
//   Future<void> _cleanupOnExit() async {
//     if (_isCleaned) return;
//     _isCleaned = true;

//     debugPrint("🧹 Cleaning up...");

//     try {
//       if (controller != null) {
//         await controller!.stopVideoStreaming();
//       }
//     } catch (e) {
//       debugPrint("⚠️ stop stream error: $e");
//     }

//     try {
//       await controller?.dispose();
//       controller = null;
//     } catch (e) {
//       debugPrint("⚠️ dispose error: $e");
//     }

//     try {
//       await WakelockPlus.disable();
//     } catch (_) {}

//     if (mounted) {
//       setState(() {
//         isStreaming = false;
//       });
//     }

//     /// ✅ FIXED (added await)
//     try {
//      liveProvider.deleteSchedules(widget.contentId);
//       debugPrint("✅ API success");
//     } catch (e) {
//       debugPrint("❌ API failed: $e");
//     }
//   }

//   /// COUNTDOWN FLOW (now triggered manually)
//   Future<void> startCountdownFlow() async {
//     final provider = context.read<ChannelProvider>();

//     try {
//       final channel = provider.selectedChannel;

//       if (channel != null && channel.status != "live") {
//         await provider.startChannel(channel.channelId);
//         await provider.fetchChannelDetails(channel.channelId);
//       }

//       for (int i = 3; i > 0; i--) {
//         if (!mounted) return;
//         setState(() => countdown = i);
//         await Future.delayed(const Duration(seconds: 1));
//       }

//       await startStream();
//     } catch (e) {
//       debugPrint("Countdown flow error: $e");
//     } finally {
//       if (mounted) {
//         setState(() => isPreparing = false);
//       }
//     }
//   }

//   /// START STREAM
//   Future<void> startStream() async {
//     if (controller == null || isStreaming) return;

//     try {
//       await controller!.startVideoStreaming(widget.rtmpUrl);
//       await WakelockPlus.enable();

//       if (mounted) {
//         setState(() {
//           isStreaming = true;
//         });
//       }
//     } catch (e) {
//       debugPrint("Start stream error: $e");
//     }
//   }

//   /// SWITCH CAMERA (smooth restart)
//   Future<void> switchCamera() async {
//     if (cameras.length < 2 || controller == null) return;

//     setState(() => isPreparing = true); // overlay

//     final currentCamera = controller!.description;
//     final newCamera = cameras.firstWhere((c) => c != currentCamera);

//     final wasStreaming = isStreaming;

//     try {
//       if (wasStreaming) {
//         await controller!.stopVideoStreaming();
//         isStreaming = false;
//       }

//       await controller!.dispose();

//       controller = CameraController(
//         newCamera,
//         ResolutionPreset.medium,
//         enableAudio: true,
//         androidUseOpenGL: true,
//       );

//       await controller!.initialize();

//       if (mounted) setState(() {});

//       if (wasStreaming) {
//         await startStream();
//       }
//     } catch (e) {
//       debugPrint("Switch camera error: $e");
//     }

//     if (mounted) {
//       setState(() => isPreparing = false);
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _cleanupOnExit();
//     super.dispose();
//   }

//   Widget liveBadge() {
//     if (!isStreaming) return const SizedBox();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.red,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: const Text(
//         "LIVE",
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading ||
//         controller == null ||
//         !(controller!.value.isInitialized ?? false)) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return WillPopScope(
//       onWillPop: () async {
//         setState(() => isStopping = true);
//         await _cleanupOnExit();
//         _goToHome();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.channelName),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: Center(child: liveBadge()),
//             )
//           ],
//         ),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Expanded(child: CameraPreview(controller!)),
//                 const SizedBox(height: 20),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.cameraswitch),
//                       iconSize: 36,
//                       onPressed:
//                           isPreparing || isStopping ? null : switchCamera,
//                     ),
//                     const SizedBox(width: 30),

//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             isStreaming ? Colors.red : Colors.green,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 30, vertical: 15),
//                       ),
//                       onPressed: isPreparing || isStopping
//                           ? null
//                           : () async {
//                               if (!isStreaming) {
//                                 /// ✅ START COUNTDOWN HERE
//                                 setState(() {
//                                   isPreparing = true;
//                                   countdown = 3;
//                                 });

//                                 await startCountdownFlow();
//                               } else {
//                                 /// STOP STREAM
//                                 setState(() => isStopping = true);

//                                 await _cleanupOnExit();

//                                 if (mounted) {
//                                   _goToHome();
//                                 }
//                               }
//                             },
//                       child: isStopping
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child:
//                                   CircularProgressIndicator(strokeWidth: 2),
//                             )
//                           : Text(
//                               isStreaming ? "STOP LIVE" : "GO LIVE",
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),

//             /// COUNTDOWN / SWITCH OVERLAY
//             if (isPreparing)
//               Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: Center(
//                   child: Text(
//                     countdown > 0 ? "$countdown" : "Starting...",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 80,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

////////////////////////// after stable /////////////////////////////////

// import 'package:cms_app/pages/home/home_page.dart';
// import 'package:cms_app/providers/live_content_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rtmp_broadcaster/camera.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// import '../../providers/channel_provider.dart';

// class GoLivePage extends StatefulWidget {
//   final String rtmpUrl;
//   final String channelName;
//   final String channelId;
//   final String contentId;

//   const GoLivePage({
//     super.key,
//     required this.rtmpUrl,
//     required this.channelName,
//     required this.channelId,
//     required this.contentId,
//   });

//   @override
//   State<GoLivePage> createState() => _GoLivePageState();
// }

// class _GoLivePageState extends State<GoLivePage>
//     with WidgetsBindingObserver {
//   CameraController? controller;
//   List<CameraDescription> cameras = [];

//   bool isStreaming = false;
//   bool isLoading = true;
//   bool _isCleaned = false;
//   bool isStopping = false;

//   bool isPreparing = false; // ✅ countdown only
//   bool isSwitching = false; // ✅ camera switch loader

//   int countdown = 3;

//   late LiveContentProvider liveProvider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     liveProvider = context.read<LiveContentProvider>();

//     initCamera();
//   }

//   /// APP LIFECYCLE
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!_isCleaned &&
//         (state == AppLifecycleState.paused ||
//             state == AppLifecycleState.detached)) {
//       _cleanupOnExit();
//     }
//   }

//   void _goToHome() {
//     if (!mounted) return;

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const HomePage()),
//       (route) => false,
//     );
//   }

//   /// INIT CAMERA
//   Future<void> initCamera() async {
//     try {
//       cameras = await availableCameras();
//       if (cameras.isNotEmpty) {
//         controller = CameraController(
//           cameras.first,
//           ResolutionPreset.medium,
//           enableAudio: true,
//           androidUseOpenGL: true,
//         );
//         await controller!.initialize();
//       }
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }

//     if (mounted) {
//       setState(() => isLoading = false);
//     }
//   }

//   /// CLEANUP
//   Future<void> _cleanupOnExit() async {
//     if (_isCleaned) return;
//     _isCleaned = true;

//     debugPrint("🧹 Cleaning up...");

//     try {
//       if (controller != null) {
//         await controller!.stopVideoStreaming();
//       }
//     } catch (e) {
//       debugPrint("⚠️ stop stream error: $e");
//     }

//     try {
//       await controller?.dispose();
//       controller = null;
//     } catch (e) {
//       debugPrint("⚠️ dispose error: $e");
//     }

//     try {
//       await WakelockPlus.disable();
//     } catch (_) {}

//     if (mounted) {
//       setState(() {
//         isStreaming = false;
//       });
//     }

//     try {
//       await liveProvider.deleteSchedules(widget.contentId);
//       debugPrint("✅ API success");
//     } catch (e) {
//       debugPrint("❌ API failed: $e");
//     }
//   }

//   /// COUNTDOWN FLOW
//   Future<void> startCountdownFlow() async {
//     final provider = context.read<ChannelProvider>();

//     try {
//       final channel = provider.selectedChannel;

//       if (channel != null && channel.status != "live") {
//         await provider.startChannel(channel.channelId);
//         await provider.fetchChannelDetails(channel.channelId);
//       }

//       for (int i = 3; i > 0; i--) {
//         if (!mounted) return;
//         setState(() => countdown = i);
//         await Future.delayed(const Duration(seconds: 1));
//       }

//       await startStream();
//     } catch (e) {
//       debugPrint("Countdown flow error: $e");
//     } finally {
//       if (mounted) {
//         setState(() => isPreparing = false);
//       }
//     }
//   }

//   /// START STREAM
//   Future<void> startStream() async {
//     if (controller == null || isStreaming) return;

//     try {
//       await controller!.startVideoStreaming(widget.rtmpUrl);
//       await WakelockPlus.enable();

//       if (mounted) {
//         setState(() {
//           isStreaming = true;
//         });
//       }
//     } catch (e) {
//       debugPrint("Start stream error: $e");
//     }
//   }

//   /// SWITCH CAMERA
//   Future<void> switchCamera() async {
//     if (cameras.length < 2 || controller == null) return;

//     setState(() => isSwitching = true);

//     final currentCamera = controller!.description;
//     final newCamera = cameras.firstWhere((c) => c != currentCamera);

//     final wasStreaming = isStreaming;

//     try {
//       if (wasStreaming) {
//         await controller!.stopVideoStreaming();
//         isStreaming = false;
//       }

//       await controller!.dispose();

//       controller = CameraController(
//         newCamera,
//         ResolutionPreset.medium,
//         enableAudio: true,
//         androidUseOpenGL: true,
//       );

//       await controller!.initialize();

//       if (mounted) setState(() {});

//       if (wasStreaming) {
//         await startStream();
//       }
//     } catch (e) {
//       debugPrint("Switch camera error: $e");
//     }

//     if (mounted) {
//       setState(() => isSwitching = false);
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _cleanupOnExit();
//     super.dispose();
//   }

//   Widget liveBadge() {
//     if (!isStreaming) return const SizedBox();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.red,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: const Text(
//         "LIVE",
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading ||
//         controller == null ||
//         !(controller!.value.isInitialized ?? false)) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return WillPopScope(
//       onWillPop: () async {
//         setState(() => isStopping = true);
//         await _cleanupOnExit();
//         _goToHome();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.channelName),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: Center(child: liveBadge()),
//             )
//           ],
//         ),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Expanded(child: CameraPreview(controller!)),
//                 const SizedBox(height: 20),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.cameraswitch),
//                       iconSize: 36,
//                       onPressed: isPreparing || isStopping || isSwitching
//                           ? null
//                           : switchCamera,
//                     ),
//                     const SizedBox(width: 30),

//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             isStreaming ? Colors.red : Colors.green,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 30, vertical: 15),
//                       ),
//                       onPressed: isPreparing || isStopping
//                           ? null
//                           : () async {
//                               if (!isStreaming) {
//                                 setState(() {
//                                   isPreparing = true;
//                                   countdown = 3;
//                                 });

//                                 await startCountdownFlow();
//                               } else {
//                                 setState(() => isStopping = true);

//                                 await _cleanupOnExit();

//                                 if (mounted) {
//                                   _goToHome();
//                                 }
//                               }
//                             },
//                       child: isStopping
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child:
//                                   CircularProgressIndicator(strokeWidth: 2),
//                             )
//                           : Text(
//                               isStreaming ? "STOP LIVE" : "GO LIVE",
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),

//             /// ✅ COUNTDOWN ONLY FOR GO LIVE
//             if (isPreparing)
//               Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: Center(
//                   child: Text(
//                     countdown > 0 ? "$countdown" : "Starting...",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 80,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),

//             /// ✅ CAMERA SWITCH LOADER ONLY
//             if (isSwitching)
//               Container(
//                 color: Colors.black.withOpacity(0.4),
//                 child: const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

////////////////////////////////////
///
///
///
///



// import 'package:cms_app/pages/home/home_page.dart';
// import 'package:cms_app/providers/live_content_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rtmp_broadcaster/camera.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// import '../../providers/channel_provider.dart';

// class GoLivePage extends StatefulWidget {
//   final String rtmpUrl;
//   final String channelName;
//   final String channelId;
//   final String contentId;

//   const GoLivePage({
//     super.key,
//     required this.rtmpUrl,
//     required this.channelName,
//     required this.channelId,
//     required this.contentId,
//   });

//   @override
//   State<GoLivePage> createState() => _GoLivePageState();
// }

// class _GoLivePageState extends State<GoLivePage> with WidgetsBindingObserver {
//   CameraController? controller;
//   List<CameraDescription> cameras = [];

//   bool isStreaming = false;
//   bool isLoading = true;
//   bool _isCleaned = false;
//   bool isStopping = false;

//   bool isPreparing = false;
//   bool isSwitching = false;

//   int countdown = 3;

//   late LiveContentProvider liveProvider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     liveProvider = context.read<LiveContentProvider>();
//     initCamera();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!_isCleaned &&
//         (state == AppLifecycleState.paused ||
//             state == AppLifecycleState.detached)) {
//       _cleanupOnExit();
//     }
//   }

//   void _goToHome() {
//     if (!mounted) return;

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const HomePage()),
//       (route) => false,
//     );
//   }

//   Future<void> initCamera() async {
//     try {
//       cameras = await availableCameras();

//       if (cameras.isEmpty) throw Exception("No camera found");

//       controller = CameraController(
//         cameras.first,
//         ResolutionPreset.medium,
//         enableAudio: true,
//         androidUseOpenGL: true,
//       );

//       await controller!.initialize();
//     } catch (e) {
//       debugPrint("Camera error: $e");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Camera initialization failed")),
//         );
//       }
//     }

//     if (mounted) setState(() => isLoading = false);
//   }

//   Future<void> _cleanupOnExit() async {
//     if (_isCleaned) return;
//     _isCleaned = true;

//     try {
//       if (controller != null) {
//         await controller!.stopVideoStreaming();
//       }
//     } catch (e) {
//       debugPrint("stop stream error: $e");
//     }

//     try {
//       await controller?.dispose();
//       controller = null;
//     } catch (e) {
//       debugPrint("dispose error: $e");
//     }

//     await WakelockPlus.disable();

//     if (mounted) {
//       setState(() => isStreaming = false);
//     }

//     try {
//       liveProvider.deleteSchedules(widget.contentId);
//     } catch (e) {
//       debugPrint("API failed: $e");
//     }
//   }

//   Future<void> startCountdownFlow() async {
//     final provider = context.read<ChannelProvider>();

//     try {
//       final channel = provider.selectedChannel;

//       if (channel != null && channel.status != "live") {
//         await provider.startChannel(channel.channelId);
//         await provider.fetchChannelDetails(channel.channelId);
//       }

//       for (int i = 3; i > 0; i--) {
//         if (!mounted) return;
//         setState(() => countdown = i);
//         await Future.delayed(const Duration(seconds: 1));
//       }

//       await startStream();
//     } catch (e) {
//       debugPrint("Countdown flow error: $e");
//     } finally {
//       if (mounted) setState(() => isPreparing = false);
//     }
//   }

//   Future<void> startStream() async {
//     if (controller == null || isStreaming) return;

//     try {
//       await controller!.startVideoStreaming(widget.rtmpUrl);
//       await WakelockPlus.enable();

//       if (mounted) {
//         setState(() => isStreaming = true);
//       }
//     } catch (e) {
//       debugPrint("Start stream error: $e");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to start live stream")),
//         );
//       }
//     }
//   }

//   Future<void> switchCamera() async {
//     if (cameras.length < 2 || controller == null) return;

//     setState(() => isSwitching = true);

//     final currentCamera = controller!.description;
//     final newCamera = cameras.firstWhere((c) => c != currentCamera);

//     final wasStreaming = isStreaming;

//     try {
//       if (wasStreaming) {
//         await controller!.stopVideoStreaming();
//         isStreaming = false;
//       }

//       await controller!.dispose();

//       controller = CameraController(
//         newCamera,
//         ResolutionPreset.medium,
//         enableAudio: true,
//         androidUseOpenGL: true,
//       );

//       await controller!.initialize();

//       if (mounted) setState(() {});

//       if (wasStreaming) {
//         await startStream();
//       }
//     } catch (e) {
//       debugPrint("Switch camera error: $e");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Camera switch failed")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => isSwitching = false);
//     }
//   }

//   // Future<void> switchCamera() async {
//   //   if (isSwitching) return;

//   //   setState(() => isSwitching = true);

//   //   try {
//   //     final cameras = await availableCameras();

//   //     final currentIndex = cameras.indexWhere(
//   //       (c) => c.name == controller?.description.name,
//   //     );

//   //     final nextIndex = (currentIndex + 1) % cameras.length;
//   //     final newCamera = cameras[nextIndex];

//   //     await controller?.dispose();

//   //     controller = CameraController(
//   //       newCamera,
//   //       ResolutionPreset.high,
//   //       enableAudio: true,
//   //     );

//   //     await controller!.initialize();

//   //     if (mounted) setState(() {});
//   //   } catch (e) {
//   //     debugPrint("Camera switch error: $e");
//   //   } finally {
//   //     if (mounted) setState(() => isSwitching = false);
//   //   }
//   // }

//   /// ✅ Helper: Get proper camera icon
//   IconData getCameraIcon() {
//     final lens = controller?.description.lensDirection;

//     if (lens == CameraLensDirection.front) {
//       return Icons.camera_front;
//     } else if (lens == CameraLensDirection.back) {
//       return Icons.camera_rear;
//     } else if (lens == CameraLensDirection.external) {
//       return Icons.videocam; // external camera
//     } else {
//       return Icons.cameraswitch; // fallback
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _cleanupOnExit();
//     super.dispose();
//   }

//   Widget liveBadge() {
//     if (!isStreaming) return const SizedBox();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.red,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: const Text(
//         "LIVE",
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isReady = controller?.value.isInitialized == true;

//     return WillPopScope(
//       onWillPop: () async {
//         setState(() => isStopping = true);
//         await _cleanupOnExit();
//         _goToHome();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.channelName),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: Center(child: liveBadge()),
//             ),
//           ],
//         ),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       isReady
//                           ? CameraPreview(controller!)
//                           : Container(color: Colors.black),

//                       if (isLoading || isSwitching)
//                         Container(
//                           color: Colors.black.withOpacity(0.4),
//                           child: const Center(
//                             child: CircularProgressIndicator(),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       onPressed: (isSwitching || controller == null)
//                           ? null
//                           : switchCamera,
//                       icon: Icon(getCameraIcon()),
//                     ),
//                     const SizedBox(width: 30),

//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isStreaming
//                             ? Colors.red
//                             : Colors.green,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 30,
//                           vertical: 15,
//                         ),
//                       ),
//                       onPressed: isPreparing || isStopping
//                           ? null
//                           : () async {
//                               if (!isStreaming) {
//                                 setState(() {
//                                   isPreparing = true;
//                                   countdown = 3;
//                                 });

//                                 await startCountdownFlow();
//                               } else {
//                                 setState(() => isStopping = true);
//                                 await _cleanupOnExit();
//                                 if (mounted) _goToHome();
//                               }
//                             },
//                       child: isStopping
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             )
//                           : Text(
//                               isStreaming ? "STOP LIVE" : "GO LIVE",
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),

//             if (isPreparing)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                   child: Center(
//                     child: Text(
//                       countdown > 0 ? "$countdown" : "Starting...",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 80,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }




///////////////////// woring code with both portrat and landscap ////////////////////////////


// import 'package:cms_app/pages/home/home_page.dart';
// import 'package:cms_app/providers/live_content_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rtmp_streaming/camera.dart'; 
// import 'package:wakelock_plus/wakelock_plus.dart';

// import '../../providers/channel_provider.dart';

// class GoLivePage extends StatefulWidget {
//   final String rtmpUrl;
//   final String channelName;
//   final String channelId;
//   final String contentId;

//   const GoLivePage({
//     super.key,
//     required this.rtmpUrl,
//     required this.channelName,
//     required this.channelId,
//     required this.contentId,
//   });

//   @override
//   State<GoLivePage> createState() => _GoLivePageState();
// }

// class _GoLivePageState extends State<GoLivePage> with WidgetsBindingObserver {
//   CameraController? controller;
//   List<CameraDescription> cameras = [];
//   CameraDescription? currentCamera;

//   bool isStreaming = false;
//   bool isLoading = true;
//   bool _isCleaned = false;
//   bool isStopping = false;

//   bool isPreparing = false;
//   bool isSwitching = false;

//   int countdown = 3;

//   late LiveContentProvider liveProvider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     liveProvider = context.read<LiveContentProvider>();
//     initCamera();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!_isCleaned &&
//         (state == AppLifecycleState.paused ||
//             state == AppLifecycleState.detached)) {
//       _cleanupOnExit();
//     }
//   }

//   void _goToHome() {
//     if (!mounted) return;

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const HomePage()),
//       (route) => false,
//     );
//   }

//   Future<void> initCamera() async {
//     try {
//       cameras = await availableCameras();

//       if (cameras.isEmpty) throw Exception("No camera found");

//       currentCamera = cameras.first;

//       controller = CameraController(
//         ResolutionPreset.medium,
//         enableAudio: true,
//         androidUseOpenGL: true,
//       );

//       await controller!.initialize(currentCamera!);
//     } catch (e) {
//       debugPrint("Camera error: $e");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Camera initialization failed")),
//         );
//       }
//     }

//     if (mounted) setState(() => isLoading = false);
//   }

//   Future<void> _cleanupOnExit() async {
//     if (_isCleaned) return;
//     _isCleaned = true;

//     try {
//       if (controller != null) {
//         await controller!.stopVideoStreaming();
//       }
//     } catch (e) {
//       debugPrint("stop stream error: $e");
//     }

//     try {
//       await controller?.dispose();
//       controller = null;
//     } catch (e) {
//       debugPrint("dispose error: $e");
//     }

//     await WakelockPlus.disable();

//     if (mounted) {
//       setState(() => isStreaming = false);
//     }

//     try {
//       liveProvider.deleteSchedules(widget.contentId);
//     } catch (e) {
//       debugPrint("API failed: $e");
//     }
//   }

//   Future<void> startCountdownFlow() async {
//     final provider = context.read<ChannelProvider>();

//     try {
//       final channel = provider.selectedChannel;

//       if (channel != null && channel.status != "live") {
//         await provider.startChannel(channel.channelId);
//         await provider.fetchChannelDetails(channel.channelId);
//       }

//       for (int i = 3; i > 0; i--) {
//         if (!mounted) return;
//         setState(() => countdown = i);
//         await Future.delayed(const Duration(seconds: 1));
//       }

//       await startStream();
//     } catch (e) {
//       debugPrint("Countdown flow error: $e");
//     } finally {
//       if (mounted) setState(() => isPreparing = false);
//     }
//   }

//   Future<void> startStream() async {
//     if (controller == null || isStreaming) return;

//     try {
//       await controller!.startVideoStreaming(widget.rtmpUrl);
//       await WakelockPlus.enable();

//       if (mounted) {
//         setState(() => isStreaming = true);
//       }
//     } catch (e) {
//       debugPrint("Start stream error: $e");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to start live stream")),
//         );
//       }
//     }
//   }

//   Future<void> switchCamera() async {
//     if (cameras.length < 2 || controller == null || currentCamera == null) return;

//     setState(() => isSwitching = true);

//     int currentIndex = cameras.indexOf(currentCamera!);
//     int newIndex = (currentIndex + 1) % cameras.length;
//     currentCamera = cameras[newIndex];

//     final wasStreaming = isStreaming;

//     try {
//       if (wasStreaming) {
//         await controller!.stopVideoStreaming();
//         isStreaming = false;
//       }

//       await controller!.dispose();

//       controller = CameraController(
//         ResolutionPreset.medium,
//         enableAudio: true,
//         androidUseOpenGL: true,
//       );

//       await controller!.initialize(currentCamera!);

//       if (mounted) setState(() {});

//       if (wasStreaming) {
//         await startStream();
//       }
//     } catch (e) {
//       debugPrint("Switch camera error: $e");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Camera switch failed")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => isSwitching = false);
//     }
//   }

//   IconData getCameraIcon() {
//     final lens = currentCamera?.lensDirection;

//     if (lens == CameraLensDirection.front) {
//       return Icons.camera_front;
//     } else if (lens == CameraLensDirection.back) {
//       return Icons.camera_rear;
//     } else if (lens == CameraLensDirection.external) {
//       return Icons.videocam;
//     } else {
//       return Icons.cameraswitch;
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _cleanupOnExit();
//     super.dispose();
//   }

//   Widget liveBadge() {
//     if (!isStreaming) return const SizedBox();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.red,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: const Text(
//         "LIVE",
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildPreview() {
//     final isReady = controller?.value.isInitialized == true;

//     if (!isReady) {
//       return Container(color: Colors.black);
//     }

//     final previewSize = controller!.value.previewSize!;

//     return Stack(
//       children: [
//         Center(
//           child: AspectRatio(
//             aspectRatio: previewSize.width / previewSize.height,
//             child: CameraPreview(controller!),
//           ),
//         ),
//         if (isLoading || isSwitching)
//           Container(
//             color: Colors.black.withOpacity(0.4),
//             child: const Center(
//               child: CircularProgressIndicator(),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildControls(bool isLandscape) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         vertical: isLandscape ? 0 : 20, 
//         horizontal: isLandscape ? 20 : 0
//       ),
//       color: Colors.black.withOpacity(0.5),
//       child: isLandscape
//           ? Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: _controlButtons(),
//             )
//           : Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: _controlButtons(),
//             ),
//     );
//   }

//   List<Widget> _controlButtons() {
//     return [
//       IconButton(
//         onPressed: (isSwitching || controller == null) ? null : switchCamera,
//         icon: Icon(getCameraIcon(), color: Colors.white, size: 30),
//       ),
//       const SizedBox(height: 20, width: 20),
//       ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isStreaming ? Colors.red : Colors.green,
//           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//         ),
//         onPressed: isPreparing || isStopping
//             ? null
//             : () async {
//                 if (!isStreaming) {
//                   setState(() {
//                     isPreparing = true;
//                     countdown = 3;
//                   });
//                   await startCountdownFlow();
//                 } else {
//                   setState(() => isStopping = true);
//                   await _cleanupOnExit();
//                   if (mounted) _goToHome();
//                 }
//               },
//         child: isStopping
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//               )
//             : Text(
//                 isStreaming ? "STOP LIVE" : "GO LIVE",
//                 style: const TextStyle(fontSize: 16, color: Colors.white),
//               ),
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orientation = MediaQuery.of(context).orientation;
//     final isLandscape = orientation == Orientation.landscape;

//     return WillPopScope(
//       onWillPop: () async {
//         setState(() => isStopping = true);
//         await _cleanupOnExit();
//         _goToHome();
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           title: Text(widget.channelName),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: Center(child: liveBadge()),
//             ),
//           ],
//         ),
//         body: Stack(
//           children: [
//             isLandscape
//                 ? Row(
//                     children: [
//                       Expanded(child: _buildPreview()),
//                       SizedBox(
//                         width: 140,
//                         child: _buildControls(true),
//                       ),
//                     ],
//                   )
//                 : Column(
//                     children: [
//                       Expanded(child: _buildPreview()),
//                       SizedBox(
//                         height: 100,
//                         child: _buildControls(false),
//                       ),
//                     ],
//                   ),
//             if (isPreparing)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                   child: Center(
//                     child: Text(
//                       countdown > 0 ? "$countdown" : "Starting...",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 80,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


















///////////////////////////////////
///
///
import 'package:cms_app/pages/home/home_page.dart';
import 'package:cms_app/providers/live_content_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rtmp_streaming/camera.dart'; 
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../providers/channel_provider.dart';

class GoLivePage extends StatefulWidget {
  final String rtmpUrl;
  final String channelName;
  final String channelId;
  final String contentId;

  const GoLivePage({
    super.key,
    required this.rtmpUrl,
    required this.channelName,
    required this.channelId,
    required this.contentId,
  });

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> with WidgetsBindingObserver {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  CameraDescription? currentCamera;

  bool isStreaming = false;
  bool isLoading = true;
  bool _isCleaned = false;
  bool isStopping = false;
  bool isPreparing = false;
  bool isSwitching = false;
  
  bool userSelectedLandscape = false;
  int countdown = 3;
  late LiveContentProvider liveProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    liveProvider = Provider.of<LiveContentProvider>(context, listen: false);
    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _cleanupOnExit();
    }
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception("No camera found");
      if (_isCleaned || !mounted) return;

      currentCamera = cameras.first;
      await _setupController();
    } catch (e) {
      debugPrint("Init Camera Error: $e");
    } finally {
      if (mounted && !_isCleaned) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _setupController() async {
    if (controller != null) {
      final oldController = controller;
      controller = null; 
      if (mounted) setState(() {}); 
      await oldController!.dispose();
    }

    if (_isCleaned || !mounted) return;

    final newController = CameraController(
      ResolutionPreset.medium,// or veryHigh / ultraHigh
      enableAudio: true,
      androidUseOpenGL: true,
    );

    try {
      await newController.initialize(currentCamera!);
      if (mounted && !_isCleaned) {
        setState(() {
          controller = newController;
        });
      }
    } catch (e) {
      debugPrint("Setup Controller Error: $e");
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && !_isCleaned) initCamera();
    }
  }

 Future<void> _toggleOrientation() async {
    if (isStreaming || isPreparing || isSwitching) return;

    setState(() {
      isSwitching = true;
      userSelectedLandscape = !userSelectedLandscape;
    });

    try {
      if (userSelectedLandscape) {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
      } else {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
      
      // Increased delay: Gives the OS memory time to allocate the flipped high-res buffer
      await Future.delayed(const Duration(milliseconds: 600)); 
      await _setupController();
    } finally {
      if (mounted) setState(() => isSwitching = false);
    }
  }

  /// Navigates to Home and clears navigation stack
  void _navToHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  Future<void> _cleanupOnExit() async {
    if (_isCleaned) return;
    _isCleaned = true; 

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    try {
      if (controller != null) {
        if (isStreaming) {
          await controller!.stopVideoStreaming();
        }
        await controller!.dispose();
        controller = null; 
      }
      await WakelockPlus.disable();
       liveProvider.deleteSchedules(widget.contentId);
    } catch (e) {
      debugPrint("Cleanup error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isStreaming = false;
          isPreparing = false;
          isStopping = false;
        });
      }
    }
  }

  Future<void> startCountdownFlow() async {
    final bool isReady = controller?.value.isInitialized ?? false;
    if (_isCleaned || !mounted || !isReady) return;

    final provider = context.read<ChannelProvider>();
    try {
      setState(() => isPreparing = true);
      
      final channel = provider.selectedChannel;
      if (channel != null && channel.status != "live") {
        await provider.startChannel(channel.channelId);
      }

      for (int i = 3; i > 0; i--) {
        if (!mounted || _isCleaned || !isPreparing) return; 
        setState(() => countdown = i);
        await Future.delayed(const Duration(seconds: 1));
      }

      if (mounted && !_isCleaned && isPreparing) {
        await startStream();
      }
    } catch (e) {
      if (mounted) setState(() => isPreparing = false);
    }
  }

  Future<void> startStream() async {
    final bool isReady = controller?.value.isInitialized ?? false;
    if (!isReady || _isCleaned || controller == null) return;

    try {
      await controller!.startVideoStreaming(widget.rtmpUrl);
      await WakelockPlus.enable();
      if (mounted) {
        setState(() {
          isStreaming = true;
          isPreparing = false; 
        });
      }
    } catch (e) {
      if (mounted) setState(() => isPreparing = false);
    }
  }

  Future<void> switchCamera() async {
    if (isStreaming || isPreparing || isSwitching || controller == null) return; 
    
    setState(() => isSwitching = true);
    
    try {
      final newCamera = cameras.firstWhere(
        (c) => c.name != currentCamera!.name,
        orElse: () => cameras.first,
      );
      currentCamera = newCamera;

      await Future.delayed(const Duration(milliseconds: 400));
      await _setupController();
    } catch (e) {
      debugPrint("Switch error: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => isSwitching = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Note: cleanup happens here if not already called
    super.dispose();
  }

 Widget _buildPreview() {
    final bool isReady = controller?.value.isInitialized ?? false;
    if (!isReady || controller == null || isSwitching) {
        return Container(
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator(color: Colors.white))
        );
    }

    return Center(
        key: ValueKey("preview_${currentCamera!.name}_$userSelectedLandscape"),
          child: CameraPreview(controller!),
    );
  }

  List<Widget> _controlButtons() {
    final bool isReady = controller?.value.isInitialized ?? false;
    final bool lockControls = isStreaming || isPreparing;
    final bool canInteract = !lockControls && !isSwitching && isReady;

    return [
      IconButton(
        onPressed: canInteract ? switchCamera : null,
        icon: isSwitching 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(
              currentCamera?.lensDirection == CameraLensDirection.front ? Icons.camera_front : Icons.camera_rear,
              color: canInteract ? Colors.white : Colors.grey, 
              size: 30,
            ),
      ),
      const SizedBox(width: 25),
      
      IconButton(
        onPressed: canInteract ? _toggleOrientation : null,
        icon: Icon(
          userSelectedLandscape ? Icons.screen_lock_landscape : Icons.screen_lock_portrait,
          color: canInteract ? Colors.blueAccent : Colors.grey,
          size: 30,
        ),
      ),
      const SizedBox(width: 25),

      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isStreaming ? Colors.red : Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: (isStopping || isSwitching || !isReady)
            ? null
            : () async {
                if (!isStreaming) {
                  _isCleaned = false; 
                  await startCountdownFlow();
                } else {
                  // STOP BUTTON LOGIC
                  setState(() => isStopping = true);
                  await _cleanupOnExit();
                  _navToHome(); // Go home, not back
                }
              },
        child: isStopping
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(isStreaming ? "STOP" : "GO LIVE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // SYSTEM BACK BUTTON LOGIC
        setState(() => isStopping = true);
        await _cleanupOnExit();
        _navToHome(); // Go home, not back
        return false; // Prevent the default back action since we handled it
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: _buildPreview()),

            if (isSwitching || isLoading)
              Container(
                color: Colors.black87,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Text(widget.channelName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  if (isStreaming)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                      child: const Text("● LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),

            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.white10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: _controlButtons()),
                ),
              ),
            ),

            if (isPreparing)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Text(
                    "$countdown",
                    style: const TextStyle(color: Colors.white, fontSize: 150, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}