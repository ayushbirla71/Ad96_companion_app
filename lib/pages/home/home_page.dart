import 'package:cms_app/pages/ads/ad_create_page.dart';
import 'package:cms_app/pages/channel/create_channel_page.dart';
import 'package:cms_app/pages/devices/add_device_step1.dart';
import 'package:cms_app/pages/schedules/create_schedule_page.dart';
import 'package:cms_app/pages/subscription/feature_not_available_page.dart';
import 'package:flutter/material.dart';
import '../ads/ads_page.dart';
import '../devices/devices_page.dart';
import '../schedules/schedules_page.dart';
import '../settings/settings_page.dart';
import 'dashboard_page.dart';
import '../deviceGroups/device_groups_page.dart';
import 'package:cms_app/pages/channel/assign_live_content_to_groups.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.8,
              children: [
                _quickAction(Icons.campaign, "New Ad", () {
                  Navigator.pop(context);
                  changeTab(6);
                }),
                _quickAction(Icons.tv, "Add Device", () {
                  Navigator.pop(context);
                  changeTab(7);
                }),
                _quickAction(Icons.live_tv, "Create Live Channel", () {
                  Navigator.pop(context);
                  changeTab(8);
                }),
                _quickAction(Icons.schedule, "New Schedule", () {
                  Navigator.pop(context);
                  changeTab(9);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: onTap, // use the callback here
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.indigo.shade50,
              child: Icon(icon, color: Colors.indigo),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center),
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
    return Scaffold(
      body: IndexedStack(index: index, children: pages),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: onPlusPressed,
      //   backgroundColor: Colors.indigo,
      //   child: const Icon(Icons.add, size: 28, color: Colors.white),
      // ),
      floatingActionButton: GestureDetector(
        // onTap: () => navigate(const AssignLiveContentToGroups()),
          onTap: () => navigate(const FeatureNotAvailablePage()),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3F7BD9), Color(0xFF1A4FB5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.wifi_tethering, color: Colors.white, size: 34),
              SizedBox(height: 2),
              Text(
                "GO LIVE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// Left items
              _navItem(Icons.dashboard, "Dashboard", 0),
              _navItem(Icons.campaign, "Ads", 1),

              const SizedBox(width: 40),

              /// Right items
              _navItem(Icons.tv, "Devices", 2),
              _navItem(Icons.group, "Groups", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int i) {
    final selected = index == i;

    return InkWell(
      onTap: () => changeTab(i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.indigo : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.indigo : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
