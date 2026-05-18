// import 'package:cms_app/pages/channel/go_live_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../models/channel.dart';
// import '../../providers/channel_provider.dart';
// import 'package:provider/provider.dart';

// class ChannelDetailsPageObs extends StatefulWidget {
//   final String channelId;

//   const ChannelDetailsPageObs({super.key, required this.channelId});

//   @override
//   State<ChannelDetailsPageObs> createState() => _ChannelDetailsPageState();
// }

// class _ChannelDetailsPageState extends State<ChannelDetailsPageObs> {
//   bool _buttonLoading = false; // <<< Loader state for button

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       context.read<ChannelProvider>().fetchChannelDetails(widget.channelId);
//     });
//   }

//   void copy(BuildContext context, String text) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("Copied")));
//   }

//   /// Toggle channel live/stop status
//   void toggleChannelStatus(ChannelProvider provider, Channel channel) async {
//     setState(() => _buttonLoading = true); // show loader

//     try {
//       print("channel status.... ${channel.status}");
//       if (channel.status == "live") {
//         await provider.stopChannel(channel.channelId);
//       } else {
//         await provider.startChannel(channel.channelId);
//       }
//       await provider.fetchChannelDetails(channel.channelId); // refresh
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }

//     setState(() => _buttonLoading = false); // hide loader
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<ChannelProvider>();
//     final channel = provider.selectedChannel;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Go Live with OBS")),
//       body: provider.loading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.error != null
//           ? Center(child: Text(provider.error!))
//           : channel == null
//           ? const Center(child: Text("Channel not found"))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// CHANNEL HEADER
//                   // Row(
//                   //   children: [
//                   //     Expanded(
//                   //       child: Text(
//                   //         channel.name,
//                   //         style: const TextStyle(
//                   //           fontSize: 22,
//                   //           fontWeight: FontWeight.bold,
//                   //         ),
//                   //       ),
//                   //     ),
//                   //     Container(
//                   //       width: 12,
//                   //       height: 12,
//                   //       decoration: BoxDecoration(
//                   //         shape: BoxShape.circle,
//                   //         color: channel.status == "live"
//                   //             ? Colors.green
//                   //             : Colors.orange,
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                   // const SizedBox(height: 5),
//                   // Text(
//                   //   "Status: ${channel.status}",
//                   //   style: TextStyle(
//                   //     color: channel.status == "live"
//                   //         ? Colors.green
//                   //         : Colors.orange,
//                   //   ),
//                   // ),
//                   const SizedBox(height: 20),

//                   /// ACTION BUTTONS
//                   // Row(
//                   //   children: [
//                   //     ElevatedButton.icon(
//                   //       icon: const Icon(Icons.videocam),
//                   //       label: const Text("Go Live with Camera"),
//                   //       onPressed: () {
//                   //         final streamUrl =
//                   //             "${channel.rtmpUrl}/${channel.streamKey}";
//                   //         Navigator.push(
//                   //           context,
//                   //           MaterialPageRoute(
//                   //             builder: (_) => GoLivePage(
//                   //               rtmpUrl: streamUrl,
//                   //               channelName: channel.name,
//                   //             ),
//                   //           ),
//                   //         );
//                   //       },
//                   //     ),
//                   //     const SizedBox(width: 10),
//                   //     ElevatedButton.icon(
//                   //       icon: _buttonLoading
//                   //           ? SizedBox(
//                   //               width: 16,
//                   //               height: 16,
//                   //               child: CircularProgressIndicator(
//                   //                 color: Colors.white,
//                   //                 strokeWidth: 2,
//                   //               ),
//                   //             )
//                   //           : Icon(channel.status == "live"
//                   //               ? Icons.stop
//                   //               : Icons.play_arrow),
//                   //       label: _buttonLoading
//                   //           ? const Text("Please wait...")
//                   //           : Text(channel.status == "live"
//                   //               ? "Stop Channel"
//                   //               : "Start Channel"),
//                   //       style: ElevatedButton.styleFrom(
//                   //         backgroundColor: channel.status == "live"
//                   //             ? Colors.red
//                   //             : Colors.green,
//                   //       ),
//                   //       onPressed: _buttonLoading
//                   //           ? null
//                   //           : () => toggleChannelStatus(provider, channel),
//                   //     ),
//                   //   ],
//                   // ),
//                   Wrap(
//                     spacing: 10,
//                     runSpacing: 10,
//                     children: [
//                       // SizedBox(
//                       //   child: ElevatedButton.icon(
//                       //     icon: const Icon(Icons.videocam),
//                       //     label: const Text("Go Live with Camera"),
//                       //     onPressed: () {
//                       //       final streamUrl =
//                       //           "${channel.rtmpUrl}/${channel.streamKey}";
//                       //       Navigator.push(
//                       //         context,
//                       //         MaterialPageRoute(
//                       //           builder: (_) => GoLivePage(
//                       //             rtmpUrl: streamUrl,
//                       //             channelName: channel.name,
//                       //           ),
//                       //         ),
//                       //       );
//                       //     },
//                       //   ),
//                       // ),
//                       SizedBox(
//                         child: ElevatedButton.icon(
//                           icon: _buttonLoading
//                               ? const SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : Icon(
//                                   channel.status == "live"
//                                       ? Icons.stop
//                                       : Icons.play_arrow,
//                                 ),
//                           label: _buttonLoading
//                               ? const Text("Please wait...")
//                               : Text(
//                                   channel.status == "live"
//                                       ? "Stop Channel"
//                                       : "Start Channel",
//                                 ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: channel.status == "live"
//                                 ? Colors.red
//                                 : Colors.green,
//                           ),
//                           onPressed: _buttonLoading
//                               ? null
//                               : () => toggleChannelStatus(provider, channel),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),

