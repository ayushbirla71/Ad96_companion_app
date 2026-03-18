import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';
import 'group_details_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  String searchText = "";

  Set<int> selectedIds = {};
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    context.read<GroupProvider>().loadGroups();
  }

  void toggleSelectAll(List<Group> groups) {
    setState(() {
      if (selectAll) {
        selectedIds.clear();
      } else {
        selectedIds = groups.map((g) => g.id).toSet();
      }

      selectAll = !selectAll;

      print("Selected IDs: $selectedIds");
    });
  }

  void toggleSelection(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }

      print("Selected IDs: $selectedIds");
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();

    final filteredGroups = provider.groups.where((group) {
      return group.name.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadGroups,
          ),
          IconButton(
            icon: Icon(
              selectAll ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            onPressed: () => toggleSelectAll(filteredGroups),
          ),
        ],
      ),
      body: Column(
        children: [
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
              onChanged: (v) => setState(() => searchText = v),
            ),
          ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: provider.loadGroups,
                    child: ListView.builder(
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

                            /// Checkbox instead of arrow
                            trailing: Checkbox(
                              value: selectedIds.contains(group.id),
                              onChanged: (value) {
                                toggleSelection(group.id);
                              },
                            ),

                            /// Tap also toggles selection
                            onTap: () {
                              toggleSelection(group.id);
                            },
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
