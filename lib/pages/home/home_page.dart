// import 'package:cms_app/pages/ads/ad_create_page.dart';
// import 'package:cms_app/pages/channel/create_channel_page.dart';
// import 'package:cms_app/pages/devices/add_device_step1.dart';
// import 'package:cms_app/pages/schedules/create_schedule_page.dart';
// import 'package:cms_app/pages/subscription/feature_not_available_page.dart';
// import 'package:flutter/material.dart';
// import '../ads/ads_page.dart';
// import '../devices/devices_page.dart';
// import '../schedules/schedules_page.dart';
// import '../settings/settings_page.dart';
// import 'dashboard_page.dart';
// import '../deviceGroups/device_groups_page.dart';
// import 'package:cms_app/pages/channel/assign_live_content_to_groups.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int index = 0;

//   final pages = const [
//     DashboardPage(),
//     AdsPage(),
//     DevicesPage(),
//     GroupsPage(),
//     SchedulesPage(),
//     SettingsPage(),
//     AddAdPage(),
//     AddDeviceStep1Page(),
//     CreateChannelPage(),
//     CreateSchedulePage(),
//   ];

//   void changeTab(int i) {
//     setState(() {
//       index = i;
//     });
//   }

//   void onPlusPressed() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return SizedBox(
//           height: 220,
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: GridView.count(
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: 2,
//               mainAxisSpacing: 20,
//               crossAxisSpacing: 20,
//               childAspectRatio: 1.8,
//               children: [
//                 _quickAction(Icons.campaign, "New Ad", () {
//                   Navigator.pop(context);
//                   changeTab(6);
//                 }),
//                 _quickAction(Icons.tv, "Add Device", () {
//                   Navigator.pop(context);
//                   changeTab(7);
//                 }),
//                 _quickAction(Icons.live_tv, "Create Live Channel", () {
//                   Navigator.pop(context);
//                   changeTab(8);
//                 }),
//                 _quickAction(Icons.schedule, "New Schedule", () {
//                   Navigator.pop(context);
//                   changeTab(9);
//                 }),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
//     return SizedBox(
//       width: 100,
//       child: InkWell(
//         onTap: onTap, // use the callback here
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 26,
//               backgroundColor: Colors.indigo.shade50,
//               child: Icon(icon, color: Colors.indigo),
//             ),
//             const SizedBox(height: 6),
//             Text(label, textAlign: TextAlign.center),
//           ],
//         ),
//       ),
//     );
//   }

//   void navigate(Widget page) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 👇 Wrap Scaffold in WillPopScope to handle the system back button
//     return WillPopScope(
//       onWillPop: () async {
//         // If we are NOT on the Dashboard tab
//         if (index != 0) {
//           // Change the tab back to Dashboard
//           setState(() {
//             index = 0;
//           });
//           // Return false to prevent the app from closing/popping
//           return false;
//         }
//         // If we ARE on the Dashboard, return true to allow the app to close normally
//         return true;
//       },
//       child: Scaffold(
//         body: IndexedStack(index: index, children: pages),

//         // floatingActionButton: FloatingActionButton(
//         //   onPressed: onPlusPressed,
//         //   backgroundColor: Colors.indigo,
//         //   child: const Icon(Icons.add, size: 28, color: Colors.white),
//         // ),
//         floatingActionButton: GestureDetector(
//           onTap: () => navigate(const AssignLiveContentToGroups()),
//           child: Container(
//             width: 90,
//             height: 90,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF3F7BD9), Color(0xFF1A4FB5)],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.5),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Icon(Icons.wifi_tethering, color: Colors.white, size: 34),
//                 SizedBox(height: 2),
//                 Text(
//                   "GO LIVE",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

//         bottomNavigationBar: BottomAppBar(
//           shape: const CircularNotchedRectangle(),
//           notchMargin: 6,
//           child: SizedBox(
//             height: 65,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 /// Left items
//                 _navItem(Icons.dashboard, "Dashboard", 0),
//                 _navItem(Icons.campaign, "Ads", 1),

//                 const SizedBox(width: 40),

//                 /// Right items
//                 _navItem(Icons.tv, "Devices", 2),
//                 _navItem(Icons.group, "Groups", 3),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _navItem(IconData icon, String label, int i) {
//     final selected = index == i;

//     return InkWell(
//       onTap: () => changeTab(i),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: selected ? Colors.indigo : Colors.grey),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: selected ? Colors.indigo : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cms_app/theme/app_colors.dart';
import 'package:cms_app/pages/ads/ad_create_page.dart';
import 'package:cms_app/pages/channel/create_channel_page.dart';
import 'package:cms_app/pages/devices/add_device_step1.dart';
import 'package:cms_app/pages/schedules/create_schedule_page.dart';
import 'package:cms_app/pages/subscription/feature_not_available_page.dart';
import 'package:cms_app/pages/channel/assign_live_content_to_groups.dart';

import '../ads/ads_page.dart';
import '../devices/devices_page.dart';
import '../schedules/schedules_page.dart';
import '../settings/settings_page.dart';
import '../deviceGroups/device_groups_page.dart';
import 'dashboard_page.dart';
import 'package:cms_app/utils/feature_access.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final pages = const [
    DashboardPage(),
    AdsPage(),
    DevicesPage(),
    GroupsPage(),
    SchedulesPage(),
    SettingsPage(),
    AddAdPage(),
    AddDeviceStep1Page(),
    CreateChannelPage(),
    CreateSchedulePage(),
  ];

  void changeTab(int i) {
    setState(() {
      index = i;
    });
  }

  void onPlusPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: appColors.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: appColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                "Quick Actions",
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _quickActionCard(
                    icon: Icons.campaign_rounded,
                    label: "New Ad",
                    color: appColors.accent,
                    bgColor: appColors.accentLight,
                    onTap: () {
                      Navigator.pop(context);
                      changeTab(6);
                    },
                  ),
                  _quickActionCard(
                    icon: Icons.tv_rounded,
                    label: "Add Device",
                    color: appColors.purple,
                    bgColor: appColors.purpleLight,
                    onTap: () {
                      Navigator.pop(context);
                      changeTab(7);
                    },
                  ),
                  _quickActionCard(
                    icon: Icons.live_tv_rounded,
                    label: "Live Channel",
                    color: appColors.red,
                    bgColor: appColors.redLight,
                    onTap: () {
                      Navigator.pop(context);
                      changeTab(8);
                    },
                  ),
                  _quickActionCard(
                    icon: Icons.schedule_rounded,
                    label: "New Schedule",
                    color: appColors.teal,
                    bgColor: appColors.tealLight,
                    onTap: () {
                      Navigator.pop(context);
                      changeTab(9);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: appColors.border),
          boxShadow: [
            BoxShadow(
              color: appColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: index == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() {
          index = 0;
        });
      },
      child: Scaffold(
        backgroundColor: appColors.bg,
        body: IndexedStack(index: index, children: pages),

        floatingActionButton: FeatureAccess.showLiveStreaming(context)
            ? GestureDetector(
                onTap: () => navigate(const AssignLiveContentToGroups()),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [appColors.accent, const Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.accent.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: appColors.surface.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.wifi_tethering_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      SizedBox(height: 2),
                      Text(
                        "LIVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomAppBar(
            color: appColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shadowColor: appColors.shadow,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: _navItem(Icons.dashboard_rounded, "Dashboard", 0),
                  ),
                  Expanded(child: _navItem(Icons.campaign_rounded, "Ads", 1)),
                  const SizedBox(width: 48),
                  Expanded(child: _navItem(Icons.tv_rounded, "Devices", 2)),
                  Expanded(child: _navItem(Icons.group_rounded, "Groups", 3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int i) {
    final isSelected = index == i;

    return InkWell(
      onTap: () => changeTab(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Sizing based on content
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? appColors.accent : appColors.textMuted,
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            // No Flexible here! Just the Text with maxLines to prevent height looping
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? appColors.accent : appColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
