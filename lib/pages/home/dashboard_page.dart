// import 'package:cms_app/pages/carousel/carousels_page.dart';
// import 'package:cms_app/pages/channel/channel_list_page.dart';
// import 'package:cms_app/pages/liveContent/live_content_page.dart';
// import 'package:cms_app/pages/subscription/feature_not_available_page.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/ad_provider.dart';
// import '../../providers/device_provider.dart';
// import '../../providers/schedule_provider.dart';
// import '../../widgets/dashboard_card.dart';

// import '../ads/ads_page.dart';
// import '../devices/devices_page.dart';
// import '../deviceGroups/device_groups_page.dart';
// import '../schedules/schedules_page.dart';
// import '../settings/settings_page.dart';
// import '../../utils/feature_access.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => loading = true);

//     try {
//       await Future.wait([
//         context.read<AdProvider>().loadAds(),
//         context.read<DeviceProvider>().loadDevices(),
//         context.read<ScheduleProvider>().loadSchedules(),
//       ]);
//     } finally {
//       setState(() => loading = false);
//     }
//   }

//   void navigate(Widget page) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ads = context.watch<AdProvider>().ads.length;
//     final activeAds = context
//         .watch<AdProvider>()
//         .ads
//         .where((ad) => ad.status == "completed")
//         .length;

//     final devices = context.watch<DeviceProvider>().devices.length;
//     final provider = context.watch<ScheduleProvider>();

//     final schedules =
//         provider.ads.length +
//         provider.liveContents.length +
//         provider.carousels.length;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("CMS Dashboard"),
//         elevation: 0,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 10),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const SettingsPage()),
//                 );
//               },
//               child: const CircleAvatar(child: Icon(Icons.person)),
//             ),
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadData,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// Greeting
//                     const Text(
//                       "Welcome Back 👋",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 4),

//                     const Text(
//                       "Manage your digital signage easily",
//                       style: TextStyle(color: Colors.grey),
//                     ),

//                     const SizedBox(height: 20),

//                     /// Stats Cards
//                     GridView.count(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisCount: 2,
//                       childAspectRatio: 1.3,
//                       crossAxisSpacing: 12,
//                       mainAxisSpacing: 12,
//                       children: [
//                         DashboardCard(
//                           "Total Ads",
//                           ads.toString(),
//                           Icons.campaign,
//                           gradient: const LinearGradient(
//                             colors: [Colors.blue, Colors.blueAccent],
//                           ),
//                         ),
//                         DashboardCard(
//                           "Active Ads",
//                           activeAds.toString(),
//                           Icons.play_circle,
//                           gradient: const LinearGradient(
//                             colors: [Colors.green, Colors.lightGreen],
//                           ),
//                         ),
//                         DashboardCard(
//                           "Devices",
//                           devices.toString(),
//                           Icons.tv,
//                           gradient: const LinearGradient(
//                             colors: [Colors.orange, Colors.deepOrange],
//                           ),
//                         ),
//                         DashboardCard(
//                           "Schedules",
//                           schedules.toString(),
//                           Icons.schedule,
//                           gradient: const LinearGradient(
//                             colors: [Colors.purple, Colors.deepPurple],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 25),

//                     /// Quick Actions
//                     const Text(
//                       "Quick Actions",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     GridView.count(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisCount: 4,
//                       children: [
//                         _QuickAction(
//                           icon: Icons.campaign,
//                           label: "Ads",
//                           onTap: () => navigate(const AdsPage()),
//                         ),

//                         _QuickAction(
//                           icon: Icons.tv,
//                           label: "Devices",
//                           onTap: () => navigate(const DevicesPage()),
//                         ),

//                         _QuickAction(
//                           icon: Icons.group_work,
//                           label: "Groups",
//                           onTap: () => navigate(const GroupsPage()),
//                         ),

//                         _QuickAction(
//                           icon: Icons.event_note,
//                           label: "Schedule",
//                           onTap: () => navigate(const SchedulesPage()),
//                         ),

//                         _QuickAction(
//                           icon: Icons.bar_chart,
//                           label: "Reports",
//                           onTap: () {},
//                         ),

//                         _QuickAction(
//                           icon: Icons.view_carousel,
//                           label: "Carousels",
//                           onTap: () => navigate(const CarouselPage()),
//                         ),

//                         // _QuickAction(
//                         //   icon: Icons.live_tv,
//                         //   label: "Channels",
//                         //   onTap: () => navigate(const ChannelListPage()),
//                         // ),

//                         // _QuickAction(
//                         //   icon: Icons.live_tv,
//                         //   label: "Channels",
//                         //   onTap: () {
//                         //     FeatureAccess.openFeature(
//                         //       context: context,
//                         //       featureKey: "LIVE_STREAMING",
//                         //       page: const ChannelListPage(),
//                         //     );
//                         //   },
//                         // ),
//                         _QuickAction(
//                           icon: Icons.stream,
//                           label: "Live Content",
//                           onTap: () => navigate(const LiveContentPage()),
//                         ),

//                         // _QuickAction(
//                         //   icon: Icons.stream,
//                         //   label: "Live Content",
//                         //   onTap: () {
//                         //     FeatureAccess.openFeature(
//                         //       context: context,
//                         //       featureKey: "LIVE_IN_LAYOUT",
//                         //       page: const LiveContentPage(),
//                         //     );
//                         //   },
//                         // ),
//                         _QuickAction(
//                           icon: Icons.settings,
//                           label: "Settings",
//                           onTap: () => navigate(const SettingsPage()),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 25),

//                     /// Info Section
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.indigo.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(Icons.info_outline, color: Colors.indigo),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               "Tip: Keep your devices online to ensure ads run smoothly.",
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

// class _QuickAction extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _QuickAction({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.indigo.shade50,
//             child: Icon(icon, color: Colors.indigo),
//           ),
//           const SizedBox(height: 6),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:cms_app/services/api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

// import '../../providers/ad_provider.dart';
// import '../../providers/device_provider.dart';
// import '../../providers/schedule_provider.dart';

// import '../ads/ads_page.dart';
// import '../carousel/carousels_page.dart';
// import '../devices/devices_page.dart';
// import '../deviceGroups/device_groups_page.dart';
// import '../liveContent/live_content_page.dart';
// import '../schedules/schedules_page.dart';
// import '../settings/settings_page.dart';
// import '../exports/export_details_page.dart';

// // ─── Data models ──────────────────────────────────────────────────────────────

// class DashboardStats {
//   final int totalImpressions;
//   final int adsScheduled;
//   final int activeDevices;
//   final int diagnosticErrors;
//   final double avgCpu;
//   final double avgRamFree;
//   final double avgStorageFree;
//   final double networkHealth;
//   final List<PerformanceOutlier> outliers;
//   final List<RecentEvent> recentEvents;

