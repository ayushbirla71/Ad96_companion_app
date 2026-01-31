import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/group_provider.dart';
import 'add_device_step1.dart';
import 'device_details_page.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DeviceProvider>().loadDevices();
    context.read<GroupProvider>().loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final groupProvider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Devices"),
        actions: [
          // 🔄 REFRESH
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),

          // ➕ ADD DEVICE
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Device",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDeviceStep1Page()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH + FILTER TOGGLE
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search device...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: deviceProvider.setSearch,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: "Filters",
                  icon: Icon(
                    Icons.filter_list,
                    color: showFilters ? Colors.blue : null,
                  ),
                  onPressed: () {
                    setState(() => showFilters = !showFilters);
                  },
                ),
              ],
            ),
          ),

          // 🎛 FILTERS + CLEAR BUTTON
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: showFilters
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: deviceProvider.statusFilter,
                    decoration: const InputDecoration(labelText: "Status"),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "online", child: Text("Online")),
                      DropdownMenuItem(value: "offline", child: Text("Offline")),
                      DropdownMenuItem(value: "active", child: Text("Active")),
                    ],
                    onChanged: (v) => deviceProvider.setStatusFilter(v!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: deviceProvider.groupFilter,
                    decoration: const InputDecoration(labelText: "Group"),
                    items: [
                      const DropdownMenuItem(
                        value: "all",
                        child: Text("All Groups"),
                      ),
                      ...groupProvider.groups.map(
                        (g) =>
                            DropdownMenuItem(value: g.id, child: Text(g.name)),
                      ),
                    ],
                    onChanged: (v) => deviceProvider.setGroupFilter(v!),
                  ),

                  const SizedBox(height: 8),

                  // 🧹 CLEAR FILTERS
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text("Clear Filters"),
                      onPressed: () {
                        deviceProvider.clearFilters();
                      },
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(),
          ),

          const SizedBox(height: 8),

          // 📺 DEVICE LIST
          Expanded(
            child: Builder(
              builder: (_) {
                if (deviceProvider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (deviceProvider.error != null) {
                  return Center(child: Text(deviceProvider.error!));
                }

                if (deviceProvider.filteredDevices.isEmpty) {
                  return const Center(child: Text("No devices found"));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    itemCount: deviceProvider.filteredDevices.length,
                    itemBuilder: (_, i) {
                      final d = deviceProvider.filteredDevices[i];
                      final isOnline =
                          d.status == "online" || d.status == "active";

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: Icon(
                            Icons.tv,
                            color: isOnline ? Colors.green : Colors.red,
                          ),
                          title: Text(d.deviceName),
                          subtitle: Text("${d.groupName} • ${d.status}"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DeviceDetailsPage(device: d),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
