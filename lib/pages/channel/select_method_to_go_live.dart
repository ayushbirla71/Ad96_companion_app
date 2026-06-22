// import 'package:cms_app/models/group.dart';
// import 'package:cms_app/pages/channel/go_live_page.dart';
// import 'package:cms_app/providers/group_provider.dart';
// import 'package:cms_app/services/api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// import '../../providers/channel_provider.dart';
// import '../../models/channel.dart';
// import 'channel_details_obs_page.dart';

// class SelectMethodToGoLive extends StatefulWidget {
//   final String channelId;
//   final String contentId;
//   final List<Group> selectedGroups;

//   const SelectMethodToGoLive({
//     super.key,
//     required this.channelId,
//     required this.contentId,
//     required this.selectedGroups, // ✅ NEW
//   });

//   @override
//   State<SelectMethodToGoLive> createState() => _SelectMethodToGoLiveState();
// }

// class _SelectMethodToGoLiveState extends State<SelectMethodToGoLive> {
//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() {
//       final channelProvider = context.read<ChannelProvider>();
//       final groupProvider = context.read<GroupProvider>();

//       // ✅ Fetch channel
//       channelProvider.fetchChannelDetails(widget.channelId);

//       // ✅ Proper date format
//       final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

//       // ✅ Fetch scheduled groups
//       groupProvider.fetchScheduledGroups(
//         contentId: widget.contentId, // ⚠️ ensure correct mapping
//         contentType: "live_content",
//         startDate: today,
//         endDate: today,
//       );
//     });
//   }

//   bool creatingSchedule = false;

//   Future<bool> createSchedule() async {
//     setState(() => creatingSchedule = true);

//     final now = DateTime.now();

//     final start = DateTime(now.year, now.month, now.day, 0, 0);
//     final end = DateTime(now.year, now.month, now.day, 23, 59);
//     final groupIds = widget.selectedGroups.map((g) => g.id).toList();

//     final payload = {
//       "content_type": "live_content",
//       "content_id": widget.contentId,
//       "groups": groupIds,
//       "start_time": start.toIso8601String(),
//       "end_time": end.toIso8601String(),
//       "total_duration": "360",
//       "priority": 1,
//     };

//     print("payload.,.,... ${payload}");

//     try {
//       final res = await ApiService.post("/schedule/add_v2", payload);

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         return true;
//       } else {
//         print(res.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to create schedule")),
//         );
//         return false;
//       }
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
//       return false;
//     } finally {
//       setState(() => creatingSchedule = false);
//     }
//   }

//   Future<bool> ensureChannelIsLive(Channel channel) async {
//     final provider = context.read<ChannelProvider>();

//     /// ✅ Already live
//     if (channel.status == "live") return true;

//     final result = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         bool loading = false;

//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               title: Row(
//                 children: const [
//                   Icon(Icons.warning_amber_rounded, color: Colors.orange),
//                   SizedBox(width: 8),
//                   Text("Channel Not Active"),
//                 ],
//               ),

//               content: const Text(
//                 "This channel is currently stopped.\n\nYou need to start it before going live.",
//                 style: TextStyle(height: 1.4),
//               ),

//               actionsPadding: const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 8,
//               ),

//               actions: [
//                 TextButton(
//                   onPressed: loading
//                       ? null
//                       : () => Navigator.pop(dialogContext, false),
//                   child: const Text("Cancel"),
//                 ),

//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 10,
//                     ),
//                   ),
//                   onPressed: loading
//                       ? null
//                       : () async {
//                           setState(() => loading = true);

//                           try {
//                             await provider.startChannel(channel.channelId);
//                             await provider.fetchChannelDetails(
//                               channel.channelId,
//                             );

//                             if (dialogContext.mounted) {
//                               Navigator.pop(dialogContext, true);
//                             }
//                           } catch (e) {
//                             if (dialogContext.mounted) {
//                               Navigator.pop(dialogContext, false);
//                             }

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Failed to start: $e")),
//                             );
//                           }
//                         },

//                   child: loading
//                       ? const SizedBox(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text("Start Channel"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     return result == true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final channelProvider = context.watch<ChannelProvider>();
//     final groupProvider = context.watch<GroupProvider>();

