









// ///////////////////////////////////
// ///
// ///
// import 'package:cms_app/pages/home/home_page.dart';
// import 'package:cms_app/providers/live_content_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
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
  
//   bool userSelectedLandscape = false;
//   int countdown = 3;
//   late LiveContentProvider liveProvider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     liveProvider = Provider.of<LiveContentProvider>(context, listen: false);
//     initCamera();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
//       _cleanupOnExit();
//     }
//   }

//   Future<void> initCamera() async {
//     try {
//       cameras = await availableCameras();
//       if (cameras.isEmpty) throw Exception("No camera found");
//       if (_isCleaned || !mounted) return;

//       currentCamera = cameras.first;
//       await _setupController();
//     } catch (e) {
//       debugPrint("Init Camera Error: $e");
//     } finally {
//       if (mounted && !_isCleaned) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   Future<void> _setupController() async {
//     if (controller != null) {
//       final oldController = controller;
//       controller = null; 
//       if (mounted) setState(() {}); 
//       await oldController!.dispose();
//     }

//     if (_isCleaned || !mounted) return;

//     final newController = CameraController(
//       ResolutionPreset.medium,// or veryHigh / ultraHigh
//       enableAudio: true,
//       androidUseOpenGL: true,
//     );

//     try {
//       await newController.initialize(currentCamera!);
//       if (mounted && !_isCleaned) {
//         setState(() {
//           controller = newController;
//         });
//       }
//     } catch (e) {
//       debugPrint("Setup Controller Error: $e");
//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted && !_isCleaned) initCamera();
//     }
//   }

//  Future<void> _toggleOrientation() async {
//     if (isStreaming || isPreparing || isSwitching) return;

//     setState(() {
//       isSwitching = true;
//       userSelectedLandscape = !userSelectedLandscape;
//     });

//     try {
//       if (userSelectedLandscape) {
//         await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
//       } else {
//         await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//       }
      
//       // Increased delay: Gives the OS memory time to allocate the flipped high-res buffer
//       await Future.delayed(const Duration(milliseconds: 600)); 
//       await _setupController();
//     } finally {
//       if (mounted) setState(() => isSwitching = false);
//     }
//   }

//   /// Navigates to Home and clears navigation stack
//   void _navToHome() {
//     if (!mounted) return;
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const HomePage()),
//       (route) => false,
//     );
//   }

//   Future<void> _cleanupOnExit() async {
//     if (_isCleaned) return;
//     _isCleaned = true; 

//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);

//     try {
//       if (controller != null) {
//         if (isStreaming) {
//           await controller!.stopVideoStreaming();
//         }
//         await controller!.dispose();
//         controller = null; 
//       }
//       await WakelockPlus.disable();
//        liveProvider.deleteSchedules(widget.contentId);
//     } catch (e) {
//       debugPrint("Cleanup error: $e");
//     } finally {
//       if (mounted) {
//         setState(() {
//           isStreaming = false;
//           isPreparing = false;
//           isStopping = false;
//         });
//       }
//     }
//   }

//   Future<void> startCountdownFlow() async {
//     final bool isReady = controller?.value.isInitialized ?? false;
//     if (_isCleaned || !mounted || !isReady) return;

//     final provider = context.read<ChannelProvider>();
//     try {
//       setState(() => isPreparing = true);
      
//       final channel = provider.selectedChannel;
//       if (channel != null && channel.status != "live") {
//         await provider.startChannel(channel.channelId);
//       }

//       for (int i = 3; i > 0; i--) {
//         if (!mounted || _isCleaned || !isPreparing) return; 
//         setState(() => countdown = i);
//         await Future.delayed(const Duration(seconds: 1));
//       }

//       if (mounted && !_isCleaned && isPreparing) {
//         await startStream();
//       }
//     } catch (e) {
//       if (mounted) setState(() => isPreparing = false);
//     }
//   }

//   Future<void> startStream() async {
//     final bool isReady = controller?.value.isInitialized ?? false;
//     if (!isReady || _isCleaned || controller == null) return;

//     try {
//       await controller!.startVideoStreaming(widget.rtmpUrl);
//       await WakelockPlus.enable();
//       if (mounted) {
//         setState(() {
//           isStreaming = true;
//           isPreparing = false; 
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() => isPreparing = false);
//     }
//   }

