import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../models/ad.dart';
import '../../providers/ad_provider.dart';

class AdDetailsPage extends StatelessWidget {
  final Ad ad;

  const AdDetailsPage({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ad.name),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.edit),
        //     onPressed: () {
        //       // TODO: Navigate to Edit Ad Page
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.delete),
        //     onPressed: () => _confirmDelete(context),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Preview Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Preview",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    AdPreview(url: ad.url),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Details Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row("Ad Name", ad.name),
                    _row("Duration", "${ad.duration} sec"),
                    _row("Status", ad.status.toUpperCase()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Ad"),
        content: const Text("Are you sure you want to delete this ad?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteAd(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAd(BuildContext context) {
    final provider = context.read<AdProvider>();
    provider.ads.removeWhere((a) => a.adId == ad.adId);
    provider.notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ad deleted")),
    );
    Navigator.pop(context);
  }
}

/// --------------------
/// Widget to Preview Images or Videos
/// --------------------
class AdPreview extends StatefulWidget {
  final String? url;

  const AdPreview({super.key, this.url});

  @override
  State<AdPreview> createState() => _AdPreviewState();
}

class _AdPreviewState extends State<AdPreview> {
  VideoPlayerController? _videoController;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();

    if (widget.url != null) {
      _isVideo = isVideo(widget.url!);
      if (_isVideo) {
        _videoController = VideoPlayerController.network(widget.url!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.setLooping(true);
          });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null) return _placeholder();

    if (_isVideo) {
      if (_videoController == null || !_videoController!.value.isInitialized) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            _videoController!.value.isPlaying
                ? _videoController!.pause()
                : _videoController!.play();
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    } else if (isImage(widget.url!)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.url!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    } else {
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50),
      ),
    );
  }

  bool isVideo(String url) {
    try {
      final path = Uri.parse(url).path.toLowerCase();
      return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.webm');
    } catch (e) {
      return false;
    }
  }

  bool isImage(String url) {
    try {
      final path = Uri.parse(url).path.toLowerCase();
      return path.endsWith('.jpeg') ||
          path.endsWith('.jpg') ||
          path.endsWith('.png') ||
          path.endsWith('.gif');
    } catch (e) {
      return false;
    }
  }
}
