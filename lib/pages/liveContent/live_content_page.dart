import 'package:cms_app/pages/liveContent/create_live_content_page.dart';
import 'package:flutter/material.dart';
import '../../models/liveContent.dart';
import '../../services/live_content_service.dart';
import 'live_content_details_page.dart';

class LiveContentPage extends StatefulWidget {
  const LiveContentPage({super.key});

  @override
  State<LiveContentPage> createState() => _LiveContentPageState();
}

class _LiveContentPageState extends State<LiveContentPage> {

  List<LiveContent> contents = [];
  List<LiveContent> filtered = [];

  String searchText = "";

  String statusFilter = "all";
  String typeFilter = "all";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadContents();
  }

  Future<void> loadContents() async {

    final data = await LiveContentService().fetchLiveContents();

    setState(() {
      contents = data;
      filtered = data;
      loading = false;
    });
  }

  /// APPLY FILTERS
  void applyFilters() {

    List<LiveContent> temp = List.from(contents);

    /// SEARCH
    if (searchText.isNotEmpty) {
      temp = temp.where((e) =>
          e.name.toLowerCase().contains(searchText.toLowerCase())).toList();
    }

    /// STATUS FILTER
    if (statusFilter != "all") {
      temp = temp.where((e) => e.status == statusFilter).toList();
    }

    /// TYPE FILTER
    if (typeFilter != "all") {
      temp = temp.where((e) => e.type == typeFilter).toList();
    }

    setState(() {
      filtered = temp;
    });
  }

  /// FILTER MODAL
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

                  /// STATUS FILTER
                  DropdownButtonFormField<String>(

                    value: statusFilter,

                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "active", child: Text("Active")),
                      DropdownMenuItem(value: "inactive", child: Text("Inactive")),
                    ],

                    onChanged: (v) {
                      setModalState(() {
                        statusFilter = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// TYPE FILTER
                  DropdownButtonFormField<String>(

                    value: typeFilter,

                    decoration: const InputDecoration(
                      labelText: "Content Type",
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "provider", child: Text("Provider")),
                      DropdownMenuItem(value: "streaming", child: Text("Streaming")),
                      DropdownMenuItem(value: "website", child: Text("Website")),
                    ],

                    onChanged: (v) {
                      setModalState(() {
                        typeFilter = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// BUTTONS
                  Row(
                    children: [

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {

                            setState(() {
                              statusFilter = "all";
                              typeFilter = "all";
                            });

                            applyFilters();

                            Navigator.pop(context);
                          },
                          child: const Text("Clear"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {

                            applyFilters();

                            Navigator.pop(context);
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// STATUS COLOR
  Color statusColor(String status) {
    if (status == "active") return Colors.green;
    return Colors.grey;
  }

  /// TYPE ICON
  IconData typeIcon(String type) {

    switch (type) {

      case "provider":
        return Icons.cloud;

      case "streaming":
        return Icons.live_tv;

      case "website":
        return Icons.language;

      default:
        return Icons.video_collection;
    }
  }

  /// DURATION TEXT
  String durationText(int seconds) {

    if (seconds == 0) return "Indefinite";

    final m = seconds ~/ 60;
    final s = seconds % 60;

    return "${m}m ${s}s";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

    appBar: AppBar(
  title: const Text("Live Content"),
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      tooltip: "Create Live Content",
      onPressed: () async {

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateLiveContentPage(),
          ),
        );

        /// refresh list after create
        if (result == true) {
          loadContents();
        }
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
                      hintText: "Search live content...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    onChanged: (v) {

                      setState(() {
                        searchText = v;
                      });

                      applyFilters();
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

            child: loading
                ? const Center(child: CircularProgressIndicator())

                : RefreshIndicator(

                    onRefresh: loadContents,

                    child: ListView.separated(

                      itemCount: filtered.length,

                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),

                      itemBuilder: (context, index) {

                        final item = filtered[index];

                        return ListTile(

                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),

                            child: Icon(
                              typeIcon(item.type),
                              color: Colors.blue,
                            ),
                          ),

                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Text(
                            "${item.type} • ${durationText(item.duration)}",
                          ),

                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),

                            decoration: BoxDecoration(
                              color: statusColor(item.status)
                                  .withOpacity(0.15),

                              borderRadius: BorderRadius.circular(6),
                            ),

                            child: Text(
                              item.status,

                              style: TextStyle(
                                color: statusColor(item.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          onTap: () {

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => LiveContentDetailsPage(
                                  content: item,
                                ),
                              ),
                            );
                          },
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