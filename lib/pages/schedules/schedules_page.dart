import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import 'create_schedule_page.dart';
import 'delete_schedule_page.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  bool showFilters = false;
  String searchText = "";

  @override
  void initState() {
    super.initState();
    context.read<ScheduleProvider>().loadSchedules(); // ✅ today → today
  }

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final provider = context.read<ScheduleProvider>();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      final date =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      if (!isFrom && date.compareTo(provider.fromDate) < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("To date cannot be before From date")),
        );
        return;
      }

      provider.updateDateRange(
        isFrom ? date : provider.fromDate,
        isFrom ? provider.toDate : date,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    // 🔍 Filter schedules by search text
    final filteredSchedules = provider.schedules.where((schedule) {
      final adMatch = schedule.adName.toLowerCase().contains(
        searchText.toLowerCase(),
      );
      final groupMatch = schedule.groups.any(
        (g) => g.groupName.toLowerCase().contains(searchText.toLowerCase()),
      );
      return adMatch || groupMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedules"),
        actions: [
          // 🔍 FILTER TOGGLE
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: showFilters ? Colors.blue : null,
            ),
            tooltip: "Filters",
            onPressed: () {
              setState(() => showFilters = !showFilters);
            },
          ),

          // ➕ CREATE
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Schedule",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateSchedulePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 SEARCH BOX
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by ad or group...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (v) => setState(() => searchText = v),
            ),
          ),

          // 🎛 FILTERS (HIDE / SHOW)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: showFilters
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text("From: ${provider.fromDate}"),
                          onPressed: () => _pickDate(context, isFrom: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text("To: ${provider.toDate}"),
                          onPressed: () => _pickDate(context, isFrom: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 🧹 CLEAR FILTERS
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text("Clear Filters"),
                      onPressed: provider.resetDateRange,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(),
          ),

          const Divider(),

          // 📋 LIST
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : filteredSchedules.isEmpty
                ? const Center(child: Text("No schedules found"))
                : RefreshIndicator(
                    onRefresh: provider.loadSchedules,
                    child: ListView.builder(
                      itemCount: filteredSchedules.length,
                      itemBuilder: (_, i) {
                        final ad = filteredSchedules[i];
                        final totalGroups = ad.groups.length;

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Expanded(child: Text(ad.adName)),

                                const SizedBox(width: 8),

                                // 🔹 Badge with tooltip showing total groups
                                Tooltip(
                                  message: ad.groups
                                      .map((g) => g.groupName)
                                      .join(", "),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "$totalGroups group${totalGroups > 1 ? 's' : ''}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // 🔹 Delete icon
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Delete Schedule",
                                  onPressed: () {
                                    // Navigate to delete page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DeleteSchedulePage(schedule: ad),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            subtitle: Text("Duration: ${ad.adDuration}s"),
                            children: ad.groups.map((g) {
                              return ListTile(
                                title: Text(g.groupName),
                                subtitle: Text("${g.fromDate} → ${g.toDate}"),
                                trailing: Text(g.completedPercentage),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
