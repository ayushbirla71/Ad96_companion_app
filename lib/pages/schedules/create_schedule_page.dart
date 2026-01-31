import 'package:cms_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/group_provider.dart';
import 'dart:convert';

enum ScheduleType { single, multiple }

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  String? selectedAdId;
  final Set<String> selectedGroupIds = {};

  String adSearch = "";
  String groupSearch = "";

  ScheduleType scheduleType = ScheduleType.single;

  late String singleDate;
  late String fromDate;
  late String toDate;

  @override
  void initState() {
    super.initState();

    final today = _fmt(DateTime.now());
    singleDate = today;
    fromDate = today;
    toDate = today;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdProvider>().loadAds();
      context.read<GroupProvider>().loadGroups();
    });
  }

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<String?> _pickDate(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    return d == null ? null : _fmt(d);
  }

  void _err(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}


  @override
  Widget build(BuildContext context) {
    final adProvider = context.watch<AdProvider>();
    final groupProvider = context.watch<GroupProvider>();

    final ads = adProvider.ads
        .where((a) => a.name.toLowerCase().contains(adSearch.toLowerCase()))
        .toList();

    final groups = groupProvider.groups
        .where((g) => g.name.toLowerCase().contains(groupSearch.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Create Schedule")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= ADS =================
            _sectionTitle("Select Ad"),

            _searchBox(
              hint: "Search ads...",
              onChanged: (v) => setState(() => adSearch = v),
            ),

            _listCard(
              child: adProvider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ads.isEmpty
                      ? const Center(child: Text("No ads found"))
                      : ListView(
                          children: ads.map((ad) {
                            return RadioListTile<String>(
                              value: ad.adId,
                              groupValue: selectedAdId,
                              title: Text(ad.name),
                              onChanged: (v) =>
                                  setState(() => selectedAdId = v),
                            );
                          }).toList(),
                        ),
            ),

            const SizedBox(height: 20),

            // ================= GROUPS =================
            _sectionTitle("Select Device Groups"),

            _searchBox(
              hint: "Search groups...",
              onChanged: (v) => setState(() => groupSearch = v),
            ),

            _listCard(
              child: groupProvider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : groups.isEmpty
                      ? const Center(child: Text("No groups found"))
                      : ListView(
                          children: groups.map((g) {
                            return CheckboxListTile(
                              value: selectedGroupIds.contains(g.id),
                              title: Text(g.name),
                              onChanged: (v) {
                                setState(() {
                                  v == true
                                      ? selectedGroupIds.add(g.id)
                                      : selectedGroupIds.remove(g.id);
                                });
                              },
                            );
                          }).toList(),
                        ),
            ),

            const SizedBox(height: 20),

            // ================= SCHEDULE TYPE =================
            _sectionTitle("Schedule Duration"),

            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Single Day"),
                    value: ScheduleType.single,
                    groupValue: scheduleType,
                    onChanged: (v) => setState(() => scheduleType = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Multiple Days"),
                    value: ScheduleType.multiple,
                    groupValue: scheduleType,
                    onChanged: (v) => setState(() => scheduleType = v!),
                  ),
                ),
              ],
            ),

            if (scheduleType == ScheduleType.single)
              _dateButton("Date: $singleDate", () async {
                final d = await _pickDate(context);
                if (d != null) setState(() => singleDate = d);
              }),

            if (scheduleType == ScheduleType.multiple)
              Row(
                children: [
                  Expanded(
                    child: _dateButton("From: $fromDate", () async {
                      final d = await _pickDate(context);
                      if (d != null) setState(() => fromDate = d);
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dateButton("To: $toDate", () async {
                      final d = await _pickDate(context);
                      if (d != null) setState(() => toDate = d);
                    }),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // ================= SUBMIT =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text("Create Schedule"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _searchBox({
    required String hint,
    required ValueChanged<String> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: onChanged,
        ),
      );

  Widget _listCard({required Widget child}) => Card(
        elevation: 1,
        child: SizedBox(height: 220, child: child),
      );

  Widget _dateButton(String text, VoidCallback onTap) =>
      OutlinedButton.icon(
        icon: const Icon(Icons.date_range),
        label: Text(text),
        onPressed: onTap,
      );

 void _submit() async {
  if (selectedAdId == null) return _err("Select an ad");
  if (selectedGroupIds.isEmpty) return _err("Select at least one group");
  if (scheduleType == ScheduleType.multiple && fromDate.compareTo(toDate) > 0) {
    return _err("Invalid date range");
  }

  const totalDuration = "360";
  const priority = 1;

  final payload = {
    "ad_id": selectedAdId,
    "groups": selectedGroupIds.toList(),
    "start_time": toISODate(scheduleType == ScheduleType.single ? singleDate : fromDate),
    "end_time": toISODate(scheduleType == ScheduleType.single ? singleDate : toDate),
    "total_duration": totalDuration,
    "priority": priority
  };

  debugPrint("SCHEDULE PAYLOAD => $payload");

  try {
    final response = await ApiService.post("/schedule/add", payload);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule created successfully")),
      );
      Navigator.pop(context);
    } else {
      debugPrint("API Error: ${response.body}");
      _err("Failed to create schedule");
    }
  } catch (e) {
    debugPrint("API Exception: $e");
    _err("Something went wrong");
  }
}

String toISODate(String date) => "${date}T00:00:00.000Z";

}
