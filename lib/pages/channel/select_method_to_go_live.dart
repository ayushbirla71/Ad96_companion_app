import 'package:cms_app/models/group.dart';
import 'package:cms_app/pages/channel/go_live_page.dart';
import 'package:cms_app/providers/group_provider.dart';
import 'package:cms_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/channel_provider.dart';
import '../../models/channel.dart';
import 'channel_details_obs_page.dart';

class SelectMethodToGoLive extends StatefulWidget {
  final String channelId;
  final String contentId;
  final List<Group> selectedGroups;

  const SelectMethodToGoLive({
    super.key,
    required this.channelId,
    required this.contentId,
    required this.selectedGroups, // ✅ NEW
  });

  @override
  State<SelectMethodToGoLive> createState() => _SelectMethodToGoLiveState();
}

class _SelectMethodToGoLiveState extends State<SelectMethodToGoLive> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final channelProvider = context.read<ChannelProvider>();
      final groupProvider = context.read<GroupProvider>();

      // ✅ Fetch channel
      channelProvider.fetchChannelDetails(widget.channelId);

      // ✅ Proper date format
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      // ✅ Fetch scheduled groups
      groupProvider.fetchScheduledGroups(
        contentId: widget.contentId, // ⚠️ ensure correct mapping
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

    final payload = {
      "content_type": "live_content",
      "content_id": widget.contentId,
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
          const SnackBar(content: Text("Failed to create schedule")),
        );
        return false;
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Channel Not Active"),
                ],
              ),

              content: const Text(
                "This channel is currently stopped.\n\nYou need to start it before going live.",
                style: TextStyle(height: 1.4),
              ),

              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => loading = true);

                          try {
                            await provider.startChannel(channel.channelId);
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
                              SnackBar(content: Text("Failed to start: $e")),
                            );
                          }
                        },

                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Start Channel"),
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
    // final groups = groupProvider.scheduledGroups;
    final groups = widget.selectedGroups;

    return Scaffold(
      appBar: AppBar(title: const Text("Start Live Streaming")),

      body: channelProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : channelProvider.error != null
          ? Center(child: Text(channelProvider.error!))
          : channel == null
          ? const Center(child: Text("Channel not found"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CHANNEL NAME
                  Text(
                    channel.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// GROUPS TITLE
                  const Text(
                    "Scheduled Groups",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// GROUPS LIST
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: groups.isEmpty
                        ? [const Text("No groups selected")]
                        : groups
                              .map(
                                (g) => Chip(
                                  label: Text(g.name),
                                  avatar: const Icon(Icons.group, size: 18),
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
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.videocam),
                          label: const Text("Go Live with Camera"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GoLivePage(
                                        rtmpUrl: url,
                                        channelName: channel.name,
                                        channelId: widget.channelId,
                                        contentId: widget.contentId,
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
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cast),
                          label: const Text("Go Live with OBS"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
