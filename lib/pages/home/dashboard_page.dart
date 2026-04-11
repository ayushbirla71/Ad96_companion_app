// import 'package:cms_app/pages/carousel/carousels_page.dart';
// import 'package:cms_app/pages/channel/channel_list_page.dart';
// import 'package:cms_app/pages/liveContent/live_content_page.dart';
import 'package:cms_app/pages/subscription/feature_not_available_page.dart';
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<AdProvider>().ads.length;
    final activeAds = context
        .watch<AdProvider>()
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: const CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                          icon: Icons.group_work,
                          label: "Groups",
                          onTap: () => navigate(const GroupsPage()),
                        ),

                        _QuickAction(
                          icon: Icons.event_note,
                          label: "Schedule",
                          onTap: () => navigate(const SchedulesPage()),
                        ),

                        _QuickAction(
                          icon: Icons.bar_chart,
                          label: "Reports",
                         onTap: () => navigate(const FeatureNotAvailablePage()),
                          
                        ),

                        _QuickAction(
                          icon: Icons.view_carousel,
                          label: "Carousels",
                          // onTap: () => navigate(const CarouselPage()),
                          onTap: () => navigate(const FeatureNotAvailablePage()),
                        ),

                        _QuickAction(
                          icon: Icons.live_tv,
                          label: "Channels",
                          // onTap: () => navigate(const ChannelListPage()),
                            onTap: () => navigate(const FeatureNotAvailablePage()),
                        ),

                        _QuickAction(
                          icon: Icons.stream,
                          label: "Live Content",
                          // onTap: () => navigate(const LiveContentPage()),
                            onTap: () => navigate(const FeatureNotAvailablePage()),
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
                          ),
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
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// import '../ads/ads_page.dart';
// import '../devices/devices_page.dart';
// import '../deviceGroups/device_groups_page.dart';
// import '../schedules/schedules_page.dart';
// import '../settings/settings_page.dart';
// import '../channel/channel_list_page.dart';
// import '../carousel/carousels_page.dart';
// import '../liveContent/live_content_page.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   bool loading = true;

