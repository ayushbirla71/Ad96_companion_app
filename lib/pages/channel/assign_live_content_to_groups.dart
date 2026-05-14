// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cms_app/services/api_service.dart';

// import '../../providers/live_content_provider.dart';
// import '../../providers/group_provider.dart';
// import '../../models/group.dart';
// import '../../models/liveContent.dart';

// import 'select_method_to_go_live.dart';

// class AssignLiveContentToGroups extends StatefulWidget {
//   const AssignLiveContentToGroups({super.key});

//   @override
//   State<AssignLiveContentToGroups> createState() =>
//       _AssignLiveContentToGroupsState();
// }

// class _AssignLiveContentToGroupsState extends State<AssignLiveContentToGroups> {
//   Set<String> selectedGroupIds = {};
//   String searchText = "";

//   DateTime selectedDate = DateTime.now();
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;

//   LiveContent? providerContent;

//   bool loading = true;
//   bool submitting = false;

//   @override
//   void initState() {
//     super.initState();
//     initData();
//   }

//   /// INIT DATA
//   Future<void> initData() async {
//     try {
//       final contentProvider = context.read<LiveContentProvider>();
//       final groupProvider = context.read<GroupProvider>();

//       await contentProvider.fetchContents();
//       await groupProvider.loadGroups();

//       /// SAFE provider fetch
//       LiveContent? provider;
//       try {
//         provider = contentProvider.contents.firstWhere(
//           (e) => e.type.toLowerCase() == "provider",
//         );
//       } catch (_) {
//         provider = null;
//       }

//       if (provider == null) {
//         _err("Provider content not available");
//       }

//       setState(() {
//         providerContent = provider;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//       _err("Failed to load data");
//     }
//   }

//   /// ERROR SNACKBAR
//   void _err(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   /// TIME PICKER
//   Future<void> pickStartTime() async {
//     final t = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (t != null) setState(() => startTime = t);
//   }

//   Future<void> pickEndTime() async {
//     final t = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (t != null) setState(() => endTime = t);
//   }

//   /// SELECT GROUP
//   void toggleGroup(String id) {
//     setState(() {
//       if (selectedGroupIds.contains(id)) {
//         selectedGroupIds.remove(id);
//       } else {
//         selectedGroupIds.add(id);
//       }
//     });
//   }

//   void toggleSelectAll(List<Group> groups) {
//     setState(() {
//       if (selectedGroupIds.length == groups.length) {
//         selectedGroupIds.clear();
//       } else {
//         selectedGroupIds = groups.map((g) => g.id).toSet();
//       }
//     });
//   }

//   /// SUBMIT
//   Future<void> submit() async {
//     if (providerContent == null) {
//       return _err("Provider content missing");
//     }

//     if (selectedGroupIds.isEmpty) {
//       return _err("Select at least one group");
//     }

//     // if (startTime == null || endTime == null) {
//     //   return _err("Select start & end time");
//     // }

//     setState(() => submitting = true);

//     // final start = DateTime(
//     //   selectedDate.year,
//     //   selectedDate.month,
//     //   selectedDate.day,
//     //   startTime!.hour,
//     //   startTime!.minute,
//     // );

//     // final end = DateTime(
//     //   selectedDate.year,
//     //   selectedDate.month,
//     //   selectedDate.day,
//     //   endTime!.hour,
//     //   endTime!.minute,
//     // );

//     final start = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//       0, // 00:00
//       0,
//     );

//     final end = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//       23, // 23:59
//       59,
//     );

//     print("Start: $start"); // 00:00
//     print("End: $end"); // 23:59

//     final payload = {
//       "content_type": "live_content",
//       "content_id": providerContent!.id,
//       "groups": selectedGroupIds.toList(),
//       "start_time": start.toIso8601String(),
//       "end_time": end.toIso8601String(),
//       "total_duration": "360",
//       "priority": 1,
//     };

//     print("payload.,.,... ${payload}");
//     // try {
//     //   final res = await ApiService.post("/schedule/add_v2", payload);