//                   /// STREAM CONFIGURATION
//                   const Text(
//                     "Stream Configuration",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   copyTile(context, "Stream URL", channel.playbackUrl),
//                   const SizedBox(height: 10),
//                   infoTile("Created At", channel.createdAt.toString()),
//                   const SizedBox(height: 30),

//                   /// STREAM CREDENTIALS
//                   const Text(
//                     "Your Streaming Credentials",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   copyTile(context, "RTMP Server URL", channel.rtmpUrl),
//                   const SizedBox(height: 10),
//                   copyTile(context, "Stream Key", channel.streamKey),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Never share your stream key. Anyone with this key can stream to your channel.",
//                     style: TextStyle(color: Colors.red),
//                   ),
//                   const SizedBox(height: 30),

//                   /// OBS GUIDE
//                   const Text(
//                     "OBS Studio Setup Guide",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   const Text("Configure OBS to stream to Dacast"),
//                   const SizedBox(height: 20),

//                   /// DOWNLOAD OBS
//                   const Text(
//                     "Download OBS",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   const SelectableText("https://obsproject.com/download"),
//                   const SizedBox(height: 25),

//                   /// STEP-BY-STEP GUIDE
//                   const Text(
//                     "Step-by-Step Setup Instructions",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),
//                   step(
//                     "1",
//                     "Download & Install OBS Studio",
//                     "Download OBS from https://obsproject.com/download",
//                   ),
//                   step(
//                     "2",
//                     "Open OBS Stream Settings",
//                     "Go to Settings → Stream tab.",
//                   ),
//                   step(
//                     "3",
//                     "Configure Stream Service",
//                     "Service: Custom\nServer: Paste RTMP URL\nStream Key: Paste Stream Key",
//                   ),
//                   step(
//                     "4",
//                     "Configure Output Settings",
//                     "Output Mode: Advanced\nEncoder: x264\nRate Control: CBR\nKeyframe Interval: 2",
//                   ),
//                   step(
//                     "5",
//                     "Configure Video Settings",
//                     "Set resolution and FPS.",
//                   ),
//                   step(
//                     "6",
//                     "Add Sources",
//                     "Video Capture Device\nDisplay Capture\nAudio Input\nMedia Source",
//                   ),
//                   step(
//                     "7",
//                     "Start Streaming",
//                     "Click 'Start Streaming' in OBS.",
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Tip: Always test your stream before going live.",
//                     style: TextStyle(fontStyle: FontStyle.italic),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget infoTile(String title, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: const TextStyle(color: Colors.grey)),
//         const SizedBox(height: 4),
//         Text(value),
//       ],
//     );
//   }

//   Widget copyTile(BuildContext context, String title, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 4),
//                 SelectableText(value),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.copy),
//             onPressed: () => copy(context, value),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget step(String number, String title, String desc) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "$number  $title",
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 4),
//           Text(desc),
//         ],
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:cms_app/pages/channel/go_live_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/channel.dart';
import '../../providers/channel_provider.dart';
import '../../theme/app_colors.dart'; // adjust import path as needed
import 'package:provider/provider.dart';

class ChannelDetailsPageObs extends StatefulWidget {
  final String channelId;

  const ChannelDetailsPageObs({super.key, required this.channelId});

  @override
  State<ChannelDetailsPageObs> createState() => _ChannelDetailsPageState();
}

