import 'package:cms_app/pages/carousel/carousels_page.dart';
import 'package:cms_app/pages/channel/channel_list_page.dart';
import 'package:cms_app/pages/liveContent/live_content_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/dashboard_card.dart';

import '../ads/ads_page.dart';
import '../devices/devices_page.dart';
import '../deviceGroups/device_groups_page.dart';
import '../schedules/schedules_page.dart';
import '../settings/settings_page.dart';

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

    try {
      await Future.wait([
        context.read<AdProvider>().loadAds(),
        context.read<DeviceProvider>().loadDevices(),
        context.read<ScheduleProvider>().loadSchedules(),
      ]);
    } finally {
      setState(() => loading = false);
    }
  }

  void navigate(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<AdProvider>().ads.length;
    final activeAds = context.watch<AdProvider>()
        .ads
        .where((ad) => ad.status == "completed")
        .length;

    final devices = context.watch<DeviceProvider>().devices.length;
   final provider = context.watch<ScheduleProvider>();

final schedules =
    provider.ads.length +
    provider.liveContents.length +
    provider.carousels.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CMS Dashboard"),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Greeting
                    const Text(
                      "Welcome Back 👋",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Manage your digital signage easily",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    /// Stats Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
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

                    const SizedBox(height: 25),

                    /// Quick Actions
                    const Text(
                      "Quick Actions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      children: [

                        _QuickAction(
                          icon: Icons.campaign,
                          label: "Ads",
                          onTap: () => navigate(const AdsPage()),
                        ),

                        _QuickAction(
                          icon: Icons.tv,
                          label: "Devices",
                          onTap: () => navigate(const DevicesPage()),
                        ),

                        _QuickAction(
                          icon: Icons.group,
                          label: "Groups",
                          onTap: () => navigate(const GroupsPage()),
                        ),

                        _QuickAction(
                          icon: Icons.schedule,
                          label: "Schedule",
                          onTap: () => navigate(const SchedulesPage()),
                        ),

                        _QuickAction(
                          icon: Icons.analytics,
                          label: "Reports",
                          onTap: () {},
                        ),

                        _QuickAction(
                          icon: Icons.analytics,
                          label: "Reports",
                         onTap: () => navigate(const CarouselPage()),
                        ),

                        _QuickAction(
                          icon: Icons.live_tv,
                          label: "Live",
                          onTap: () => navigate(const ChannelListPage()),
                        ),

                        _QuickAction(
                          icon: Icons.live_tv,
                          label: "Live Content",
                          onTap: () => navigate(const LiveContentPage()),
                        ),

                        _QuickAction(
                          icon: Icons.settings,
                          label: "Settings",
                          onTap: () => navigate(const SettingsPage()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// Info Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.indigo),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Tip: Keep your devices online to ensure ads run smoothly.",
                              style: TextStyle(fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.indigo.shade50,
            child: Icon(icon, color: Colors.indigo),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }
}