import 'package:flutter/material.dart';
import '../ads/ads_page.dart';
import '../devices/devices_page.dart';
import '../schedules/schedules_page.dart';
import '../settings/settings_page.dart';
import 'dashboard_page.dart';
import '../deviceGroups/device_groups_page.dart';

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
  ];

  void changeTab(int i) {
    setState(() {
      index = i;
    });
  }

  void onPlusPressed() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _quickAction(Icons.campaign, "New Ad"),
              _quickAction(Icons.tv, "Add Device"),
              _quickAction(Icons.group, "Create Group"),
              _quickAction(Icons.schedule, "New Schedule"),
            ],
          ),
        );
      },
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return SizedBox(
      width: 100,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: onPlusPressed,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, size: 28),
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
          Icon(
            icon,
            color: selected ? Colors.indigo : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.indigo : Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}