//   const DashboardStats({
//     required this.totalImpressions,
//     required this.adsScheduled,
//     required this.activeDevices,
//     required this.diagnosticErrors,
//     required this.avgCpu,
//     required this.avgRamFree,
//     required this.avgStorageFree,
//     required this.networkHealth,
//     required this.outliers,
//     required this.recentEvents,
//   });

//   factory DashboardStats.fromJson(Map<String, dynamic> json) {
//     final d = json['data'] as Map<String, dynamic>;
//     final health = d['systemHealth'] as Map<String, dynamic>;
//     return DashboardStats(
//       totalImpressions: (d['totalImpressions'] ?? 0) as int,
//       adsScheduled: (d['adsScheduledInRange'] ?? 0) as int,
//       activeDevices: (d['activeDevicesInRange'] ?? 0) as int,
//       diagnosticErrors: (d['diagnosticErrors'] ?? 0) as int,
//       avgCpu: (health['avgCpuUsage'] ?? 0.0).toDouble(),
//       avgRamFree: (health['avgRamFree'] ?? 0.0).toDouble(),
//       avgStorageFree: (health['avgStorageFree'] ?? 0.0).toDouble(),
//       networkHealth: (health['networkHealth'] ?? 0.0).toDouble(),
//       outliers: (d['performanceOutliers'] as List<dynamic>? ?? [])
//           .map((e) => PerformanceOutlier.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       recentEvents: (d['recentEvents'] as List<dynamic>? ?? [])
//           .map((e) => RecentEvent.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }

// class PerformanceOutlier {
//   final String deviceName;
//   final String metric;
//   final String value;
//   final String severity;

//   const PerformanceOutlier({
//     required this.deviceName,
//     required this.metric,
//     required this.value,
//     required this.severity,
//   });

//   factory PerformanceOutlier.fromJson(Map<String, dynamic> j) =>
//       PerformanceOutlier(
//         deviceName: j['device_name'] as String? ?? '',
//         metric: j['metric'] as String? ?? '',
//         value: j['value'] as String? ?? '',
//         severity: j['severity'] as String? ?? '',
//       );
// }

// class RecentEvent {
//   final String device;
//   final String eventType;
//   final DateTime timestamp;

//   const RecentEvent({
//     required this.device,
//     required this.eventType,
//     required this.timestamp,
//   });

//   factory RecentEvent.fromJson(Map<String, dynamic> j) => RecentEvent(
//     device: j['device'] as String? ?? '',
//     eventType: j['event_type'] as String? ?? '',
//     timestamp:
//         DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(),
//   );
// }

// // ─── Colour palette ────────────────────────────────────────────────────────────

// // const _bg = Color(0xFF0D1117);
// // const _surface = Color(0xFF161B22);
// // const _surfaceHigh = Color(0xFF21262D);
// const _accent = Color(0xFF58A6FF);
// const _accentGreen = Color(0xFF3FB950);
// const _accentOrange = Color(0xFFF78166);
// const _accentYellow = Color(0xFFE3B341);
// const _accentPurple = Color(0xFFBC8CFF);
// // const _textPrimary = Color(0xFFE6EDF3);
// // const _textMuted = Color(0xFF8B949E);
// const _bg = Color(0xFFF5F5F5);

// const _surface = Color(0xFFFFFFFF);

// const _surfaceHigh = Color(0xFFF1F3F5);

// const _textPrimary = Color(0xFF1F2937);

// const _textMuted = Color(0xFF6B7280);

// // ─── Page ──────────────────────────────────────────────────────────────────────

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   bool _loading = true;
//   DashboardStats? _stats;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadAll();
//   }

//   Future<void> _loadAll() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       await Future.wait([
//         _fetchStats(),
//         context.read<AdProvider>().loadAds(),
//         context.read<DeviceProvider>().loadDevices(),
//         context.read<ScheduleProvider>().loadSchedules(),
//       ]);
//     } catch (e) {
//       if (mounted) setState(() => _error = e.toString());
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _fetchStats() async {
//     final now = DateTime.now();
//     final start = '${now.year}-${_pad(now.month)}-01';
//     final end = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';

//     final res = await ApiService.get(
//       '/dashboard/stats?startDate=$start&endDate=$end',
//     );
//     if (res.statusCode == 200) {
//       final json = jsonDecode(res.body) as Map<String, dynamic>;
//       if (mounted) setState(() => _stats = DashboardStats.fromJson(json));
//     } else {
//       throw Exception('API error ${res.statusCode}');
//     }
//   }

//   String _pad(int n) => n.toString().padLeft(2, '0');

//   void _go(Widget page) =>
//       Navigator.push(context, MaterialPageRoute(builder: (_) => page));

//   String _fmt(int n) {
//     if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
//     if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
//     return n.toString();
//   }

//   String _timeAgo(DateTime dt) {
//     final d = DateTime.now().difference(dt);
//     if (d.inMinutes < 1) return 'just now';
//     if (d.inHours < 1) return '${d.inMinutes}m ago';
//     if (d.inDays < 1) return '${d.inHours}h ago';
//     return '${d.inDays}d ago';
//   }

//   // ─── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: _bg,
//         colorScheme: const ColorScheme.dark(
//           primary: _accent,
//           surface: _surface,
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: _bg,
//         appBar: _appBar(),
//         body: _loading
//             ? _loader()
//             : _error != null
//             ? _errorView()
//             : RefreshIndicator(
//                 color: _accent,
//                 backgroundColor: _surface,
//                 onRefresh: _loadAll,
//                 child: _body(),
//               ),
//       ),
//     );
//   }

//   PreferredSizeWidget _appBar() => AppBar(
//     backgroundColor: _surface,
//     elevation: 0,
//     title: Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: _accent.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.dashboard_rounded, color: _accent, size: 17),
//         ),
//         const SizedBox(width: 10),
//         const Text(
//           'CMS Dashboard',
//           style: TextStyle(
//             color: _textPrimary,
//             fontSize: 17,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.2,
//           ),
//         ),
//       ],
//     ),
//     actions: [
//       GestureDetector(
//         onTap: () => _go(const SettingsPage()),
//         child: Container(
//           margin: const EdgeInsets.only(right: 14),
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: _surfaceHigh,
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white12),
//           ),
//           child: const Icon(
//             Icons.person_outline,
//             color: _textPrimary,
//             size: 20,
//           ),
//         ),
//       ),
//     ],
//     bottom: PreferredSize(
//       preferredSize: const Size.fromHeight(1),
//       child: Container(height: 1, color: Colors.white10),
//     ),
//   );

//   Widget _loader() => const Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CircularProgressIndicator(color: _accent, strokeWidth: 2),
//         SizedBox(height: 16),
//         Text('Loading…', style: TextStyle(color: _textMuted, fontSize: 13)),
//       ],
//     ),
//   );