//     final channel = channelProvider.selectedChannel;
//     // final groups = groupProvider.scheduledGroups;
//     final groups = widget.selectedGroups;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Start Live Streaming")),

//       body: channelProvider.loading
//           ? const Center(child: CircularProgressIndicator())
//           : channelProvider.error != null
//           ? Center(child: Text(channelProvider.error!))
//           : channel == null
//           ? const Center(child: Text("Channel not found"))
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// CHANNEL NAME
//                   Text(
//                     channel.name,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// GROUPS TITLE
//                   const Text(
//                     "Scheduled Groups",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 10),

//                   /// GROUPS LIST
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: groups.isEmpty
//                         ? [const Text("No groups selected")]
//                         : groups
//                               .map(
//                                 (g) => Chip(
//                                   label: Text(g.name),
//                                   avatar: const Icon(Icons.group, size: 18),
//                                 ),
//                               )
//                               .toList(),
//                   ),

//                   const Spacer(),

//                   /// ACTION BUTTONS
//                   Column(
//                     children: [
//                       /// CAMERA BUTTON
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.videocam),
//                           label: const Text("Go Live with Camera"),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           onPressed: creatingSchedule
//                               ? null
//                               : () async {
//                                   /// ✅ Ensure channel is live FIRST
//                                   final isReady = await ensureChannelIsLive(
//                                     channel,
//                                   );
//                                   if (!isReady) return;

//                                   /// ✅ Create schedule
//                                   final success = await createSchedule();
//                                   if (!success) return;

//                                   final url =
//                                       "${channel.rtmpUrl}/${channel.streamKey}";

//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => GoLivePage(
//                                         rtmpUrl: url,
//                                         channelName: channel.name,
//                                         channelId: widget.channelId,
//                                         contentId: widget.contentId,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       /// OBS BUTTON
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.cast),
//                           label: const Text("Go Live with OBS"),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade900,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           onPressed: () async {
//                             final isReady = await ensureChannelIsLive(channel);
//                             if (!isReady) return;

//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => ChannelDetailsPageObs(
//                                   channelId: channel.channelId,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<< NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>

import 'package:cms_app/models/group.dart';
import 'package:cms_app/pages/channel/go_live_page.dart';
import 'package:cms_app/providers/group_provider.dart';
import 'package:cms_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/channel_provider.dart';
import '../../models/channel.dart';
import '../../theme/app_colors.dart'; // adjust import path as needed
import 'channel_details_obs_page.dart';

class SelectMethodToGoLive extends StatefulWidget {
  final String channelId;
  final String contentId;
  final List<Group> selectedGroups;
  final String? layoutId;

  const SelectMethodToGoLive({
    super.key,
    required this.channelId,
    required this.contentId,
    required this.selectedGroups,
    this.layoutId,
  });

  @override
  State<SelectMethodToGoLive> createState() => _SelectMethodToGoLiveState();
}

class _SelectMethodToGoLiveState extends State<SelectMethodToGoLive> {
  @override
  void initState() {
    super.initState();

    print("Received Layout ID: ${widget.layoutId}");

    Future.microtask(() {
      final channelProvider = context.read<ChannelProvider>();
      final groupProvider = context.read<GroupProvider>();

      // ✅ Fetch channel
      channelProvider.fetchChannelDetails(widget.channelId);

      // ✅ Proper date format
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      // ✅ Fetch scheduled groups
      groupProvider.fetchScheduledGroups(
        contentId: widget.contentId,
        contentType: "live_content",
        startDate: today,
        endDate: today,
      );
    });
  }

  bool creatingSchedule = false;

  Future<bool> createSchedule() async {
    setState(() => creatingSchedule = true);

    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day, 0, 0);
    final end = DateTime(now.year, now.month, now.day, 23, 59);
    final groupIds = widget.selectedGroups.map((g) => g.id).toList();
    final bool hasLayout = widget.layoutId != null;
    final payload = {
      // "content_type": "live_content",
      // "content_id": widget.contentId,
      "content_type": hasLayout ? "layout" : "live_content",
      "content_id": hasLayout ? widget.layoutId : widget.contentId,
      "groups": groupIds,
      "start_time": start.toIso8601String(),
      "end_time": end.toIso8601String(),
      "total_duration": "360",
      "priority": 1,
    };

