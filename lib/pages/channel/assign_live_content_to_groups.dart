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

///////////////////////////////////////////////////////////
///
///
///
///
///

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../providers/group_provider.dart';
// import '../../providers/channel_provider.dart';

// import '../../models/group.dart';

// import 'select_method_to_go_live.dart';

// class AssignLiveContentToGroups extends StatefulWidget {
//   const AssignLiveContentToGroups({super.key});

//   @override
//   State<AssignLiveContentToGroups> createState() =>
//       _AssignLiveContentToGroupsState();
// }

// class _AssignLiveContentToGroupsState extends State<AssignLiveContentToGroups> {
//   /// GROUPS
//   Set<String> selectedGroupIds = {};

//   /// CHANNEL
//   String? selectedChannelId;

//   /// SEARCH
//   String searchText = "";

//   /// UI
//   bool loading = true;
//   bool submitting = false;

//   /// STEP
//   bool showGroups = false;

//   @override
//   void initState() {
//     super.initState();
//     initData();
//   }

//   /// LOAD DATA
//   Future<void> initData() async {
//     try {
//       await context.read<GroupProvider>().loadGroups();

//       await context.read<ChannelProvider>().fetchChannels();

//       setState(() {
//         loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         loading = false;
//       });

//       _err("Failed to load data");
//     }
//   }

//   /// ERROR
//   void _err(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   /// GROUP SELECT
//   void toggleGroup(String id) {
//     setState(() {
//       if (selectedGroupIds.contains(id)) {
//         selectedGroupIds.remove(id);
//       } else {
//         selectedGroupIds.add(id);
//       }
//     });
//   }

//   /// SUBMIT
//   Future<void> submit() async {
//     if (selectedGroupIds.isEmpty) {
//       return _err("Select at least one group");
//     }

//     setState(() {
//       submitting = true;
//     });

//     final groupProvider = context.read<GroupProvider>();

//     final selectedGroups = groupProvider.groups
//         .where((g) => selectedGroupIds.contains(g.id))
//         .toList();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SelectMethodToGoLive(
//           channelId: selectedChannelId!,
//           contentId: selectedChannelId!,
//           selectedGroups: selectedGroups,
//         ),
//       ),
//     );

//     setState(() {
//       submitting = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(showGroups ? "Select Groups" : "Select Channel"),
//       ),

//       body: !showGroups ? buildChannelStep() : buildGroupStep(),
//     );
//   }

//   /// =========================
//   /// CHANNEL STEP
//   /// =========================

//   Widget buildChannelStep() {
//     final channelProvider = context.watch<ChannelProvider>();

//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: channelProvider.channels.length,

//             itemBuilder: (_, i) {
//               final channel = channelProvider.channels[i];

//               return Card(
//                 margin: const EdgeInsets.all(12),

//                 child: RadioListTile<String>(
//                   value: channel.channelId,

//                   groupValue: selectedChannelId,

//                   title: Text(channel.name),

//                   subtitle: Text(channel.status),

//                   onChanged: (value) {
//                     setState(() {
//                       selectedChannelId = value;
//                     });
//                   },
//                 ),
//               );
//             },
//           ),
//         ),

//         Padding(
//           padding: const EdgeInsets.all(16),

//           child: SizedBox(
//             width: double.infinity,

//             child: ElevatedButton(
//               onPressed: () {
//                 if (selectedChannelId == null) {
//                   _err("Please select one channel");
//                   return;
//                 }

//                 setState(() {
//                   showGroups = true;
//                 });
//               },

//               child: const Text("Continue"),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   /// =========================
//   /// GROUP STEP
//   /// =========================

//   Widget buildGroupStep() {
//     final groupProvider = context.watch<GroupProvider>();

//     final groups = groupProvider.groups
//         .where((g) => g.name.toLowerCase().contains(searchText.toLowerCase()))
//         .toList();

//     return Column(
//       children: [
//         /// SEARCH
//         Padding(
//           padding: const EdgeInsets.all(12),

//           child: TextField(
//             decoration: InputDecoration(
//               hintText: "Search group...",
//               prefixIcon: const Icon(Icons.search),

//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),

//             onChanged: (v) {
//               setState(() {
//                 searchText = v;
//               });
//             },
//           ),
//         ),

//         /// GROUP LIST
//         Expanded(
//           child: groups.isEmpty
//               ? const Center(child: Text("No groups found"))
//               : ListView.builder(
//                   itemCount: groups.length,