//   Widget _errorView() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.cloud_off_rounded, color: _accentOrange, size: 48),
//           const SizedBox(height: 12),
//           const Text(
//             'Could not load stats',
//             style: TextStyle(
//               color: _textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _error ?? '',
//             style: const TextStyle(color: _textMuted, fontSize: 12),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _loadAll,
//             icon: const Icon(Icons.refresh_rounded, size: 16),
//             label: const Text('Retry'),
//             style: ElevatedButton.styleFrom(backgroundColor: _accent),
//           ),
//         ],
//       ),
//     ),
//   );

//   Widget _body() {
//     final s = _stats;
//     final now = DateTime.now();
//     return SingleChildScrollView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Greeting
//           const Text(
//             'Welcome Back 👋',
//             style: TextStyle(
//               color: _textPrimary,
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'May 1 – May ${now.day}, ${now.year}',
//             style: const TextStyle(color: _textMuted, fontSize: 12),
//           ),
//           const SizedBox(height: 20),

//           // Hero impressions
//           if (s != null) _heroCard(s),
//           const SizedBox(height: 14),

//           // 4-stat grid
//           if (s != null) _statGrid(s),
//           const SizedBox(height: 22),

//           // System health
//           if (s != null) ...[
//             _sectionLabel('System Health'),
//             const SizedBox(height: 10),
//             _healthRow(s),
//             const SizedBox(height: 22),
//           ],

//           // Quick Actions
//           _sectionLabel('Quick Actions'),
//           const SizedBox(height: 10),
//           _quickActions(),
//           const SizedBox(height: 22),

//           // Critical devices
//           if (s != null && s.outliers.isNotEmpty) ...[
//             _sectionLabel(
//               'Critical Devices',
//               badge: s.outliers.length.toString(),
//               badgeColor: _accentOrange,
//             ),
//             const SizedBox(height: 10),
//             _outlierList(s.outliers),
//             const SizedBox(height: 22),
//           ],

//           // Recent events
//           if (s != null && s.recentEvents.isNotEmpty) ...[
//             _sectionLabel('Recent Events'),
//             const SizedBox(height: 10),
//             _recentEvents(s.recentEvents),
//           ],
//         ],
//       ),
//     );
//   }

//   // ─── Hero card ─────────────────────────────────────────────────────────────

//   Widget _heroCard(DashboardStats s) => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [_accent.withOpacity(0.18), _accent.withOpacity(0.04)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: _accent.withOpacity(0.3)),
//     ),
//     child: Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'TOTAL IMPRESSIONS',
//                 style: TextStyle(
//                   color: _textMuted,
//                   fontSize: 11,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 _fmt(s.totalImpressions),
//                 style: const TextStyle(
//                   color: _textPrimary,
//                   fontSize: 38,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -1.5,
//                   height: 1,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   const Icon(Icons.circle, color: _accentGreen, size: 8),
//                   const SizedBox(width: 6),
//                   Text(
//                     '${_fmt(s.adsScheduled)} ads  •  ${s.activeDevices} devices active',
//                     style: const TextStyle(color: _textMuted, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: _accent.withOpacity(0.12),
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(Icons.visibility_rounded, color: _accent, size: 30),
//         ),
//       ],
//     ),
//   );

//   // ─── 4-stat grid ───────────────────────────────────────────────────────────

//   Widget _statGrid(DashboardStats s) => GridView.count(
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     crossAxisCount: 2,
//     crossAxisSpacing: 12,
//     mainAxisSpacing: 12,
//     childAspectRatio: MediaQuery.of(context).size.width < 380 ? 1.05 : 1.25,
//     children: [
//       _StatTile(
//         icon: Icons.campaign_rounded,
//         label: 'Ads Scheduled',
//         value: _fmt(s.adsScheduled),
//         color: const Color(0xFF79C0FF),
//       ),
//       _StatTile(
//         icon: Icons.tv_rounded,
//         label: 'Active Devices',
//         value: s.activeDevices.toString(),
//         color: _accentGreen,
//       ),
//       _StatTile(
//         icon: Icons.warning_amber_rounded,
//         label: 'Diagnostic Errors',
//         value: _fmt(s.diagnosticErrors),
//         color: _accentOrange,
//       ),
//       _StatTile(
//         icon: Icons.wifi_rounded,
//         label: 'Network Health',
//         value: '${s.networkHealth.toStringAsFixed(1)}%',
//         color: _accentYellow,
//       ),
//     ],
//   );

//   // ─── System health bars ────────────────────────────────────────────────────

//   Widget _healthRow(DashboardStats s) => Column(
//     children: [
//       _HealthBar(
//         label: 'CPU',
//         value: s.avgCpu / 100,
//         displayText: '${s.avgCpu.toStringAsFixed(1)}%',
//         color: s.avgCpu > 70 ? _accentOrange : _accentGreen,
//       ),

//       const SizedBox(height: 10),

//       _HealthBar(
//         label: 'RAM Free',
//         value: (s.avgRamFree / 512).clamp(0, 1),
//         displayText: '${s.avgRamFree.toStringAsFixed(0)} MB',
//         color: _accent,
//       ),

//       const SizedBox(height: 10),

//       _HealthBar(
//         label: 'Storage',
//         value: (s.avgStorageFree / 4096).clamp(0, 1),
//         displayText: '${(s.avgStorageFree / 1024).toStringAsFixed(1)} GB',
//         color: _accentPurple,
//       ),
//     ],
//   );

//   // ─── Quick actions ─────────────────────────────────────────────────────────

//   Widget _quickActions() => Container(
//     padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
//     decoration: BoxDecoration(
//       color: _surface,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: Colors.white10),
//     ),
//     child: GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 4,
//       childAspectRatio: 0.9,
//       children: [
//         _QAction(
//           icon: Icons.campaign_rounded,
//           label: 'Ads',
//           color: const Color(0xFF79C0FF),
//           onTap: () => _go(const AdsPage()),
//         ),
//         _QAction(
//           icon: Icons.tv_rounded,
//           label: 'Devices',
//           color: _accentGreen,
//           onTap: () => _go(const DevicesPage()),
//         ),
//         _QAction(
//           icon: Icons.group_work_rounded,
//           label: 'Groups',
//           color: _accentPurple,
//           onTap: () => _go(const GroupsPage()),
//         ),
//         _QAction(
//           icon: Icons.event_note_rounded,
//           label: 'Schedule',
//           color: _accentYellow,
//           onTap: () => _go(const SchedulesPage()),
//         ),