//   final Map<String, dynamic> dashboardData = {
//     "totalImpressions": 12000,
//     "adsScheduledInRange": 35,
//     "activeDevicesInRange": 12,
//     "networkIssues": 2,
//     "storageIssues": 1,
//     "deviceCrashes": 3,
//     "playbackErrors": 2,
//     "systemHealth": {
//       "avgCpuUsage": 78,
//       "avgRamFree": 45,
//       "avgStorageFree": 60,
//       "networkHealth": 85
//     },
//     "performanceOutliers": [
//       {
//         "device_name": "Everest G L2",
//         "metric": "CPU Usage",
//         "value": "100%",
//       },
//       {
//         "device_name": "Kailash B1 L4",
//         "metric": "CPU Usage",
//         "value": "96%",
//       }
//     ]
//   };

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 800), () {
//       setState(() => loading = false);
//     });
//   }

//   int getInt(String key) {
//     final value = dashboardData[key];
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? 0;
//     return 0;
//   }

//   Map<String, dynamic> getSystemHealth() {
//     final value = dashboardData["systemHealth"];
//     return value is Map<String, dynamic> ? value : {};
//   }

//   List<dynamic> getOutliers() {
//     final value = dashboardData["performanceOutliers"];
//     return value is List ? value : [];
//   }

//   void navigate(Widget page) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final system = getSystemHealth();
//     final outliers = getOutliers();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Dashboard"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () => navigate(const SettingsPage()),
//           )
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: () async {},
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     /// HEADER
//                     const Text(
//                       "Welcome Back 👋",
//                       style: TextStyle(
//                           fontSize: 22, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       "Live Monitoring Dashboard",
//                       style: TextStyle(color: Colors.grey),
//                     ),

//                     const SizedBox(height: 20),

//                     /// 🔥 QUICK ACTIONS (TOP)
//                     const Text(
//                       "Quick Actions",
//                       style: TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),

//                     Wrap(
//                       spacing: 20,
//                       runSpacing: 20,
//                       children: [
//                         _QuickAction(Icons.campaign, "Ads",
//                             () => navigate(const AdsPage())),
//                         _QuickAction(Icons.tv, "Devices",
//                             () => navigate(const DevicesPage())),
//                         _QuickAction(Icons.group, "Groups",
//                             () => navigate(const GroupsPage())),
//                         _QuickAction(Icons.schedule, "Schedule",
//                             () => navigate(const SchedulesPage())),
//                         _QuickAction(Icons.view_carousel, "Carousels",
//                             () => navigate(const CarouselPage())),
//                         _QuickAction(Icons.live_tv, "Channels",
//                             () => navigate(const ChannelListPage())),
//                         _QuickAction(Icons.stream, "Live",
//                             () => navigate(const LiveContentPage())),
//                         _QuickAction(Icons.settings, "Settings",
//                             () => navigate(const SettingsPage())),
//                       ],
//                     ),

//                     const SizedBox(height: 25),

//                     /// STATS
//                     Wrap(
//                       spacing: 12,
//                       runSpacing: 12,
//                       children: [
//                         _StatCard("Impressions",
//                             getInt("totalImpressions"), Icons.visibility),
//                         _StatCard("Scheduled Ads",
//                             getInt("adsScheduledInRange"),
//                             Icons.campaign),
//                         _StatCard("Devices",
//                             getInt("activeDevicesInRange"), Icons.tv),
//                         _StatCard("Errors",
//                             getInt("playbackErrors"), Icons.error),
//                       ],
//                     ),

//                     const SizedBox(height: 25),

//                     /// BAR CHART
//                     const Text(
//                       "Performance Overview",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),

//                     SizedBox(
//                       height: 220,
//                       child: BarChart(
//                         BarChartData(
//                           alignment: BarChartAlignment.spaceAround,
//                           titlesData: FlTitlesData(
//                             bottomTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 getTitlesWidget: (value, _) {
//                                   switch (value.toInt()) {
//                                     case 0:
//                                       return const Text("Ads");
//                                     case 1:
//                                       return const Text("Devices");
//                                     case 2:
//                                       return const Text("Errors");
//                                   }
//                                   return const Text("");
//                                 },
//                               ),
//                             ),
//                           ),
//                           barGroups: [
//                             BarChartGroupData(x: 0, barRods: [
//                               BarChartRodData(
//                                   toY: getInt("adsScheduledInRange")
//                                       .toDouble())
//                             ]),
//                             BarChartGroupData(x: 1, barRods: [
//                               BarChartRodData(
//                                   toY: getInt("activeDevicesInRange")
//                                       .toDouble())
//                             ]),
//                             BarChartGroupData(x: 2, barRods: [
//                               BarChartRodData(
//                                   toY:
//                                       getInt("playbackErrors").toDouble())
//                             ]),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 25),

//                     /// LINE CHART
//                     const Text(
//                       "CPU Usage Trend",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),

//                     SizedBox(
//                       height: 220,
//                       child: LineChart(
//                         LineChartData(
//                           gridData: FlGridData(show: true),
//                           borderData: FlBorderData(show: true),
//                           lineBarsData: [
//                             LineChartBarData(
//                               isCurved: true,
//                               spots: [
//                                 FlSpot(0, 30),
//                                 FlSpot(1, 50),
//                                 FlSpot(2, 70),
//                                 FlSpot(3, 60),
//                                 FlSpot(4, 80),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 25),

//                     /// PIE CHART
//                     const Text(
//                       "Error Distribution",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),

//                     SizedBox(
//                       height: 220,
//                       child: PieChart(
//                         PieChartData(
//                           sections: [
//                             PieChartSectionData(
//                                 value: getInt("networkIssues").toDouble(),
//                                 title: "Network"),
//                             PieChartSectionData(
//                                 value: getInt("storageIssues").toDouble(),
//                                 title: "Storage"),
//                             PieChartSectionData(
//                                 value: getInt("deviceCrashes").toDouble(),
//                                 title: "Crash"),
//                             PieChartSectionData(
//                                 value: getInt("playbackErrors").toDouble(),
//                                 title: "Playback"),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 25),

//                     /// OUTLIERS
//                     const Text(
//                       "Critical Devices",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),

//                     ...outliers.map((item) {
//                       return Card(
//                         child: ListTile(
//                           leading:
//                               const Icon(Icons.warning, color: Colors.red),
//                           title: Text(item["device_name"] ?? ""),
//                           subtitle: Text(
//                               "${item["metric"]} → ${item["value"]}"),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

// /// STAT CARD
// class _StatCard extends StatelessWidget {
//   final String title;
//   final int value;
//   final IconData icon;

//   const _StatCard(this.title, this.value, this.icon);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: (MediaQuery.of(context).size.width / 2) - 24,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(14),
//         color: Colors.grey.shade200,
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(child: Icon(icon)),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title),
//               Text(value.toString(),
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold)),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// /// QUICK ACTION
// class _QuickAction extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _QuickAction(this.icon, this.label, this.onTap);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(50),
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(radius: 24, child: Icon(icon)),
//           const SizedBox(height: 6),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }