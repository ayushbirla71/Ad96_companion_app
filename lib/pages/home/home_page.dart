import 'package:flutter/material.dart';
import '../ads/ads_page.dart';
import '../devices/devices_page.dart';
import '../schedules/schedules_page.dart';
import '../settings/settings_page.dart';
import 'dashboard_page.dart';
import '../deviceGroups/device_groups_page.dart'; // 👈 new page import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  // Add DeviceGroupsPage to the pages list
  final pages = const [
    DashboardPage(),
    AdsPage(),
    DevicesPage(),
    GroupsPage(), // 👈 new page here
    SchedulesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "Ads"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Devices"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Groups"), // 👈 device groups
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedules"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