//   Future<void> switchCamera() async {
//     if (isStreaming || isPreparing || isSwitching || controller == null) return; 
    
//     setState(() => isSwitching = true);
    
//     try {
//       final newCamera = cameras.firstWhere(
//         (c) => c.name != currentCamera!.name,
//         orElse: () => cameras.first,
//       );
//       currentCamera = newCamera;

//       await Future.delayed(const Duration(milliseconds: 400));
//       await _setupController();
//     } catch (e) {
//       debugPrint("Switch error: $e");
//     } finally {
//       await Future.delayed(const Duration(milliseconds: 600));
//       if (mounted) setState(() => isSwitching = false);
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     // Note: cleanup happens here if not already called
//     super.dispose();
//   }

//  Widget _buildPreview() {
//     final bool isReady = controller?.value.isInitialized ?? false;
//     if (!isReady || controller == null || isSwitching) {
//         return Container(
//             color: Colors.black,
//             child: const Center(child: CircularProgressIndicator(color: Colors.white))
//         );
//     }

//     return Center(
//         key: ValueKey("preview_${currentCamera!.name}_$userSelectedLandscape"),
//           child: CameraPreview(controller!),
//     );
//   }

//   List<Widget> _controlButtons() {
//     final bool isReady = controller?.value.isInitialized ?? false;
//     final bool lockControls = isStreaming || isPreparing;
//     final bool canInteract = !lockControls && !isSwitching && isReady;

//     return [
//       IconButton(
//         onPressed: canInteract ? switchCamera : null,
//         icon: isSwitching 
//           ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//           : Icon(
//               currentCamera?.lensDirection == CameraLensDirection.front ? Icons.camera_front : Icons.camera_rear,
//               color: canInteract ? Colors.white : Colors.grey, 
//               size: 30,
//             ),
//       ),
//       const SizedBox(width: 25),
      
//       IconButton(
//         onPressed: canInteract ? _toggleOrientation : null,
//         icon: Icon(
//           userSelectedLandscape ? Icons.screen_lock_landscape : Icons.screen_lock_portrait,
//           color: canInteract ? Colors.blueAccent : Colors.grey,
//           size: 30,
//         ),
//       ),
//       const SizedBox(width: 25),

//       ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isStreaming ? Colors.red : Colors.green,
//           padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         ),
//         onPressed: (isStopping || isSwitching || !isReady)
//             ? null
//             : () async {
//                 if (!isStreaming) {
//                   _isCleaned = false; 
//                   await startCountdownFlow();
//                 } else {
//                   // STOP BUTTON LOGIC
//                   setState(() => isStopping = true);
//                   await _cleanupOnExit();
//                   _navToHome(); // Go home, not back
//                 }
//               },
//         child: isStopping
//             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//             : Text(isStreaming ? "STOP" : "GO LIVE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // SYSTEM BACK BUTTON LOGIC
//         setState(() => isStopping = true);
//         await _cleanupOnExit();
//         _navToHome(); // Go home, not back
//         return false; // Prevent the default back action since we handled it
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             Positioned.fill(child: _buildPreview()),

//             if (isSwitching || isLoading)
//               Container(
//                 color: Colors.black87,
//                 child: const Center(
//                   child: CircularProgressIndicator(color: Colors.white),
//                 ),
//               ),

//             Positioned(
//               top: 50,
//               left: 20,
//               right: 20,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
//                     child: Text(widget.channelName, style: const TextStyle(color: Colors.white, fontSize: 14)),
//                   ),
//                   if (isStreaming)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
//                       child: const Text("● LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                     ),
//                 ],
//               ),
//             ),

//             Positioned(
//               bottom: 40,
//               left: 20,
//               right: 20,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.white10)),
//                   child: Row(mainAxisSize: MainAxisSize.min, children: _controlButtons()),
//                 ),
//               ),
//             ),

//             if (isPreparing)
//               Container(
//                 color: Colors.black87,
//                 child: Center(
//                   child: Text(
//                     "$countdown",
//                     style: const TextStyle(color: Colors.white, fontSize: 150, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';

import 'package:cms_app/pages/home/home_page.dart';
import 'package:cms_app/providers/live_content_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

