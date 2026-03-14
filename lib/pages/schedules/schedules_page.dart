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

  String searchText = "";

  String contentType = "all";

  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ScheduleProvider>().loadSchedules();
    });
  }

  /// SAFE DATE PARSER
  DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// SEARCH MATCH
  bool matchSearch(String name, List groups) {

    if (searchText.isEmpty) return true;

    final s = searchText.toLowerCase();

    if (name.toLowerCase().contains(s)) return true;

    for (var g in groups) {
      if (g.groupName.toLowerCase().contains(s)) {
        return true;
      }
    }

    return false;
  }

  /// DATE FILTER
  bool matchDate(List groups) {

    if (fromDate == null && toDate == null) return true;

    for (var g in groups) {

      final start = parseDate(g.fromDate);
      final end = parseDate(g.toDate);

      if (start == null || end == null) continue;

      if (fromDate != null && start.isBefore(fromDate!)) {
        return false;
      }

      if (toDate != null && end.isAfter(toDate!)) {
        return false;
      }
    }

    return true;
  }

  /// FILTER UI
  void openFilter() {

    showModalBottomSheet(
      context: context,
      builder: (_) {

        return StatefulBuilder(
          builder: (context, setModalState) {

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Filters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: contentType,
                    decoration: const InputDecoration(
                      labelText: "Content Type",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "ads", child: Text("Ads")),
                      DropdownMenuItem(value: "live", child: Text("Live Content")),
                      DropdownMenuItem(value: "carousel", child: Text("Carousels")),
                    ],
                    onChanged: (v) {
                      setModalState(() {
                        contentType = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    title: Text(
                      "From: ${fromDate != null ? fromDate!.toLocal().toString().split(" ")[0] : "Select"}",
                    ),
                    trailing: const Icon(Icons.date_range),
                    onTap: () async {

                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );

                      if (picked != null) {
                        setModalState(() {
                          fromDate = picked;
                        });
                      }
                    },
                  ),

                  ListTile(
                    title: Text(
                      "To: ${toDate != null ? toDate!.toLocal().toString().split(" ")[0] : "Select"}",
                    ),
                    trailing: const Icon(Icons.date_range),
                    onTap: () async {

                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );

                      if (picked != null) {
                        setModalState(() {
                          toDate = picked;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {

                            setState(() {
                              contentType = "all";
                              fromDate = null;
                              toDate = null;
                            });

                            Navigator.pop(context);
                          },
                          child: const Text("Clear"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// CARD UI
  Widget buildCard({
    required String title,
    required int duration,
    required List groups,
    required dynamic data,
  }) {

    final totalGroups = groups.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: ExpansionTile(
        title: Row(
          children: [

            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$totalGroups groups",
                style: const TextStyle(fontSize: 12),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeleteSchedulePage(schedule: data),
                  ),
                );
              },
            ),
          ],
        ),

        subtitle: Text("Duration: ${duration}s"),

        children: groups.map<Widget>((g) {

          return ListTile(
            title: Text(g.groupName),
            subtitle: Text("${g.fromDate} → ${g.toDate}"),
            trailing: Text(g.completedPercentage),
          );

        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<ScheduleProvider>();

    var ads = provider.ads
        .where((a) => matchSearch(a.adName, a.groups))
        .where((a) => matchDate(a.groups))
        .toList();

    var liveContents = provider.liveContents
        .where((l) => matchSearch(l.contentName, l.groups))
        .where((l) => matchDate(l.groups))
        .toList();

    var carousels = provider.carousels
        .where((c) => matchSearch(c.carouselName, c.groups))
        .where((c) => matchDate(c.groups))
        .toList();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Schedules"),
        actions: [

          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateSchedulePage(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [

          /// SEARCH + FILTER
          Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search schedules...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    onChanged: (v) {

                      Future.microtask(() {

                        setState(() {
                          searchText = v;
                        });

                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: openFilter,
                ),
              ],
            ),
          ),

          Expanded(

            child: provider.loading
                ? const Center(child: CircularProgressIndicator())

                : RefreshIndicator(
                    onRefresh: provider.loadSchedules,

                    child: ListView(
                      children: [

                        if ((contentType == "all" || contentType == "ads") &&
                            ads.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "Ads",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        if (contentType == "all" || contentType == "ads")
                          ...ads.map((ad) => buildCard(
                                title: ad.adName,
                                duration: ad.adDuration,
                                groups: ad.groups,
                                data: ad,
                              )),

                        if ((contentType == "all" || contentType == "live") &&
                            liveContents.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "Live Content",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        if (contentType == "all" || contentType == "live")
                          ...liveContents.map((live) => buildCard(
                                title: live.contentName,
                                duration: live.contentDuration,
                                groups: live.groups,
                                data: live,
                              )),

                        if ((contentType == "all" ||
                                contentType == "carousel") &&
                            carousels.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "Carousels",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        if (contentType == "all" ||
                            contentType == "carousel")
                          ...carousels.map((carousel) => buildCard(
                                title: carousel.contentName,
                                duration: carousel.carouselDuration,
                                groups: carousel.groups,
                                data: carousel,
                              )),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}