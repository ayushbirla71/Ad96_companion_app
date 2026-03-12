
import 'package:cms_app/pages/channel/go_live_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/channel.dart';

class ChannelDetailsPage extends StatelessWidget {
  final Channel channel;

  const ChannelDetailsPage({
    super.key,
    required this.channel,
  });

  void copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Copied")));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dacast Channel"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// CHANNEL HEADER
            Text(
              channel.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              channel.status,
              style: TextStyle(
                color: channel.status == "live"
                    ? Colors.green
                    : Colors.orange,
              ),
            ),

            const SizedBox(height: 20),

            /// GO LIVE BUTTONS
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Go Live"),
                ),
                const SizedBox(width: 10),
               ElevatedButton(
  onPressed: () {

    final streamUrl = "${channel.rtmpUrl}/${channel.streamKey}";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoLivePage(
          rtmpUrl: streamUrl,
          channelName: channel.name,
        ),
      ),
    );

  },
  child: const Text("Go Live"),
)
              ],
            ),

            const SizedBox(height: 30),

            /// STREAM CONFIGURATION
            const Text(
              "Stream Configuration",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            copyTile(
              context,
              "Stream URL",
              channel.playbackUrl,
            ),

            const SizedBox(height: 10),

            infoTile(
              "Created At",
              channel.createdAt.toString(),
            ),

            const SizedBox(height: 30),

            /// OBS GUIDE
            const Text(
              "OBS Studio Setup Guide",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text("Configure OBS to stream to Dacast"),

            const SizedBox(height: 20),

            /// DOWNLOAD OBS
            const Text(
              "Download OBS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const SelectableText(
              "https://obsproject.com/download",
            ),

            const SizedBox(height: 25),

            /// STREAM CREDENTIALS
            const Text(
              "Your Streaming Credentials",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            copyTile(
              context,
              "RTMP Server URL",
              channel.rtmpUrl,
            ),

            const SizedBox(height: 10),

            copyTile(
              context,
              "Stream Key",
              channel.streamKey,
            ),

            const SizedBox(height: 10),

            const Text(
              "Never share your stream key. Anyone with this key can stream to your channel.",
              style: TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 30),

            /// STEP GUIDE
            const Text(
              "Step-by-Step Setup Instructions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            step(
              "1",
              "Download & Install OBS Studio",
              "Download OBS from https://obsproject.com/download",
            ),

            step(
              "2",
              "Open OBS Stream Settings",
              "Go to Settings → Stream tab.",
            ),

            step(
              "3",
              "Configure Stream Service",
              "Service: Custom\nServer: Paste RTMP URL\nStream Key: Paste Stream Key",
            ),

            step(
              "4",
              "Configure Output Settings",
              "Output Mode: Advanced\nEncoder: x264\nRate Control: CBR\nKeyframe Interval: 2",
            ),

            step(
              "5",
              "Configure Video Settings",
              "Set resolution and FPS.",
            ),

            step(
              "6",
              "Add Sources",
              "Video Capture Device\nDisplay Capture\nAudio Input\nMedia Source",
            ),

            step(
              "7",
              "Start Streaming",
              "Click 'Start Streaming' in OBS.",
            ),

            const SizedBox(height: 20),

            const Text(
              "Tip: Always test your stream before going live.",
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  Widget copyTile(
    BuildContext context,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                SelectableText(value),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => copy(context, value),
          ),
        ],
      ),
    );
  }

  Widget step(
    String number,
    String title,
    String desc,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "$number  $title",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(desc),
        ],
      ),
    );
  }
}