//         _QAction(
//           icon: Icons.bar_chart_rounded,
//           label: 'Reports',
//           color: _textMuted,
//           onTap: () => _go(const ExportDetailsPage()),
//         ),
//         _QAction(
//           icon: Icons.view_carousel_rounded,
//           label: 'Carousels',
//           color: const Color(0xFFFFA657),
//           onTap: () => _go(const CarouselPage()),
//         ),
//         _QAction(
//           icon: Icons.stream_rounded,
//           label: 'Live',
//           color: _accentOrange,
//           onTap: () => _go(const LiveContentPage()),
//         ),
//         _QAction(
//           icon: Icons.settings_rounded,
//           label: 'Settings',
//           color: _textMuted,
//           onTap: () => _go(const SettingsPage()),
//         ),
//       ],
//     ),
//   );

//   // ─── Outlier list ──────────────────────────────────────────────────────────

//   Widget _outlierList(List<PerformanceOutlier> items) {
//     final seen = <String>{};
//     final unique = items
//         .where((e) => seen.add('${e.deviceName}|${e.value}'))
//         .take(5)
//         .toList();

//     return Column(
//       children: unique.map((e) {
//         final pct = int.tryParse(e.value.replaceAll('%', '')) ?? 0;
//         final color = pct >= 95
//             ? const Color(0xFFFF6B6B)
//             : pct >= 90
//             ? _accentOrange
//             : _accentYellow;
//         return Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           decoration: BoxDecoration(
//             color: _surface,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: color.withOpacity(0.25)),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(7),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.memory_rounded, color: color, size: 16),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       e.deviceName,
//                       style: const TextStyle(
//                         color: _textPrimary,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       e.metric,
//                       style: const TextStyle(color: _textMuted, fontSize: 11),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   e.value,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ─── Recent events ─────────────────────────────────────────────────────────