class _GoLivePageState extends State<GoLivePage>
    with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel("rtmp_stream");

  bool isStreaming = false;
  bool isLoading = true;
  bool isStopping = false;
  bool isPreparing = false;
  bool isSwitching = false;
  bool isCleaned = false;

  bool userSelectedLandscape = false;
  int countdown = 3;

  late LiveContentProvider liveProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    liveProvider =
        Provider.of<LiveContentProvider>(context, listen: false);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cleanupOnExit();
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
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }

      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() => isSwitching = false);
      }
    }
  }

  Future<void> switchCamera() async {
    if (isStreaming || isPreparing || isSwitching) return;

    try {
      setState(() => isSwitching = true);

      await _channel.invokeMethod("switchCamera");

      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      debugPrint("Switch camera error: $e");
    } finally {
      if (mounted) {
        setState(() => isSwitching = false);
      }
    }
  }

  Future<void> startStream() async {
    try {
      await _channel.invokeMethod("startStream", {
        "url": widget.rtmpUrl,
      });

      await WakelockPlus.enable();

      if (mounted) {
        setState(() {
          isStreaming = true;
          isPreparing = false;
        });
      }
    } catch (e) {
      debugPrint("Start stream error: $e");

      if (mounted) {
        setState(() => isPreparing = false);
      }
    }
  }

  Future<void> stopStream() async {
    try {
      await _channel.invokeMethod("stopStream");
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint("Stop stream error: $e");
    }
  }

  Future<void> startCountdownFlow() async {
    if (!mounted || isCleaned) return;

    final provider = context.read<ChannelProvider>();

    try {
      setState(() => isPreparing = true);

      final channel = provider.selectedChannel;

      if (channel != null && channel.status != "live") {
        await provider.startChannel(channel.channelId);
      }

      for (int i = 3; i > 0; i--) {
        if (!mounted || isCleaned || !isPreparing) return;

        setState(() => countdown = i);

        await Future.delayed(const Duration(seconds: 1));
      }

      if (mounted && !isCleaned) {
        await startStream();
      }
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        setState(() => isPreparing = false);
      }
    }
  }

  Future<void> _cleanupOnExit() async {
    if (isCleaned) return;

    isCleaned = true;

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    try {
      if (isStreaming) {
        await stopStream();
      }

      await liveProvider.deleteSchedules(widget.contentId);
    } catch (e) {
      debugPrint("cleanup error: $e");
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

  void _navToHome() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildPreview() {
    if (isLoading || isSwitching) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (Platform.isAndroid) {
      return const AndroidView(
        viewType: "rtmp_camera_view",
      );
    }

    if (Platform.isIOS) {
      return const UiKitView(
        viewType: "rtmp_camera_view",
      );
    }

    return const SizedBox();
  }

  List<Widget> _controlButtons() {
    final lockControls = isStreaming || isPreparing;
    final canInteract = !lockControls && !isSwitching;

    return [
      IconButton(
        onPressed: canInteract ? switchCamera : null,
        icon: isSwitching
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.cameraswitch,
                color: canInteract
                    ? Colors.white
                    : Colors.grey,
                size: 30,
              ),
      ),

      const SizedBox(width: 25),

      IconButton(
        onPressed: canInteract ? _toggleOrientation : null,
        icon: Icon(
          userSelectedLandscape
              ? Icons.screen_lock_landscape
              : Icons.screen_lock_portrait,
          color: canInteract
              ? Colors.blueAccent
              : Colors.grey,
          size: 30,
        ),
      ),

      const SizedBox(width: 25),

      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isStreaming ? Colors.red : Colors.green,
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: isStopping || isSwitching
            ? null
            : () async {
                if (!isStreaming) {
                  isCleaned = false;
                  await startCountdownFlow();
                } else {
                  setState(() => isStopping = true);

                  await _cleanupOnExit();
                  _navToHome();
                }
              },
        child: isStopping
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                isStreaming ? "STOP" : "GO LIVE",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() => isStopping = true);

        await _cleanupOnExit();
        _navToHome();

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildPreview(),
            ),

            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.channelName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  if (isStreaming)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "● LIVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
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
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius:
                        BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white10,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _controlButtons(),
                  ),
                ),
              ),
            ),

            if (isPreparing)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Text(
                    "$countdown",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 150,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}