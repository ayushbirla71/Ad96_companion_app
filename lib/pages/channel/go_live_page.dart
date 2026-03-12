import 'package:flutter/material.dart';
import 'package:rtmp_broadcaster/camera.dart';

class GoLivePage extends StatefulWidget {
  final String rtmpUrl;
  final String channelName;

  const GoLivePage({
    super.key,
    required this.rtmpUrl,
    required this.channelName,
  });

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> {
  CameraController? controller;
  List<CameraDescription> cameras = [];

  bool isStreaming = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        controller = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: true,
          androidUseOpenGL: true,
        );

        await controller!.initialize();
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> startStream() async {
    if (controller == null) return;

    try {
      await controller!.startVideoStreaming(widget.rtmpUrl);

      setState(() {
        isStreaming = true;
      });
    } catch (e) {
      debugPrint("Start stream error: $e");
    }
  }

  Future<void> stopStream() async {
    if (controller == null) return;

    try {
      await controller!.stopVideoStreaming();

      setState(() {
        isStreaming = false;
      });
    } catch (e) {
      debugPrint("Stop stream error: $e");
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2 || controller == null) return;

    final currentCamera = controller!.description;

    final newCamera = cameras.firstWhere(
      (camera) => camera != currentCamera,
    );

    await controller!.dispose();

    controller = CameraController(
      newCamera,
      ResolutionPreset.medium,
      enableAudio: true,
      androidUseOpenGL: true,
    );

    await controller!.initialize();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget liveBadge() {
    if (!isStreaming) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "LIVE",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || controller == null || !(controller!.value.isInitialized ?? false)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: liveBadge()),
          )
        ],
      ),
      body: Column(
        children: [

          /// CAMERA PREVIEW
          Expanded(
            child: CameraPreview(controller!),
          ),

          const SizedBox(height: 20),

          /// CONTROLS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// SWITCH CAMERA
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                iconSize: 36,
                onPressed: switchCamera,
              ),

              const SizedBox(width: 30),

              /// GO LIVE BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isStreaming ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                onPressed: isStreaming ? stopStream : startStream,
                child: Text(
                  isStreaming ? "STOP LIVE" : "GO LIVE",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30)
        ],
      ),
    );
  }
}