//   Widget _recentEvents(List<RecentEvent> events) {
//     final items = events.take(8).toList();
//     return Container(
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white10),
//       ),
//       child: Column(
//         children: items.asMap().entries.map((entry) {
//           final i = entry.key;
//           final e = entry.value;
//           final isLast = i == items.length - 1;
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 11,
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: const BoxDecoration(
//                         color: _accentYellow,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             e.device,
//                             style: const TextStyle(
//                               color: _textPrimary,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             e.eventType.replaceAll('_', ' '),
//                             style: const TextStyle(
//                               color: _textMuted,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       _timeAgo(e.timestamp),
//                       style: const TextStyle(color: _textMuted, fontSize: 11),
//                     ),
//                   ],
//                 ),
//               ),
//               if (!isLast)
//                 const Divider(height: 1, color: Colors.white10, indent: 34),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // ─── Helpers ───────────────────────────────────────────────────────────────

//   Widget _sectionLabel(String text, {String? badge, Color? badgeColor}) => Row(
//     children: [
//       Text(
//         text,
//         style: const TextStyle(
//           color: _textPrimary,
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       if (badge != null) ...[
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//           decoration: BoxDecoration(
//             color: (badgeColor ?? _accent).withOpacity(0.15),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             badge,
//             style: TextStyle(
//               color: badgeColor ?? _accent,
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ],
//     ],
//   );
// }

// // ─── Reusable sub-widgets ──────────────────────────────────────────────────────

// class _StatTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;

//   const _StatTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.white10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(7),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 16),
//           ),

//           const Spacer(),

//           Text(
//             value,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               color: _textPrimary,
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//               height: 1,
//             ),
//           ),

//           const SizedBox(height: 6),

//           Text(
//             label,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(color: _textMuted, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HealthBar extends StatelessWidget {
//   final String label;
//   final double value;
//   final String displayText;
//   final Color color;

//   const _HealthBar({
//     required this.label,
//     required this.value,
//     required this.displayText,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: _surface,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: Colors.white10),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(color: _textMuted, fontSize: 11),
//             ),
//             Text(
//               displayText,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: LinearProgressIndicator(
//             value: value.clamp(0.0, 1.0),
//             backgroundColor: Colors.white10,
//             valueColor: AlwaysStoppedAnimation<Color>(color),
//             minHeight: 5,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _QAction extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const _QAction({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 44,
//           height: 44,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: color.withOpacity(0.25)),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           label,
//           style: const TextStyle(
//             color: _textMuted,
//             fontSize: 10,
//             fontWeight: FontWeight.w500,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     ),
//   );
// }

import 'dart:convert';
import 'package:cms_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/ad_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/schedule_provider.dart';

import '../ads/ads_page.dart';
import '../carousel/carousels_page.dart';
import '../devices/devices_page.dart';
import '../deviceGroups/device_groups_page.dart';
import '../liveContent/live_content_page.dart';
import '../schedules/schedules_page.dart';
import '../settings/settings_page.dart';
import '../exports/export_details_page.dart';

// ─── Safe parsers ──────────────────────────────────────────────────────────────

int _parseInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double _parseDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

String _safeString(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  if (v is String) return v.trim().isEmpty ? fallback : v;
  return v.toString();
}

DateTime _safeDate(dynamic v) =>
    DateTime.tryParse(_safeString(v)) ?? DateTime.now();

// ─── Data models ───────────────────────────────────────────────────────────────

class DashboardStats {
  final int totalImpressions;
  final int adsScheduled;
  final int activeDevices;
  final int networkIssues;
  final int storageIssues;
  final int deviceCrashes;
  final int diagnosticErrors;
  final int playbackErrors;
  final double avgCpu;
  final double avgRamFree;
  final double avgStorageFree;
  final double networkHealth;
  final List<PerformanceOutlier> outliers;
  final List<RecentEvent> recentEvents;

  const DashboardStats({
    required this.totalImpressions,
    required this.adsScheduled,
    required this.activeDevices,
    required this.networkIssues,
    required this.storageIssues,
    required this.deviceCrashes,
    required this.diagnosticErrors,
    required this.playbackErrors,
    required this.avgCpu,
    required this.avgRamFree,
    required this.avgStorageFree,
    required this.networkHealth,
    required this.outliers,
    required this.recentEvents,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final d = ((json['data'] ?? json) as Map<String, dynamic>?) ?? {};
    final health = (d['systemHealth'] as Map<String, dynamic>?) ?? {};

    return DashboardStats(
      totalImpressions: _parseInt(d['totalImpressions']),
      adsScheduled: _parseInt(d['adsScheduledInRange']),
      activeDevices: _parseInt(d['activeDevicesInRange']),
      networkIssues: _parseInt(d['networkIssues']),
      storageIssues: _parseInt(d['storageIssues']),
      deviceCrashes: _parseInt(d['deviceCrashes']),
      diagnosticErrors: _parseInt(d['diagnosticErrors']),
      playbackErrors: _parseInt(d['playbackErrors']),
      avgCpu: _parseDouble(health['avgCpuUsage']),
      avgRamFree: _parseDouble(health['avgRamFree']),
      avgStorageFree: _parseDouble(health['avgStorageFree']),
      networkHealth: _parseDouble(health['networkHealth']),
      outliers: ((d['performanceOutliers'] as List<dynamic>?) ?? [])
          .map(
            (e) =>
                PerformanceOutlier.fromJson((e as Map<String, dynamic>?) ?? {}),
          )
          .toList(),
      recentEvents: ((d['recentEvents'] as List<dynamic>?) ?? [])
          .map((e) => RecentEvent.fromJson((e as Map<String, dynamic>?) ?? {}))
          .toList(),
    );
  }
}

class PerformanceOutlier {
  final String deviceName;
  final String location;
  final String metric;
  final String value;
  final String severity;
  final DateTime createdAt;

  const PerformanceOutlier({
    required this.deviceName,
    required this.location,
    required this.metric,
    required this.value,
    required this.severity,
    required this.createdAt,
  });

  factory PerformanceOutlier.fromJson(Map<String, dynamic> j) =>
      PerformanceOutlier(
        deviceName: _safeString(j['device_name'], 'Unknown Device'),
        location: _safeString(j['location']),
        metric: _safeString(j['metric'], '—'),
        value: _safeString(j['value'], '—'),
        severity: _safeString(j['severity'], 'low'),
        createdAt: _safeDate(j['created_at']),
      );
}

class RecentEvent {
  final String device;
  final String location;
  final String eventType;
  final DateTime timestamp;

  const RecentEvent({
    required this.device,
    required this.location,
    required this.eventType,
    required this.timestamp,
  });

  factory RecentEvent.fromJson(Map<String, dynamic> j) => RecentEvent(
    device: _safeString(j['device'], 'Unknown'),
    location: _safeString(j['location']),
    eventType: _safeString(j['event_type'], 'UNKNOWN'),
    timestamp: _safeDate(j['timestamp']),
  );
}

// ─── Colour palette ────────────────────────────────────────────────────────────

const _c = _DashColors();

class _DashColors {
  const _DashColors();
  Color get accent => const Color(0xFF2563EB);
  Color get accentLight => const Color(0xFFEFF6FF);
  Color get green => const Color(0xFF059669);
  Color get greenLight => const Color(0xFFECFDF5);
  Color get orange => const Color(0xFFEA580C);
  Color get orangeLight => const Color(0xFFFFF7ED);
  Color get yellow => const Color(0xFFD97706);
  Color get yellowLight => const Color(0xFFFFFBEB);
  Color get purple => const Color(0xFF7C3AED);
  Color get purpleLight => const Color(0xFFF5F3FF);
  Color get red => const Color(0xFFDC2626);
  Color get redLight => const Color(0xFFFEF2F2);
  Color get teal => const Color(0xFF0891B2);
  Color get tealLight => const Color(0xFFECFEFF);
  Color get pink => const Color(0xFFDB2777);
  Color get bg => const Color(0xFFF1F5F9);
  Color get surface => const Color(0xFFFFFFFF);
  Color get surfaceHigh => const Color(0xFFF8FAFC);
  Color get textPrimary => const Color(0xFF0F172A);
  Color get textSecondary => const Color(0xFF475569);
  Color get textMuted => const Color(0xFF94A3B8);
  Color get border => const Color(0xFFE2E8F0);
  Color get borderLight => const Color(0xFFF1F5F9);
  Color get shadow => const Color(0x08000000);
  Color get shadowMd => const Color(0x12000000);
}

const _kOutliersPerPage = 5;
const _kEventsPerPage = 6;

// ─── Page ──────────────────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  DashboardStats? _stats;
  String? _error;
  int _outlierPage = 0;
  int _eventPage = 0;
  AnimationController? _fadeCtrl;
  Animation<double>? _fadeAnim;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeCtrl = ctrl;
    _fadeAnim = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    _loadAll();
  }

  @override
  void dispose() {
    _fadeCtrl?.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
      _outlierPage = 0;
      _eventPage = 0;
    });
    try {
      await Future.wait([
        _fetchStats(),
        context.read<AdProvider>().loadAds(),
        context.read<DeviceProvider>().loadDevices(),
        context.read<ScheduleProvider>().loadSchedules(),
      ]);
      _fadeCtrl?.forward(from: 0);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Future<void> _fetchStats() async {
  //   final now = DateTime.now();
  //   final start = '${now.year}-${_pad(now.month)}-01';
  //   final end = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
  //   final res = await ApiService.get(
  //     '/dashboard/stats?startDate=$start&endDate=$end',
  //   );
  //   if (res.statusCode == 200) {
  //     final json = jsonDecode(res.body) as Map<String, dynamic>;
  //     if (mounted) setState(() => _stats = DashboardStats.fromJson(json));
  //   } else {
  //     throw Exception('Server error ${res.statusCode}');
  //   }
  // }

  // ─── Add these state variables inside _DashboardPageState ─────────────────

  String _selectedPreset = 'This Month';
  DateTimeRange? _customRange;

  // ─── Replace _fetchStats ──────────────────────────────────────────────────

  Future<void> _fetchStats() async {
    final range = _getDateRange();
    final start = _fmtDate(range.start);
    final end = _fmtDate(range.end);
    final res = await ApiService.get(
      '/dashboard/stats?startDate=$start&endDate=$end',
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted) setState(() => _stats = DashboardStats.fromJson(json));
    } else {
      throw Exception('Server error ${res.statusCode}');
    }
  }

  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedPreset) {
      case 'Today':
        return DateTimeRange(start: today, end: today);
      case 'Yesterday':
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: y, end: y);
      case 'Last 7 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case 'Last 14 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 13)),
          end: today,
        );
      case 'Last 30 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
      case 'Custom':
        return _customRange ??
            DateTimeRange(start: DateTime(now.year, now.month, 1), end: today);
      case 'This Month':
      default:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: today,
        );
    }
  }

  String _fmtDate(DateTime d) => '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  String _fmtDateDisplay(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month]} ${_pad(d.day)}, ${d.year}';
  }

  // ─── Add this widget method ────────────────────────────────────────────────

  Widget _dateFilterRow() {
    final range = _getDateRange();
    final presets = [
      'Today',
      'Yesterday',
      'Last 7 Days',
      'Last 14 Days',
      'Last 30 Days',
      'This Month',
    ];

    return Row(
      children: [
        // ── Preset dropdown ──
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset offset = box.localToGlobal(Offset.zero);

              final selected = await showMenu<String>(
                context: context,
                color: _c.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: _c.border),
                ),
                position: RelativeRect.fromLTRB(
                  16,
                  offset.dy + 200,
                  MediaQuery.of(context).size.width / 2,
                  0,
                ),
                items: [
                  PopupMenuItem(
                    enabled: false,
                    height: 36,
                    child: Text(
                      'Date Presets',
                      style: TextStyle(
                        color: _c.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...presets.map(
                    (p) => PopupMenuItem<String>(
                      value: p,
                      height: 40,
                      child: Row(
                        children: [
                          if (_selectedPreset == p)
                            Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: _c.accent,
                            )
                          else
                            const SizedBox(width: 14),
                          const SizedBox(width: 8),
                          Text(
                            p,
                            style: TextStyle(
                              color: _selectedPreset == p
                                  ? _c.accent
                                  : _c.textPrimary,
                              fontSize: 13,
                              fontWeight: _selectedPreset == p
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              if (selected != null && selected != _selectedPreset) {
                setState(() {
                  _selectedPreset = selected;
                  _customRange = null;
                });
                _loadAll();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _c.border),
                boxShadow: [
                  BoxShadow(
                    color: _c.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range_rounded, color: _c.accent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedPreset,
                      style: TextStyle(
                        color: _c.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _c.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // ── Custom date range picker ──
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange:
                    _customRange ??
                    DateTimeRange(start: range.start, end: range.end),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: _c.accent,
                      onPrimary: Colors.white,
                      surface: _c.surface,
                      onSurface: _c.textPrimary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setState(() {
                  _customRange = picked;
                  _selectedPreset = 'Custom';
                });
                _loadAll();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedPreset == 'Custom'
                    ? _c.accentLight
                    : _c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPreset == 'Custom'
                      ? _c.accent.withOpacity(0.4)
                      : _c.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _c.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: _selectedPreset == 'Custom'
                        ? _c.accent
                        : _c.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_fmtDateDisplay(range.start)} – ${_fmtDateDisplay(range.end)}',
                      style: TextStyle(
                        color: _selectedPreset == 'Custom'
                            ? _c.accent
                            : _c.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  void _go(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _c.bg,
      appBar: _appBar(),
      body: _loading
          ? _loader()
          : _error != null
          ? _errorView()
          : _fadeAnim != null
          ? FadeTransition(
              opacity: _fadeAnim!,
              child: RefreshIndicator(
                color: _c.accent,
                backgroundColor: _c.surface,
                onRefresh: _loadAll,
                child: _body(),
              ),
            )
          : RefreshIndicator(
              color: _c.accent,
              backgroundColor: _c.surface,
              onRefresh: _loadAll,
              child: _body(),
            ),
    );
  }

  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: _c.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    titleSpacing: 16,
    title: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_c.accent, const Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CMS Dashboard',
              style: TextStyle(
                color: _c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
            Text(
              'Content Management',
              style: TextStyle(color: _c.textMuted, fontSize: 10, height: 1),
            ),
          ],
        ),
      ],
    ),
    actions: [
      _AppBarAction(
        icon: Icons.notifications_outlined,
        badge:
            _stats?.diagnosticErrors != null && (_stats!.diagnosticErrors) > 0
            ? true
            : false,
        onTap: () {},
      ),
      const SizedBox(width: 6),
      _AppBarAction(
        icon: Icons.person_outline_rounded,
        onTap: () => _go(const SettingsPage()),
      ),
      const SizedBox(width: 12),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: _c.border),
    ),
  );

  Widget _loader() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            color: _c.accent,
            strokeWidth: 2.5,
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading dashboard…',
          style: TextStyle(color: _c.textMuted, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _c.orangeLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off_rounded, color: _c.orange, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'Could not load data',
            style: TextStyle(
              color: _c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'An unexpected error occurred.',
            style: TextStyle(color: _c.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: _c.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _body() {
    final s = _stats;
    final now = DateTime.now();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = months[now.month];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting header ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back 👋',
                      style: TextStyle(
                        color: _c.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   'May 1 – $monthName ${now.day}, ${now.year}',
                    //   style: TextStyle(color: _c.textSecondary, fontSize: 13),
                    // ),
                    // Replace the static date text with:
                    Text(() {
                      final r = _getDateRange();
                      return '${_fmtDateDisplay(r.start)} – ${_fmtDateDisplay(r.end)}';
                    }(), style: TextStyle(color: _c.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              // if (s != null)
              //   Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 10,
              //       vertical: 6,
              //     ),
              //     decoration: BoxDecoration(
              //       color: s.networkHealth < 30 ? _c.redLight : _c.greenLight,
              //       borderRadius: BorderRadius.circular(20),
              //       border: Border.all(
              //         color: s.networkHealth < 30
              //             ? _c.red.withOpacity(0.3)
              //             : _c.green.withOpacity(0.3),
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Container(
              //           width: 7,
              //           height: 7,
              //           decoration: BoxDecoration(
              //             color: s.networkHealth < 30 ? _c.red : _c.green,
              //             shape: BoxShape.circle,
              //           ),
              //         ),
              //         const SizedBox(width: 6),
              //         Text(
              //           s.networkHealth < 30
              //               ? 'Issues Detected'
              //               : 'All Systems',
              //           style: TextStyle(
              //             color: s.networkHealth < 30 ? _c.red : _c.green,
              //             fontSize: 11,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
            ],
          ),

          // ── Date filter row ──  ← ADD THIS
          const SizedBox(height: 12),

          _dateFilterRow(),
          const SizedBox(height: 12),

          // ── Hero impressions card ──
          // if (s != null) _heroCard(s),
          // const SizedBox(height: 20),

          // ── Hero impressions card ──
          if (s != null) _heroCard(s),
          const SizedBox(height: 12),

          // ── 4 stat tiles ──
          if (s != null) ...[
            _sectionHeader('Overview'),
            const SizedBox(height: 10),
            _statGrid(s),
            const SizedBox(height: 20),
          ],

          // ── Quick Actions ──
          _sectionHeader('Quick Actions'),
          const SizedBox(height: 10),
          _quickActions(),
          const SizedBox(height: 20),

          // ── Incident Summary ──
          if (s != null) ...[
            _sectionHeader('Incident Summary'),
            const SizedBox(height: 10),
            _incidentGrid(s),
            const SizedBox(height: 20),
          ],

          // ── System Health ──
          if (s != null) ...[
            _sectionHeader('System Health'),
            const SizedBox(height: 10),
            _healthSection(s),
            const SizedBox(height: 20),
          ],

          // ── Critical Devices ──
          if (s != null && s.outliers.isNotEmpty) ...[
            _sectionHeader(
              'Critical Devices',
              badge: s.outliers.length.toString(),
              badgeColor: _c.red,
            ),
            const SizedBox(height: 10),
            _outlierListPaginated(s.outliers),
            const SizedBox(height: 20),
          ],

          // ── Recent Events ──
          if (s != null && s.recentEvents.isNotEmpty) ...[
            _sectionHeader(
              'Recent Events',
              badge: s.recentEvents.length.toString(),
              badgeColor: _c.accent,
            ),
            const SizedBox(height: 10),
            _recentEventsPaginated(s.recentEvents),
          ],
        ],
      ),
    );
  }

  // ─── Hero card ─────────────────────────────────────────────────────────────

  Widget _heroCard(DashboardStats s) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [_c.accent, const Color(0xFF1E40AF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: _c.accent.withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Decorative circles
        Positioned(
          right: -24,
          top: -24,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: -30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL IMPRESSIONS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fmt(s.totalImpressions),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _HeroBadge(
                          icon: Icons.campaign_rounded,
                          label: '${_fmt(s.adsScheduled)} ads',
                        ),
                        _HeroBadge(
                          icon: Icons.tv_rounded,
                          label: '${s.activeDevices} devices',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.visibility_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── Stat grid ─────────────────────────────────────────────────────────────

  Widget _statGrid(DashboardStats s) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: MediaQuery.of(context).size.width < 380 ? 1.05 : 1.22,
    children: [
      _StatCard(
        icon: Icons.campaign_rounded,
        label: 'Ads Scheduled',
        value: _fmt(s.adsScheduled),
        color: _c.accent,
        bgColor: _c.accentLight,
        trend: '+12%',
        positive: true,
      ),
      _StatCard(
        icon: Icons.tv_rounded,
        label: 'Active Devices',
        value: s.activeDevices.toString(),
        color: _c.green,
        bgColor: _c.greenLight,
        trend: 'Online',
        positive: true,
      ),
      _StatCard(
        icon: Icons.bug_report_rounded,
        label: 'Diagnostic Errors',
        value: _fmt(s.diagnosticErrors),
        color: _c.red,
        bgColor: _c.redLight,
        trend: 'Critical',
        positive: false,
      ),
      _StatCard(
        icon: Icons.wifi_rounded,
        label: 'Network Health',
        value: '${s.networkHealth.toStringAsFixed(1)}%',
        color: s.networkHealth < 30 ? _c.red : _c.teal,
        bgColor: s.networkHealth < 30 ? _c.redLight : _c.tealLight,
        trend: s.networkHealth < 30 ? 'Low' : 'Good',
        positive: s.networkHealth >= 30,
      ),
    ],
  );

  // ─── Quick Actions ─────────────────────────────────────────────────────────

  Widget _quickActions() {
    final actions = [
      _QAData(
        Icons.campaign_rounded,
        'Ads',
        _c.accent,
        _c.accentLight,
        () => _go(const AdsPage()),
      ),
      _QAData(
        Icons.tv_rounded,
        'Devices',
        _c.green,
        _c.greenLight,
        () => _go(const DevicesPage()),
      ),
      _QAData(
        Icons.group_work_rounded,
        'Groups',
        _c.purple,
        _c.purpleLight,
        () => _go(const GroupsPage()),
      ),
      _QAData(
        Icons.event_note_rounded,
        'Schedule',
        _c.yellow,
        _c.yellowLight,
        () => _go(const SchedulesPage()),
      ),
      _QAData(
        Icons.bar_chart_rounded,
        'Reports',
        _c.teal,
        _c.tealLight,
        () => _go(const ExportDetailsPage()),
      ),
      _QAData(
        Icons.view_carousel_rounded,
        'Carousels',
        _c.orange,
        _c.orangeLight,
        () => _go(const CarouselPage()),
      ),
      _QAData(
        Icons.stream_rounded,
        'Live',
        _c.red,
        _c.redLight,
        () => _go(const LiveContentPage()),
      ),
      _QAData(
        Icons.settings_rounded,
        'Settings',
        _c.purple,
        _c.purpleLight,
        () => _go(const SettingsPage()),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: _c.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          mainAxisSpacing: 12,
          crossAxisSpacing: 4,
        ),
        itemCount: actions.length,
        itemBuilder: (_, i) => _QuickActionTile(data: actions[i]),
      ),
    );
  }

  // ─── Incident grid ─────────────────────────────────────────────────────────

  Widget _incidentGrid(DashboardStats s) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _IncidentTile(
              label: 'Network Issues',
              value: s.networkIssues,
              icon: Icons.wifi_off_rounded,
              color: _c.teal,
              bgColor: _c.tealLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _IncidentTile(
              label: 'Storage Issues',
              value: s.storageIssues,
              icon: Icons.storage_rounded,
              color: _c.purple,
              bgColor: _c.purpleLight,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _IncidentTile(
              label: 'Device Crashes',
              value: s.deviceCrashes,
              icon: Icons.phonelink_erase_rounded,
              color: _c.orange,
              bgColor: _c.orangeLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _IncidentTile(
              label: 'Playback Errors',
              value: s.playbackErrors,
              icon: Icons.play_disabled_rounded,
              color: _c.yellow,
              bgColor: _c.yellowLight,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _IncidentTileWide(
        label: 'Diagnostic Errors',
        value: s.diagnosticErrors,
        icon: Icons.bug_report_rounded,
        color: _c.red,
        bgColor: _c.redLight,
        fmt: _fmt,
      ),
    ],
  );

  // ─── System Health ─────────────────────────────────────────────────────────

  Widget _healthSection(DashboardStats s) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _c.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _c.border),
      boxShadow: [
        BoxShadow(color: _c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      children: [
        _HealthRow(
          label: 'CPU Usage',
          value: s.avgCpu / 100,
          displayText: '${s.avgCpu.toStringAsFixed(1)}%',
          icon: Icons.memory_rounded,
          color: s.avgCpu > 70
              ? _c.red
              : s.avgCpu > 50
              ? _c.orange
              : _c.green,
          warning: s.avgCpu > 70
              ? 'High CPU — performance may be degraded'
              : null,
        ),
        const SizedBox(height: 14),
        _HealthRow(
          label: 'RAM Free',
          value: (s.avgRamFree / 512).clamp(0, 1),
          displayText: '${s.avgRamFree.toStringAsFixed(0)} MB',
          icon: Icons.developer_board_rounded,
          color: _c.accent,
        ),
        const SizedBox(height: 14),
        _HealthRow(
          label: 'Storage Free',
          value: (s.avgStorageFree / 4096).clamp(0, 1),
          displayText: '${(s.avgStorageFree / 1024).toStringAsFixed(1)} GB',
          icon: Icons.save_rounded,
          color: _c.purple,
        ),
        const SizedBox(height: 14),
        _HealthRow(
          label: 'Network Health',
          value: (s.networkHealth / 100).clamp(0, 1),
          displayText: '${s.networkHealth.toStringAsFixed(1)}%',
          icon: Icons.wifi_rounded,
          color: s.networkHealth < 30 ? _c.red : _c.teal,
          warning: s.networkHealth < 30
              ? 'Low network health — attention needed'
              : null,
        ),
      ],
    ),
  );

  // ─── Critical Devices Paginated ───────────────────────────────────────────

  Widget _outlierListPaginated(List<PerformanceOutlier> items) {
    final totalPages = (items.length / _kOutliersPerPage).ceil();
    final slice = items
        .skip(_outlierPage * _kOutliersPerPage)
        .take(_kOutliersPerPage)
        .toList();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _c.border),
            boxShadow: [
              BoxShadow(
                color: _c.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: slice.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final isLast = i == slice.length - 1;
              final pct = int.tryParse(e.value.replaceAll('%', '').trim()) ?? 0;
              final color = pct >= 95
                  ? _c.red
                  : pct >= 80
                  ? _c.orange
                  : _c.yellow;
              final bgColor = pct >= 95
                  ? _c.redLight
                  : pct >= 80
                  ? _c.orangeLight
                  : _c.yellowLight;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.memory_rounded,
                            color: color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.deviceName,
                                style: TextStyle(
                                  color: _c.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                e.metric,
                                style: TextStyle(
                                  color: _c.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _timeAgo(e.createdAt),
                                style: TextStyle(
                                  color: _c.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                e.severity.toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: _c.borderLight,
                      indent: 66,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        if (totalPages > 1)
          _Pager(
            currentPage: _outlierPage,
            totalPages: totalPages,
            total: items.length,
            onPrev: () => setState(() => _outlierPage--),
            onNext: () => setState(() => _outlierPage++),
          ),
      ],
    );
  }

  // ─── Recent Events Paginated ───────────────────────────────────────────────

  Widget _recentEventsPaginated(List<RecentEvent> events) {
    final totalPages = (events.length / _kEventsPerPage).ceil();
    final slice = events
        .skip(_eventPage * _kEventsPerPage)
        .take(_kEventsPerPage)
        .toList();

    Color _eventColor(String type) {
      final t = type.toUpperCase();
      if (t.contains('ERROR') || t.contains('CRASH')) return _c.red;
      if (t.contains('WARN')) return _c.yellow;
      if (t.contains('NETWORK')) return _c.teal;
      if (t.contains('STORAGE')) return _c.purple;
      if (t.contains('PLAYBACK')) return _c.orange;
      return _c.accent;
    }

    IconData _eventIcon(String type) {
      final t = type.toUpperCase();
      if (t.contains('CRASH')) return Icons.phonelink_erase_rounded;
      if (t.contains('WARN') || t.contains('DIAGNOSTIC'))
        return Icons.warning_amber_rounded;
      if (t.contains('NETWORK')) return Icons.wifi_off_rounded;
      if (t.contains('STORAGE')) return Icons.storage_rounded;
      if (t.contains('PLAYBACK')) return Icons.play_disabled_rounded;
      return Icons.circle_notifications_rounded;
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _c.border),
            boxShadow: [
              BoxShadow(
                color: _c.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: slice.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final isLast = i == slice.length - 1;
              final ec = _eventColor(e.eventType);
              final ei = _eventIcon(e.eventType);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ec.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(ei, color: ec, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.device,
                                style: TextStyle(
                                  color: _c.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                e.eventType.replaceAll('_', ' ').toLowerCase(),
                                style: TextStyle(
                                  color: _c.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(e.timestamp),
                          style: TextStyle(color: _c.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: _c.borderLight,
                      indent: 62,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        if (totalPages > 1)
          _Pager(
            currentPage: _eventPage,
            totalPages: totalPages,
            total: events.length,
            onPrev: () => setState(() => _eventPage--),
            onNext: () => setState(() => _eventPage++),
          ),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(String text, {String? badge, Color? badgeColor}) => Row(
    children: [
      Text(
        text,
        style: TextStyle(
          color: _c.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      if (badge != null) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (badgeColor ?? _c.accent).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: badgeColor ?? _c.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ],
  );
}

// ─── AppBar Action ────────────────────────────────────────────────────────────

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  const _AppBarAction({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            child: Icon(icon, color: c.textSecondary, size: 18),
          ),
          if (badge)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: c.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Hero Badge ───────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final String trend;
  final bool positive;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.trend,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (positive ? c.green : c.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: positive ? c.green : c.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(color: c.textSecondary, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Data ────────────────────────────────────────────────────────

class _QAData {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const _QAData(this.icon, this.label, this.color, this.bgColor, this.onTap);
}

// ─── Quick Action Tile (with press animation) ─────────────────────────────────

class _QuickActionTile extends StatefulWidget {
  final _QAData data;
  const _QuickActionTile({required this.data});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _ctrl.forward().then(
      (_) => _ctrl.reverse().then((_) {
        widget.data.onTap();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onTapDown: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.data.bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.data.color.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: widget.data.color.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(widget.data.icon, color: widget.data.color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              widget.data.label,
              style: TextStyle(
                color: _c.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Incident Tile ────────────────────────────────────────────────────────────

class _IncidentTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _IncidentTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isOk = value == 0;
    final activeColor = isOk ? _c.green : color;
    final activeBg = isOk ? _c.greenLight : bgColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _c.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOk ? Icons.check_circle_rounded : icon,
              color: activeColor,
              size: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: TextStyle(
              color: activeColor,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: _c.textSecondary, fontSize: 11),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _IncidentTileWide extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String Function(int) fmt;

  const _IncidentTileWide({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final isOk = value == 0;
    final activeColor = isOk ? _c.green : color;
    final activeBg = isOk ? _c.greenLight : bgColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _c.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOk ? Icons.check_circle_rounded : icon,
              color: activeColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _c.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOk ? 'No issues detected' : 'Requires attention',
                  style: TextStyle(color: _c.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            fmt(value),
            style: TextStyle(
              color: activeColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Health Row ───────────────────────────────────────────────────────────────

class _HealthRow extends StatelessWidget {
  final String label;
  final double value;
  final String displayText;
  final IconData icon;
  final Color color;
  final String? warning;

  const _HealthRow({
    required this.label,
    required this.value,
    required this.displayText,
    required this.icon,
    required this.color,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final c = _c;
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: c.textSecondary, fontSize: 12),
              ),
            ),
            Text(
              displayText,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: clamped,
            backgroundColor: c.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        if (warning != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  warning!,
                  style: TextStyle(color: color, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Pager ────────────────────────────────────────────────────────────────────

class _Pager extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _Pager({
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PagerBtn(
            label: 'Prev',
            icon: Icons.chevron_left_rounded,
            leading: true,
            enabled: currentPage > 0,
            onTap: onPrev,
          ),
          Column(
            children: [
              Text(
                'Page ${currentPage + 1} of $totalPages',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$total total',
                style: TextStyle(color: c.textMuted, fontSize: 10),
              ),
            ],
          ),
          _PagerBtn(
            label: 'Next',
            icon: Icons.chevron_right_rounded,
            leading: false,
            enabled: currentPage < totalPages - 1,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _PagerBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool leading;
  final bool enabled;
  final VoidCallback onTap;

  const _PagerBtn({
    required this.label,
    required this.icon,
    required this.leading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final color = enabled ? c.accent : c.textMuted;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? c.accentLight : c.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? c.accent.withOpacity(0.3) : c.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: leading
              ? [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              : [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(icon, size: 16, color: color),
                ],
        ),
      ),
    );
  }
}
