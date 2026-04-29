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
  @override
  void initState() {
    super.initState();

    // 🔥 FIX: Replaced Future.microtask with addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<DeviceProvider>().loadDevices();
    context.read<GroupProvider>().loadGroups();
  }

  /// FILTER UI
  void openFilter() {
    final deviceProvider = context.read<DeviceProvider>();
    final groupProvider = context.read<GroupProvider>();

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

                  /// STATUS
                  DropdownButtonFormField<String>(
                    value: deviceProvider.statusFilter,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "active", child: Text("Online")),
                      DropdownMenuItem(value: "offline", child: Text("Offline")),
                      // DropdownMenuItem(value: "active", child: Text("Active")),
                    ],
                    onChanged: (v) {
                      setModalState(() {
                        deviceProvider.setStatusFilter(v!);
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  /// GROUP
                  DropdownButtonFormField<String>(
                    value: deviceProvider.groupFilter,
                    decoration: const InputDecoration(
                      labelText: "Group",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: "all",
                        child: Text("All Groups"),
                      ),
                      ...groupProvider.groups.map(
                        (g) => DropdownMenuItem(
                          value: g.id,
                          child: Text(g.name),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setModalState(() {
                        deviceProvider.setGroupFilter(v!);
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      /// CLEAR
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            deviceProvider.clearFilters();
                            Navigator.pop(context);
                          },
                          child: const Text("Clear"),
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// APPLY
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // setState(() {}); is not needed here as Provider updates the UI automatically
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

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Devices"),
        actions: [
          /// REFRESH
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),

          /// ADD DEVICE
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Device",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddDeviceStep1Page(),
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
                      hintText: "Search device...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (v) {
                       // 🔥 Using microtask inside onChanged is fine, but not strictly necessary 
                       // unless you are avoiding a specific textfield stutter. 
                       Future.microtask(() {
                         deviceProvider.setSearch(v);
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

          /// DEVICE LIST
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
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isOnline ? Colors.green : Colors.red,
                            child: const Icon(
                              Icons.tv,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            d.deviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "${d.groupName} • ${d.status}",
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DeviceDetailsPage(device: d),
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