//     //   if (res.statusCode == 200 || res.statusCode == 201) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text("Schedule created")),
//     //     );

//     //     Navigator.push(
//     //       context,
//     //       MaterialPageRoute(
//     //         builder: (_) => SelectMethodToGoLive(
//     //           // selectedGroups: [],
//     //           channelId: providerContent!.channel_id,
//     //          contentId: providerContent!.id,

//     //         ),
//     //       ),
//     //     );
//     //   } else {
//     //     _err("Failed to create schedule");
//     //   }
//     // } catch (e) {
//     //   _err("Something went wrong");
//     // }

//      final groupProvider = context.read<GroupProvider>();
//  final selectedGroups = groupProvider.groups
//       .where((g) => selectedGroupIds.contains(g.id))
//       .toList();

//   /// ✅ NAVIGATE (NO API CALL HERE)
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => SelectMethodToGoLive(
//         channelId: providerContent!.channel_id,
//         contentId: providerContent!.id,
//         selectedGroups: selectedGroups,
//       ),
//     ),
//   );

//     setState(() => submitting = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final groupProvider = context.watch<GroupProvider>();

//     final groups = groupProvider.groups
//         .where((g) => g.name.toLowerCase().contains(searchText.toLowerCase()))
//         .toList();

//     if (loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Assign Channel")),

//       /// BODY
//       body: Column(
//         children: [
//           /// SEARCH
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search group...",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onChanged: (v) => setState(() => searchText = v),
//             ),
//           ),

//           /// SELECT ALL
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Groups",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 TextButton(
//                   onPressed: () => toggleSelectAll(groups),
//                   child: Text(
//                     selectedGroupIds.length == groups.length
//                         ? "Unselect All"
//                         : "Select All",
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// GROUP LIST
//           Expanded(
//             child: groupProvider.loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : groups.isEmpty
//                 ? const Center(child: Text("No groups found"))
//                 : ListView.builder(
//                     itemCount: groups.length,
//                     itemBuilder: (_, i) {
//                       final g = groups[i];

//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         child: ListTile(
//                           title: Text(g.name),
//                           subtitle: Text(
//                             "Client: ${g.clientName}\nDevices: ${g.deviceCount}",
//                           ),
//                           isThreeLine: true,
//                           trailing: Checkbox(
//                             value: selectedGroupIds.contains(g.id),
//                             onChanged: (_) => toggleGroup(g.id),
//                           ),
//                           onTap: () => toggleGroup(g.id),
//                         ),
//                       );
//                     },
//                   ),
//           ),

//           /// SCHEDULE CARD
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     //   Expanded(
//                     //     child: InkWell(
//                     //       onTap: pickStartTime,
//                     //       child: _timeBox(
//                     //         startTime == null
//                     //             ? "Start Time"
//                     //             : startTime!.format(context),
//                     //       ),
//                     //     ),
//                     //   ),
//                     //   const SizedBox(width: 10),
//                     //   Expanded(
//                     //     child: InkWell(
//                     //       onTap: pickEndTime,
//                     //       child: _timeBox(
//                     //         endTime == null
//                     //             ? "End Time"
//                     //             : endTime!.format(context),
//                     //       ),
//                     //     ),
//                     //   ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 /// SUBMIT
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: submitting ? null : submit,
//                     child: submitting
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Text("Assign & Continue"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _timeBox(String text) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(text),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import '../../providers/channel_provider.dart';

import '../../models/group.dart';

import 'select_method_to_go_live.dart';

class AssignLiveContentToGroups extends StatefulWidget {
  const AssignLiveContentToGroups({super.key});

  @override
  State<AssignLiveContentToGroups> createState() =>
      _AssignLiveContentToGroupsState();
}

class _AssignLiveContentToGroupsState extends State<AssignLiveContentToGroups> {
  /// GROUPS
  Set<String> selectedGroupIds = {};

  /// CHANNEL
  String? selectedChannelId;

  /// SEARCH
  String searchText = "";

  /// UI
  bool loading = true;
  bool submitting = false;

  /// STEP
  bool showGroups = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  /// LOAD DATA
  Future<void> initData() async {
    try {
      await context.read<GroupProvider>().loadGroups();

      await context.read<ChannelProvider>().fetchChannels();

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      _err("Failed to load data");
    }
  }

  /// ERROR
  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// GROUP SELECT
  void toggleGroup(String id) {
    setState(() {
      if (selectedGroupIds.contains(id)) {
        selectedGroupIds.remove(id);
      } else {
        selectedGroupIds.add(id);
      }
    });
  }

  /// SUBMIT
  Future<void> submit() async {
    if (selectedGroupIds.isEmpty) {
      return _err("Select at least one group");
    }

    setState(() {
      submitting = true;
    });

    final groupProvider = context.read<GroupProvider>();

    final selectedGroups = groupProvider.groups
        .where((g) => selectedGroupIds.contains(g.id))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMethodToGoLive(
          channelId: selectedChannelId!,
          contentId: selectedChannelId!,
          selectedGroups: selectedGroups,
        ),
      ),
    );

    setState(() {
      submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(showGroups ? "Select Groups" : "Select Channel"),
      ),

      body: !showGroups ? buildChannelStep() : buildGroupStep(),
    );
  }

  /// =========================
  /// CHANNEL STEP
  /// =========================

  Widget buildChannelStep() {
    final channelProvider = context.watch<ChannelProvider>();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: channelProvider.channels.length,

            itemBuilder: (_, i) {
              final channel = channelProvider.channels[i];

              return Card(
                margin: const EdgeInsets.all(12),

                child: RadioListTile<String>(
                  value: channel.channelId,

                  groupValue: selectedChannelId,

                  title: Text(channel.name),

                  subtitle: Text(channel.status),

                  onChanged: (value) {
                    setState(() {
                      selectedChannelId = value;
                    });
                  },
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),

          child: SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () {
                if (selectedChannelId == null) {
                  _err("Please select one channel");
                  return;
                }

                setState(() {
                  showGroups = true;
                });
              },

              child: const Text("Continue"),
            ),
          ),
        ),
      ],
    );
  }

  /// =========================
  /// GROUP STEP
  /// =========================

  Widget buildGroupStep() {
    final groupProvider = context.watch<GroupProvider>();

    final groups = groupProvider.groups
        .where((g) => g.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Column(
      children: [
        /// SEARCH
        Padding(
          padding: const EdgeInsets.all(12),

          child: TextField(
            decoration: InputDecoration(
              hintText: "Search group...",
              prefixIcon: const Icon(Icons.search),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            onChanged: (v) {
              setState(() {
                searchText = v;
              });
            },
          ),
        ),

        /// GROUP LIST
        Expanded(
          child: groups.isEmpty
              ? const Center(child: Text("No groups found"))
              : ListView.builder(
                  itemCount: groups.length,

                  itemBuilder: (_, i) {
                    final g = groups[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      child: ListTile(
                        title: Text(g.name),

                        subtitle: Text(
                          "Client: ${g.clientName}\nDevices: ${g.deviceCount}",
                        ),

                        isThreeLine: true,

                        trailing: Checkbox(
                          value: selectedGroupIds.contains(g.id),

                          onChanged: (_) {
                            toggleGroup(g.id);
                          },
                        ),

                        onTap: () {
                          toggleGroup(g.id);
                        },
                      ),
                    );
                  },
                ),
        ),

        /// BUTTONS
        /// BUTTONS
        Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              /// SMALL BACK BUTTON
              SizedBox(
                width: 60,

                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showGroups = false;
                    });
                  },

                  child: const Icon(Icons.arrow_back),
                ),
              ),

              const SizedBox(width: 12),

              /// BIG CONTINUE BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: submitting ? null : submit,

                  child: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Assign & Continue"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