//                   itemBuilder: (_, i) {
//                     final g = groups[i];

//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),

//                       child: ListTile(
//                         title: Text(g.name),

//                         subtitle: Text(
//                           "Client: ${g.clientName}\nDevices: ${g.deviceCount}",
//                         ),

//                         isThreeLine: true,

//                         trailing: Checkbox(
//                           value: selectedGroupIds.contains(g.id),

//                           onChanged: (_) {
//                             toggleGroup(g.id);
//                           },
//                         ),

//                         onTap: () {
//                           toggleGroup(g.id);
//                         },
//                       ),
//                     );
//                   },
//                 ),
//         ),

//         /// BUTTONS
//         /// BUTTONS
//         Padding(
//           padding: const EdgeInsets.all(16),

//           child: Row(
//             children: [
//               /// SMALL BACK BUTTON
//               SizedBox(
//                 width: 60,

//                 child: OutlinedButton(
//                   onPressed: () {
//                     setState(() {
//                       showGroups = false;
//                     });
//                   },

//                   child: const Icon(Icons.arrow_back),
//                 ),
//               ),

//               const SizedBox(width: 12),

//               /// BIG CONTINUE BUTTON
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: submitting ? null : submit,

//                   child: submitting
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text("Assign & Continue"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
// }

// <<<<<<<<<<<<<<<<<<<<OLD WORKING CODE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

//   /// ADDED: Controls which step of the UI to show
//   bool showGroups = false;

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

//       /// REMOVED: Auto-selection of the first provider.
//       /// Now we just load the data and wait for the user to select.
//       setState(() {
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

//     setState(() => submitting = true);

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

//     final groupProvider = context.read<GroupProvider>();
//     final selectedGroups = groupProvider.groups
//         .where((g) => selectedGroupIds.contains(g.id))
//         .toList();

//     /// ✅ NAVIGATE (NO API CALL HERE)
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SelectMethodToGoLive(
//           channelId: providerContent!.channel_id,
//           contentId: providerContent!.id,
//           selectedGroups: selectedGroups,
//         ),
//       ),
//     );

//     setState(() => submitting = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(showGroups ? "Assign Channel" : "Select Live Content"),
//         // Back button to return to Content Selection step
//         leading: showGroups
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   setState(() {
//                     showGroups = false;
//                   });
//                 },
//               )
//             : null,
//       ),

//       /// Switch between Content Selection Step and Group Selection Step
//       body: showGroups ? buildGroupStep() : buildContentStep(),
//     );
//   }

//   /// =========================
//   /// STEP 1: CONTENT SELECTION
//   /// =========================
//   Widget buildContentStep() {
//     final contentProvider = context.watch<LiveContentProvider>();

//     // Filtering exactly as you did in your auto-pick logic
//     final contents = contentProvider.contents
//         .where((e) => e.type.toLowerCase() == "provider")
//         .toList();

//     if (contents.isEmpty) {
//       return const Center(child: Text("No provider content available"));
//     }

//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: contents.length,
//             itemBuilder: (_, i) {
//               final content = contents[i];

//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: RadioListTile<LiveContent>(
//                   value: content,
//                   groupValue: providerContent,
//                   // NOTE: Change `content.id` to `content.name` or `content.title` if your model supports it
//                   title: Text("${content.name}"),
//                   subtitle: Text("Type: ${content.type}"),
//                   onChanged: (value) {
//                     setState(() {
//                       providerContent = value;
//                     });
//                   },
//                 ),
//               );
//             },
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 if (providerContent == null) {
//                   _err("Please select a live content");
//                   return;
//                 }
//                 setState(() {
//                   showGroups = true;
//                 });
//               },
//               child: const Text("Continue"),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   /// =========================
//   /// STEP 2: GROUP SELECTION
//   /// =========================
//   Widget buildGroupStep() {
//     final groupProvider = context.watch<GroupProvider>();

//     final groups = groupProvider.groups
//         .where((g) => g.name.toLowerCase().contains(searchText.toLowerCase()))
//         .toList();

//     return Column(
//       children: [
//         /// SEARCH
//         Padding(
//           padding: const EdgeInsets.all(12),
//           child: TextField(
//             decoration: InputDecoration(
//               hintText: "Search group...",
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onChanged: (v) => setState(() => searchText = v),
//           ),
//         ),

//         /// SELECT ALL
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Groups",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               TextButton(
//                 onPressed: () => toggleSelectAll(groups),
//                 child: Text(
//                   selectedGroupIds.length == groups.length
//                       ? "Unselect All"
//                       : "Select All",
//                 ),
//               ),
//             ],
//           ),
//         ),

//         /// GROUP LIST
//         Expanded(
//           child: groupProvider.loading
//               ? const Center(child: CircularProgressIndicator())
//               : groups.isEmpty
//               ? const Center(child: Text("No groups found"))
//               : ListView.builder(
//                   itemCount: groups.length,
//                   itemBuilder: (_, i) {
//                     final g = groups[i];

//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       child: ListTile(
//                         title: Text(g.name),
//                         subtitle: Text(
//                           "Client: ${g.clientName}\nDevices: ${g.deviceCount}",
//                         ),
//                         isThreeLine: true,
//                         trailing: Checkbox(
//                           value: selectedGroupIds.contains(g.id),
//                           onChanged: (_) => toggleGroup(g.id),
//                         ),
//                         onTap: () => toggleGroup(g.id),
//                       ),
//                     );
//                   },
//                 ),
//         ),

//         /// SCHEDULE CARD
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   // Expanded(
//                   //   child: InkWell(
//                   //     onTap: pickStartTime,
//                   //     child: _timeBox(
//                   //       startTime == null
//                   //           ? "Start Time"
//                   //           : startTime!.format(context),
//                   //     ),
//                   //   ),
//                   // ),
//                   // const SizedBox(width: 10),
//                   // Expanded(
//                   //   child: InkWell(
//                   //     onTap: pickEndTime,
//                   //     child: _timeBox(
//                   //       endTime == null
//                   //           ? "End Time"
//                   //           : endTime!.format(context),
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               /// SUBMIT
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: submitting ? null : submit,
//                   child: submitting
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text("Assign & Continue"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
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

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms_app/services/api_service.dart';

import '../../providers/live_content_provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';
import '../../models/liveContent.dart';

import 'select_method_to_go_live.dart';
import 'package:cms_app/theme/app_colors.dart';
import 'dart:convert';

class AssignLiveContentToGroups extends StatefulWidget {
  const AssignLiveContentToGroups({super.key});

  @override
  State<AssignLiveContentToGroups> createState() =>
      _AssignLiveContentToGroupsState();
}

class _AssignLiveContentToGroupsState extends State<AssignLiveContentToGroups> {
  Set<String> selectedGroupIds = {};
  String searchText = "";

  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  LiveContent? providerContent;

  bool loading = true;
  bool submitting = false;

  bool showGroups = false;

  bool showLayouts = false;

  String? selectedLayoutId;
  Map<String, dynamic>? selectedLayout;

  List<dynamic> layouts = [];
  bool layoutsLoading = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> loadLayouts() async {
    try {
      setState(() => layoutsLoading = true);

      final response = await ApiService.get(
        "/layout/templates?is_live_content_template=true",
      );

      final jsonResponse = jsonDecode(response.body);

      setState(() {
        layouts = jsonResponse["data"] ?? [];
        layoutsLoading = false;
      });
    } catch (e) {
      setState(() => layoutsLoading = false);
      _err("Failed to load layouts");
    }
  }

  /// INIT DATA
  Future<void> initData() async {
    try {
      final contentProvider = context.read<LiveContentProvider>();
      final groupProvider = context.read<GroupProvider>();

      await contentProvider.fetchContents();
      await groupProvider.loadGroups();

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      _err("Failed to load data");
    }
  }

  /// ERROR SNACKBAR
  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: appColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// TIME PICKER
  Future<void> pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => startTime = t);
  }

  Future<void> pickEndTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => endTime = t);
  }

  /// SELECT GROUP
  void toggleGroup(String id) {
    setState(() {
      if (selectedGroupIds.contains(id)) {
        selectedGroupIds.remove(id);
      } else {
        selectedGroupIds.add(id);
      }
    });
  }

  void toggleSelectAll(List<Group> groups) {
    setState(() {
      if (selectedGroupIds.length == groups.length) {
        selectedGroupIds.clear();
      } else {
        selectedGroupIds = groups.map((g) => g.id).toSet();
      }
    });
  }

  /// SUBMIT
  Future<void> submit() async {
    if (providerContent == null) {
      return _err("Provider content missing");
    }

    if (selectedGroupIds.isEmpty) {
      return _err("Select at least one group");
    }

    setState(() => submitting = true);

    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0,
      0,
    );

    final end = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
    );

    print("Start: $start");
    print("End: $end");

    final groupProvider = context.read<GroupProvider>();
    final selectedGroups = groupProvider.groups
        .where((g) => selectedGroupIds.contains(g.id))
        .toList();
    print("Passing Layout ID: $selectedLayoutId");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMethodToGoLive(
          channelId: providerContent!.channel_id,
          contentId: providerContent!.id,
          selectedGroups: selectedGroups,
          layoutId: selectedLayoutId, // optional
        ),
      ),
    );

    setState(() => submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: appColors.bg,
        body: Center(
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
                'Loading…',
                style: TextStyle(color: appColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: appColors.bg,
      appBar: AppBar(
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: showGroups
            ? IconButton(
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
                onPressed: () => setState(() => showGroups = false),
              )
            : IconButton(
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
        title: Text(
          // showGroups ? 'Assign Channel' : 'Select Live Content',
          showGroups
              ? 'Assign Channel'
              : showLayouts
              ? 'Select Layout'
              : 'Select Live Content',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      // body: showGroups ? buildGroupStep() : buildContentStep(),
      body: showGroups
          ? buildGroupStep()
          : showLayouts
          ? buildLayoutStep()
          : buildContentStep(),
    );
  }

  /// =========================
  /// STEP 1: CONTENT SELECTION
  /// =========================
  Widget buildContentStep() {
    final contentProvider = context.watch<LiveContentProvider>();

    final contents = contentProvider.contents
        .where((e) => e.type.toLowerCase() == "provider")
        .toList();

    if (contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appColors.surfaceHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.live_tv_rounded,
                color: appColors.textMuted,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No provider content available',
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Step indicator ──
        _stepBanner(
          step: '01',
          title: 'Select Live Content',
          subtitle: 'Choose a provider stream to assign',
          icon: Icons.live_tv_rounded,
        ),

        // ── Content list ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: contents.length,
            itemBuilder: (_, i) {
              final content = contents[i];
              final isSelected = providerContent?.id == content.id;

              return GestureDetector(
                onTap: () => setState(() => providerContent = content),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: appColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? appColors.accent.withOpacity(0.6)
                          : appColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? appColors.accentLight
                              : appColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.live_tv_rounded,
                          color: isSelected
                              ? appColors.accent
                              : appColors.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content.name,
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Type: ${content.type}',
                              style: TextStyle(
                                color: appColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<LiveContent>(
                        value: content,
                        groupValue: providerContent,
                        activeColor: appColors.accent,
                        onChanged: (value) =>
                            setState(() => providerContent = value),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Continue button ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: appColors.surface,
            border: Border(top: BorderSide(color: appColors.border)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                if (providerContent == null) {
                  _err("Please select a live content");
                  return;
                }
                // setState(() => showGroups = true);
                try {
                  await loadLayouts();

                  setState(() {
                    showLayouts = true;
                  });
                } catch (e) {
                  _err("Failed to load layouts");
                }
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: const Text('Continue'),
              style: FilledButton.styleFrom(
                backgroundColor: appColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// =========================
  /// STEP 2: Layout SELECTION
  /// =========================
  Widget buildLayoutStep() {
    return Column(
      children: [
        _stepBanner(
          step: '02',
          title: 'Select Layout',
          subtitle: 'Choose a layout template (optional)',
          icon: Icons.dashboard_customize_rounded,
        ),

        Expanded(
          child: layoutsLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: layouts.length,
                  itemBuilder: (_, index) {
                    final layout = layouts[index];

                    final isSelected = selectedLayoutId == layout["layout_id"];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLayoutId = layout["layout_id"];
                          selectedLayout = layout;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: appColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? appColors.accent
                                : appColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.dashboard_customize_rounded,
                              color: isSelected
                                  ? appColors.accent
                                  : appColors.textMuted,
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    layout["name"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "${layout["orientation"]} • ${layout["resolution"]}",
                                  ),

                                  Text(
                                    "${(layout["zones"] as List).length} Zones",
                                  ),
                                ],
                              ),
                            ),

                            Radio<String>(
                              value: layout["layout_id"],
                              groupValue: selectedLayoutId,
                              onChanged: (value) {
                                setState(() {
                                  selectedLayoutId = value;
                                  selectedLayout = layout;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: appColors.surface,
            border: Border(top: BorderSide(color: appColors.border)),
            boxShadow: [
              BoxShadow(
                color: appColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedLayoutId = null;
                      selectedLayout = null;

                      showLayouts = false;
                      showGroups = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appColors.textSecondary,
                    side: BorderSide(color: appColors.border, width: 1.2),
                    backgroundColor: appColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text("Skip & Continue"),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FilledButton.icon(
                  onPressed: selectedLayoutId == null
                      ? null
                      : () {
                          setState(() {
                            showLayouts = false;
                            showGroups = true;
                          });
                        },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text("Continue"),
                  style: FilledButton.styleFrom(
                    backgroundColor: appColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: appColors.accent.withOpacity(0.4),
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// =========================
  /// STEP 3: GROUP SELECTION
  /// =========================
  Widget buildGroupStep() {
    final groupProvider = context.watch<GroupProvider>();

    final groups = groupProvider.groups
        .where((g) => g.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Column(
      children: [
        // ── Step indicator ──
        _stepBanner(
          step: '03',
          title: 'Assign to Groups',
          subtitle: 'Select one or more groups to go live',
          icon: Icons.group_rounded,
        ),

        // ── Search bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: appColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: appColors.border),
              boxShadow: [
                BoxShadow(
                  color: appColors.shadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              style: TextStyle(color: appColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search group…',
                hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: appColors.textMuted,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
              ),
              onChanged: (v) => setState(() => searchText = v),
            ),
          ),
        ),

        // ── Select All row ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: appColors.accentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: appColors.accent,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Groups',
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (selectedGroupIds.isNotEmpty) ...[
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
                        '${selectedGroupIds.length}',
                        style: TextStyle(
                          color: appColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              GestureDetector(
                onTap: () => toggleSelectAll(groups),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selectedGroupIds.length == groups.length
                        ? appColors.redLight
                        : appColors.accentLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedGroupIds.length == groups.length
                          ? appColors.red.withOpacity(0.3)
                          : appColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    selectedGroupIds.length == groups.length
                        ? 'Unselect All'
                        : 'Select All',
                    style: TextStyle(
                      color: selectedGroupIds.length == groups.length
                          ? appColors.red
                          : appColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Group list ──
        Expanded(
          child: groupProvider.loading
              ? Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: appColors.accent,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : groups.isEmpty
              ? Center(
                  child: Text(
                    'No groups found',
                    style: TextStyle(color: appColors.textMuted, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  itemCount: groups.length,
                  itemBuilder: (_, i) {
                    final g = groups[i];
                    final isSelected = selectedGroupIds.contains(g.id);

                    return GestureDetector(
                      onTap: () => toggleGroup(g.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: appColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? appColors.accent.withOpacity(0.5)
                                : appColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
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
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? appColors.accentLight
                                    : appColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.devices_rounded,
                                color: isSelected
                                    ? appColors.accent
                                    : appColors.textMuted,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.name,
                                    style: TextStyle(
                                      color: appColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Client: ${g.clientName}',
                                    style: TextStyle(
                                      color: appColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    'Devices: ${g.deviceCount}',
                                    style: TextStyle(
                                      color: appColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              activeColor: appColors.accent,
                              side: BorderSide(
                                color: appColors.border,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (_) => toggleGroup(g.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ── Bottom action bar ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: appColors.surface,
            border: Border(top: BorderSide(color: appColors.border)),
            boxShadow: [
              BoxShadow(
                color: appColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Selected count summary
              if (selectedGroupIds.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.accentLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: appColors.accent.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: appColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${selectedGroupIds.length} group${selectedGroupIds.length > 1 ? 's' : ''} selected',
                        style: TextStyle(
                          color: appColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: submitting ? null : submit,
                  icon: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.live_tv_rounded, size: 17),
                  label: Text(
                    submitting ? 'Please wait…' : 'Assign & Continue',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: appColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: appColors.accent.withOpacity(0.6),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeBox(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: appColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: appColors.textPrimary, fontSize: 13),
      ),
    );
  }

  // ─── Step banner ───────────────────────────────────────────────────────────

  Widget _stepBanner({
    required String step,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appColors.accent, const Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColors.accent.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Step $step',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
