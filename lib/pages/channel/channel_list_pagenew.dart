import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms_app/services/api_service.dart';

import '../../providers/live_content_provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';
import '../../models/liveContent.dart';

import 'channel_details_webcam_page.dart';

class ChannelGroupAssignPage extends StatefulWidget {
  const ChannelGroupAssignPage({super.key});

  @override
  State<ChannelGroupAssignPage> createState() => _ChannelGroupAssignPageState();
}

class _ChannelGroupAssignPageState extends State<ChannelGroupAssignPage> {
  String? selectedChannelId;
  Set<String> selectedGroupIds = {};

  String searchText = "";

  DateTime singleDate = DateTime.now();

  TimeOfDay? startTime;

  TimeOfDay? endTime;

  LiveContent? providerContent;

  Future<TimeOfDay?> _pickTime(BuildContext context) async {
    return await showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  String toISODate(DateTime date, TimeOfDay? time) {
    if (time == null) return "";

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return dt.toIso8601String();
  }

  Widget _dateButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final contentProvider = context.read<LiveContentProvider>();
      final groupProvider = context.read<GroupProvider>();

      await contentProvider.fetchContents();
      await groupProvider.loadGroups();

      /// Find provider content
      final provider = contentProvider.contents.firstWhere(
        (e) => e.type.toLowerCase() == "provider",
        orElse: () => throw Exception("Provider content not found"),
      );

      setState(() {
        providerContent = provider;
      });

      print("Provider Content ID: ${provider.id}");
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

  void toggleGroup(String id) {
    setState(() {
      if (selectedGroupIds.contains(id)) {
        selectedGroupIds.remove(id);
      } else {
        selectedGroupIds.add(id);
      }
    });
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void submitSelection() async {
    if (providerContent == null) {
      return _err("Provider content not loaded");
    }

    if (selectedGroupIds.isEmpty) {
      return _err("Select at least one group");
    }

    final start = DateTime(
      singleDate.year,
      singleDate.month,
      singleDate.day,
      0,
      0,
      0,
    );

    final end = DateTime(
      singleDate.year,
      singleDate.month,
      singleDate.day,
      23,
      59,
      59,
    );

    final payload = {
      "content_type": "live_content",

      "content_id": providerContent!.id,

      "groups": selectedGroupIds.toList(),

      "start_time": start.toIso8601String(),

      "end_time": end.toIso8601String(),

      "total_duration": "360",

      "priority": 1,
    };

    print("PAYLOAD:");
    print(payload);

    try {
      final response = await ApiService.post("/schedule/add_v2", payload);

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Live schedule created")));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChannelDetailsPage(
              // channelId: 'ebebb40d-7295-4e92-b70c-48346f6a7836',
              channelId: providerContent!.channel_id,
            ),
          ),
        );
      } else {
        _err("Failed to create schedule");
      }
    } catch (e) {
      print(e);
      _err("Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    final filteredGroups = groupProvider.groups.where((group) {
      return group.name.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Assign Channel to Groups")),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// CHANNEL SECTION
            /// GROUP HEADER + SELECT ALL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Groups",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => toggleSelectAll(filteredGroups),
                    child: Text(
                      selectedGroupIds.length == filteredGroups.length
                          ? "Unselect All"
                          : "Select All",
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            /// SEARCH GROUP
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
            /// GROUP LIST
            groupProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredGroups.length,
                    itemBuilder: (_, i) {
                      final group = filteredGroups[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(group.name),

                          subtitle: Text(
                            "Client: ${group.clientName}\nDevices: ${group.deviceCount}",
                          ),

                          isThreeLine: true,

                          trailing: Checkbox(
                            value: selectedGroupIds.contains(group.id),
                            onChanged: (value) {
                              toggleGroup(group.id);
                            },
                          ),

                          onTap: () {
                            toggleGroup(group.id);
                          },
                        ),
                      );
                    },
                  ),

            /// SCHEDULE DATE (Single Only)
            /// SCHEDULE TIME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Schedule",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// DATE (TODAY DEFAULT)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Date: ${singleDate.toLocal().toString().split(' ')[0]}",
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// START TIME
                  InkWell(
                    onTap: () async {
                      final t = await _pickTime(context);
                      if (t != null) {
                        setState(() => startTime = t);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        startTime == null
                            ? "Select Start Time"
                            : "Start Time: ${startTime!.format(context)}",
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// END TIME
                  InkWell(
                    onTap: () async {
                      final t = await _pickTime(context);
                      if (t != null) {
                        setState(() => endTime = t);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        endTime == null
                            ? "Select End Time"
                            : "End Time: ${endTime!.format(context)}",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// SUBMIT BUTTON
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitSelection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