    print("payload.,.,... ${payload}");

    try {
      final res = await ApiService.post("/schedule/add_v2", payload);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        print(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to create schedule"),
            backgroundColor: appColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return false;
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Something went wrong"),
          backgroundColor: appColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return false;
    } finally {
      setState(() => creatingSchedule = false);
    }
  }

  Future<bool> ensureChannelIsLive(Channel channel) async {
    final provider = context.read<ChannelProvider>();

    /// ✅ Already live
    if (channel.status == "live") return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool loading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: appColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: appColors.orangeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: appColors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Channel Not Active",
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              content: Text(
                "This channel is currently stopped.\n\nYou need to start it before going live.",
                style: TextStyle(
                  color: appColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: loading
                            ? null
                            : () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: appColors.textSecondary,
                          side: BorderSide(color: appColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: appColors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: appColors.green.withOpacity(
                            0.6,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() => loading = true);

                                try {
                                  await provider.startChannel(
                                    channel.channelId,
                                  );
                                  await provider.fetchChannelDetails(
                                    channel.channelId,
                                  );

                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext, true);
                                  }
                                } catch (e) {
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext, false);
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Failed to start: $e"),
                                      backgroundColor: appColors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: loading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow_rounded, size: 16),
                        label: loading
                            ? const Text("Starting…")
                            : const Text("Start Channel"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final channelProvider = context.watch<ChannelProvider>();
    final groupProvider = context.watch<GroupProvider>();

    final channel = channelProvider.selectedChannel;
    final groups = widget.selectedGroups;

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
                  colors: [appColors.red, const Color(0xFFB91C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.live_tv_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Start Live Streaming',
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

      body: channelProvider.loading
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
          : channelProvider.error != null
          ? Center(
              child: Text(
                channelProvider.error!,
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
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CHANNEL CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appColors.red, const Color(0xFFB91C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.red.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.live_tv_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                channel.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      channel.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// GROUPS TITLE
                  Row(
                    children: [
                      Text(
                        "Scheduled Groups",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: appColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: appColors.accentLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${groups.length}',
                          style: TextStyle(
                            color: appColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// GROUPS LIST
                  groups.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: appColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: appColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.group_off_rounded,
                                color: appColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "No groups selected",
                                style: TextStyle(
                                  color: appColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: groups
                              .map(
                                (g) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appColors.accentLight,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: appColors.accent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.group_rounded,
                                        size: 13,
                                        color: appColors.accent,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        g.name,
                                        style: TextStyle(
                                          color: appColors.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                  const Spacer(),

                  /// ACTION BUTTONS
                  Column(
                    children: [
                      /// CAMERA BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.videocam_rounded, size: 18),
                          label: const Text("Go Live with Camera"),
                          style: FilledButton.styleFrom(
                            backgroundColor: appColors.accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: appColors.accent
                                .withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: creatingSchedule
                              ? null
                              : () async {
                                  /// ✅ Ensure channel is live FIRST
                                  final isReady = await ensureChannelIsLive(
                                    channel,
                                  );
                                  if (!isReady) return;

                                  /// ✅ Create schedule
                                  final success = await createSchedule();
                                  if (!success) return;

                                  final url =
                                      "${channel.rtmpUrl}/${channel.streamKey}";
                                  final bool hasLayout =
                                      widget.layoutId != null;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GoLivePage(
                                        rtmpUrl: url,
                                        channelName: channel.name,
                                        channelId: widget.channelId,
                                        // contentId: widget.contentId,
                                        contentId: hasLayout
                                            ? widget.layoutId!
                                            : widget.contentId,
                                        contentType: hasLayout
                                            ? "layout"
                                            : "live_content",
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// OBS BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.cast_rounded, size: 18),
                          label: const Text("Go Live with OBS"),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () async {
                            final isReady = await ensureChannelIsLive(channel);
                            if (!isReady) return;

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
                ],
              ),
            ),
    );
  }
}
