import 'package:cms_app/pages/channel/go_live_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/channel.dart';
import '../../providers/channel_provider.dart';
import 'package:provider/provider.dart';
import 'channel_details_obs_page.dart';

class ChannelDetailsPage extends StatefulWidget {
  final String channelId;

  const ChannelDetailsPage({super.key, required this.channelId});

  @override
  State<ChannelDetailsPage> createState() => _ChannelDetailsPageState();
}

class _ChannelDetailsPageState extends State<ChannelDetailsPage> {
  bool _buttonLoading = false; // <<< Loader state for button

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ChannelProvider>().fetchChannelDetails(widget.channelId);
    });
  }

  void copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied")));
  }

  /// Toggle channel live/stop status
  void toggleChannelStatus(ChannelProvider provider, Channel channel) async {
    setState(() => _buttonLoading = true); // show loader

    try {
      if (channel.status == "live") {
        await provider.stopChannel(channel.channelId);
      } else {
        await provider.startChannel(channel.channelId);
      }
      await provider.fetchChannelDetails(channel.channelId); // refresh
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _buttonLoading = false); // hide loader
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChannelProvider>();
    final channel = provider.selectedChannel;

    return Scaffold(
      appBar: AppBar(title: const Text("Go Live with Any")),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : channel == null
          ? const Center(child: Text("Channel not found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CHANNEL HEADER
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Text(
                  //         channel.name,
                  //         style: const TextStyle(
                  //           fontSize: 22,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //     Container(
                  //       width: 12,
                  //       height: 12,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: channel.status == "live"
                  //             ? Colors.green
                  //             : Colors.orange,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 5),
                  // Text(
                  //   "Status: ${channel.status}",
                  //   style: TextStyle(
                  //     color: channel.status == "live"
                  //         ? Colors.green
                  //         : Colors.orange,
                  //   ),
                  // ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.videocam),
                          label: const Text("Go Live with Camera"),
                          onPressed: () {
                            final streamUrl =
                                "${channel.rtmpUrl}/${channel.streamKey}";
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
                        ),
                      ),

                      // SizedBox(
                      //   child: ElevatedButton.icon(
                      //     icon: _buttonLoading
                      //         ? const SizedBox(
                      //             width: 16,
                      //             height: 16,
                      //             child: CircularProgressIndicator(
                      //               color: Colors.white,
                      //               strokeWidth: 2,
                      //             ),
                      //           )
                      //         : Icon(
                      //             channel.status == "live"
                      //                 ? Icons.stop
                      //                 : Icons.play_arrow,
                      //           ),
                      //     label: _buttonLoading
                      //         ? const Text("Please wait...")
                      //         : Text(
                      //             channel.status == "live"
                      //                 ? "Stop Channel"
                      //                 : "Start Channel",
                      //           ),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: channel.status == "live"
                      //           ? Colors.red
                      //           : Colors.green,
                      //     ),
                      //     onPressed: _buttonLoading
                      //         ? null
                      //         : () => toggleChannelStatus(provider, channel),
                      //   ),
                      // ),
                      /// GO LIVE WITH OBS
                      SizedBox(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cast),
                          label: const Text("Go Live with OBS"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChannelDetailsPageObs(
                                  channelId: channel.channelId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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

  Widget copyTile(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget step(String number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number  $title",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(desc),
        ],
      ),
    );
  }
}
