import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewPopup extends StatefulWidget {
  final String url;

  const PreviewPopup({
    super.key,
    required this.url,
  });

  @override
  State<PreviewPopup> createState() => _PreviewPopupState();
}

class _PreviewPopupState extends State<PreviewPopup> {
  VideoPlayerController? controller;

  bool loading = true;

  bool get isVideo {
    final cleanUrl = widget.url.split("?")[0];

    return RegExp(r'\.(mp4|webm|ogg)$', caseSensitive: false)
        .hasMatch(cleanUrl);
  }

  bool get isImage {
    final cleanUrl = widget.url.split("?")[0];

    return RegExp(r'\.(jpeg|jpg|png|gif|webp)$',
            caseSensitive: false)
        .hasMatch(cleanUrl);
  }

  @override
  void initState() {
    super.initState();

    initVideo();
  }

  Future<void> initVideo() async {
    if (!isVideo) {
      setState(() {
        loading = false;
      });

      return;
    }

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

    await controller!.initialize();

    await controller!.play();

    controller!.setLooping(true);

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxWidth: 900,
            maxHeight: 700,
          ),

          decoration: BoxDecoration(
            color: Colors.black,

            borderRadius: BorderRadius.circular(24),
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),

            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )

                /// VIDEO
                : isVideo
                ? AspectRatio(
                    aspectRatio:
                        controller!.value.aspectRatio,

                    child: VideoPlayer(controller!),
                  )

                /// IMAGE
                : isImage
                ? InteractiveViewer(
                    child: Image.network(
                      widget.url,
                      fit: BoxFit.contain,
                    ),
                  )

                /// NO PREVIEW
                : const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.image_not_supported_rounded,
                          color: Colors.white,
                          size: 60,
                        ),

                        SizedBox(height: 16),

                        Text(
                          "Preview not available",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),

        /// CLOSE BUTTON
        Positioned(
          top: 12,
          right: 12,

          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },

            borderRadius: BorderRadius.circular(30),

            child: Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}