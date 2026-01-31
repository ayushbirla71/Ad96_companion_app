import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import '../../services/api_service.dart';

class DeleteSchedulePage extends StatefulWidget {
  final ScheduleAd schedule;

  const DeleteSchedulePage({super.key, required this.schedule});

  @override
  State<DeleteSchedulePage> createState() => _DeleteSchedulePageState();
}

class _DeleteSchedulePageState extends State<DeleteSchedulePage> {
  String? selectedGroupId;
  DateTime? selectedFrom;
  DateTime? selectedTo;
  bool deleting = false;

  String selectedTimeRange = "today";
  final DateFormat backendDateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();

    // Auto-select the first group if exists
    if (widget.schedule.groups.isNotEmpty) {
      final firstGroup = widget.schedule.groups.first;
      selectedGroupId = firstGroup.groupId;
      selectedFrom = _parseDate(firstGroup.fromDate);
      selectedTo = _parseDate(firstGroup.toDate);
      selectedTimeRange = "today";
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split("-");
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  String _fmt(DateTime d) => backendDateFormat.format(d);

  List<DropdownMenuItem<String>> getTimeRangeOptions() {
    if (selectedGroupId == null) return [];

    final group = widget.schedule.groups
        .firstWhere((g) => g.groupId == selectedGroupId);

    final startDate = _parseDate(group.fromDate);
    final endDate = _parseDate(group.toDate);
    final today = DateTime.now();
    final totalDays = group.totalDays;
    final remainingDays = (endDate.difference(today).inDays).clamp(0, totalDays);

    final isActiveToday =
        today.isAfter(startDate.subtract(const Duration(days: 1))) &&
        today.isBefore(endDate.add(const Duration(days: 1)));

    final options = <DropdownMenuItem<String>>[];

    if (isActiveToday) {
      options.add(const DropdownMenuItem(value: "today", child: Text("Today")));
    }

    if (totalDays > 1 && (isActiveToday || remainingDays > 0)) {
      options.add(
          const DropdownMenuItem(value: "week", child: Text("This week")));
    }

    if (totalDays > 7) {
      options.add(
          const DropdownMenuItem(value: "month", child: Text("This month")));
    }

    options.add(const DropdownMenuItem(value: "custom", child: Text("Custom")));

    return options;
  }

  Future<void> pickDate({required bool isFrom}) async {
    final initial = isFrom
        ? selectedFrom ?? DateTime.now()
        : selectedTo ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          selectedFrom = picked;
        } else {
          selectedTo = picked;
        }
      });
    }
  }

  Map<String, String> getDateRangeForTimeOption() {
    final today = DateTime.now();
    switch (selectedTimeRange) {
      case "today":
        return {"from": _fmt(today), "to": _fmt(today)};
      case "week":
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return {"from": _fmt(startOfWeek), "to": _fmt(endOfWeek)};
      case "month":
        final startOfMonth = DateTime(today.year, today.month, 1);
        final endOfMonth = DateTime(today.year, today.month + 1, 0);
        return {"from": _fmt(startOfMonth), "to": _fmt(endOfMonth)};
      case "custom":
        return {"from": _fmt(selectedFrom!), "to": _fmt(selectedTo!)};
      default:
        return {"from": _fmt(today), "to": _fmt(today)};
    }
  }

  Future<void> deleteSchedule() async {
    if (selectedGroupId == null) return;

    setState(() => deleting = true);

    final dateRange = getDateRangeForTimeOption();

    final payload = {
      "adId": widget.schedule.adId,
      "groupId": selectedGroupId,
      "startDate": dateRange["from"],
      "endDate": dateRange["to"],
      "timeRangeType": selectedTimeRange,
    };

    try {
      final response = await ApiService.post(
        "/schedule/multiple-delete",
        payload,
      );

      final result = jsonDecode(response.body);
      if (result != null && result["message"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Schedule deleted successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${result?["error"] ?? 'Unknown'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.schedule;

    return Scaffold(
      appBar: AppBar(title: const Text("Delete Schedule")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ad: ${schedule.adName}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text("Select a group:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...schedule.groups.map(
              (g) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: RadioListTile<String>(
                  title: Text(g.groupName),
                  subtitle: Text("${g.fromDate} → ${g.toDate}"),
                  value: g.groupId,
                  groupValue: selectedGroupId,
                  onChanged: (val) {
                    setState(() {
                      selectedGroupId = val;
                      final group = schedule.groups.firstWhere(
                        (grp) => grp.groupId == val,
                      );
                      selectedFrom = _parseDate(group.fromDate);
                      selectedTo = _parseDate(group.toDate);
                      selectedTimeRange = "today";
                    });
                  },
                ),
              ),
            ),
            const Divider(),
            if (selectedGroupId != null) ...[
              const SizedBox(height: 12),
              const Text("Select time range:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedTimeRange,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: getTimeRangeOptions(),
                  onChanged: (val) {
                    setState(() => selectedTimeRange = val!);
                  },
                  hint: const Text("Select Time Range"),
                ),
              ),
              if (selectedTimeRange == "custom") ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickDate(isFrom: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedFrom != null
                                  ? DateFormat('yyyy-MM-dd').format(selectedFrom!)
                                  : "Select From"),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickDate(isFrom: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedTo != null
                                  ? DateFormat('yyyy-MM-dd').format(selectedTo!)
                                  : "Select To"),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: deleting ? null : deleteSchedule,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: deleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Delete Schedule"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