class _ChannelDetailsPageState extends State<ChannelDetailsPageObs> {
  bool _buttonLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ChannelProvider>().fetchChannelDetails(widget.channelId);
    });
  }

  void copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Copied to clipboard"),
        backgroundColor: appColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Toggle channel live/stop status
  void toggleChannelStatus(ChannelProvider provider, Channel channel) async {
    setState(() => _buttonLoading = true);

    try {
      print("channel status.... ${channel.status}");
      if (channel.status == "live") {
        await provider.stopChannel(channel.channelId);
      } else {
        await provider.startChannel(channel.channelId);
      }
      await provider.fetchChannelDetails(channel.channelId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: appColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    setState(() => _buttonLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChannelProvider>();
    final channel = provider.selectedChannel;

    final isLive = channel?.status == "live";

    return Scaffold(
      backgroundColor: appColors.bg,

      appBar: AppBar(
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: appColors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: appColors.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.textSecondary,
              size: 15,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),

        titleSpacing: 16,

        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.cast_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Go Live with OBS',
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),

      body: provider.loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      color: appColors.accent,
                      strokeWidth: 2.5,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading channel…',
                    style: TextStyle(color: appColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          : provider.error != null
          ? Center(
              child: Text(
                provider.error!,
                style: TextStyle(color: appColors.red, fontSize: 13),
              ),
            )
          : channel == null
          ? Center(
              child: Text(
                "Channel not found",
                style: TextStyle(color: appColors.textMuted, fontSize: 13),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CHANNEL STATUS BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: _buttonLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isLive
                                  ? Icons.stop_rounded
                                  : Icons.play_arrow_rounded,
                              size: 18,
                            ),
                      label: _buttonLoading
                          ? const Text("Please wait...")
                          : Text(isLive ? "Stop Channel" : "Start Channel"),
                      style: FilledButton.styleFrom(
                        backgroundColor: isLive
                            ? appColors.red
                            : appColors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            (isLive ? appColors.red : appColors.green)
                                .withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: _buttonLoading
                          ? null
                          : () => toggleChannelStatus(provider, channel),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// STREAM CONFIGURATION
                  _sectionLabel('Stream Configuration'),
                  const SizedBox(height: 10),
                  copyTile(context, "Stream URL", channel.playbackUrl),
                  const SizedBox(height: 10),
                  infoTile("Created At", channel.createdAt.toString()),

                  const SizedBox(height: 20),

                  /// STREAM CREDENTIALS
                  _sectionLabel('Your Streaming Credentials'),
                  const SizedBox(height: 10),
                  copyTile(context, "RTMP Server URL", channel.rtmpUrl),
                  const SizedBox(height: 10),
                  copyTile(context, "Stream Key", channel.streamKey),
                  const SizedBox(height: 10),

                  /// WARNING
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appColors.redLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appColors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: appColors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Never share your stream key. Anyone with this key can stream to your channel.",
                            style: TextStyle(
                              color: appColors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// OBS GUIDE HEADER
                  _sectionLabel('OBS Studio Setup Guide'),
                  const SizedBox(height: 4),
                  Text(
                    "Configure OBS to stream to Dacast",
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// DOWNLOAD OBS
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: appColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: appColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: appColors.accentLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            color: appColors.accent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Download OBS",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: appColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              SelectableText(
                                "https://obsproject.com/download",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// STEP-BY-STEP GUIDE
                  _sectionLabel('Step-by-Step Setup Instructions'),
                  const SizedBox(height: 16),

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
                    isLast: true,
                  ),

                  const SizedBox(height: 16),

                  /// TIP
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appColors.yellowLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appColors.yellow.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: appColors.yellow,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Tip: Always test your stream before going live.",
                            style: TextStyle(
                              color: appColors.yellow,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
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

  // ─── Section Label ───────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: appColors.textPrimary,
      letterSpacing: -0.2,
    ),
  );

  // ─── Info Tile ───────────────────────────────────────────────────────────

  Widget infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appColors.border),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: appColors.textMuted,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: appColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: appColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Copy Tile ───────────────────────────────────────────────────────────

  Widget copyTile(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appColors.border),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: appColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => copy(context, value),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: appColors.accentLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: appColors.accent.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.copy_rounded,
                color: appColors.accent,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step ────────────────────────────────────────────────────────────────

  Widget step(String number, String title, String desc, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: appColors.border),
          boxShadow: [
            BoxShadow(
              color: appColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: appColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    color: appColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: appColors.textSecondary,
                      height: 1.5,
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
