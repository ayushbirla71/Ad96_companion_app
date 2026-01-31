import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/dashboard_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);

    // Call all providers
    try {
      await Future.wait([
        context.read<AdProvider>().loadAds(),
        context.read<DeviceProvider>().loadDevices(),
        context.read<ScheduleProvider>().loadSchedules(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading dashboard: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<AdProvider>().ads.length;
    final activeAds = context.watch<AdProvider>().ads
        .where((ad) => ad.status == "completed") // Assuming your Ad model has isActive
        .length;
    final devices = context.watch<DeviceProvider>().devices.length;
    final schedules = context.watch<ScheduleProvider>().schedules.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  DashboardCard(
                    "Total Ads",
                    ads.toString(),
                    Icons.campaign,
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                    ),
                  ),
                  DashboardCard(
                    "Active Ads",
                    activeAds.toString(),
                    Icons.play_circle,
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                    ),
                  ),
                  DashboardCard(
                    "Devices",
                    devices.toString(),
                    Icons.tv,
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                  ),
                  DashboardCard(
                    "Schedules",
                    schedules.toString(),
                    Icons.schedule,
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
