import 'package:cms_app/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔹 PROFILE CARD
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       colors: [Color(0xFF3F7BD9), Color(0xFF1A4FB5)],
          //     ),
          //     borderRadius: BorderRadius.circular(16),
          //   ),
          //   child: const Row(
          //     children: [
          //       CircleAvatar(
          //         radius: 28,
          //         backgroundColor: Colors.white,
          //         child: Icon(Icons.person, size: 30, color: Colors.indigo),
          //       ),
          //       SizedBox(width: 12),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             "Admin User",
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           Text(
          //             "admin@cms.com",
          //             style: TextStyle(color: Colors.white70),
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // ),

          const SizedBox(height: 20),

          /// 🔹 ACCOUNT SECTION
          _buildSectionTitle("Account"),
          _buildCard([
            _tile(Icons.person_outline, "Edit Profile"),
            _divider(),
            _tile(Icons.lock_outline, "Change Password"),
          ]),

          const SizedBox(height: 16),

          /// 🔹 PREFERENCES
          _buildSectionTitle("Preferences"),
          _buildCard([
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text("Push Notifications"),
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            _divider(),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text("Dark Mode"),
              value: _darkModeEnabled,
              onChanged: (v) => setState(() => _darkModeEnabled = v),
            ),
            _divider(),
            _tile(Icons.language, "Language"),
          ]),

          const SizedBox(height: 16),

          /// 🔹 SUPPORT
          _buildSectionTitle("Support & About"),
          _buildCard([
            _tile(Icons.help_outline, "Help Center"),
            _divider(),
            _tile(Icons.privacy_tip_outlined, "Privacy Policy"),
            _divider(),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("App Version"),
              trailing: Text(
                "v1.0.0",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          /// 🔴 LOGOUT BUTTON
          ElevatedButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (ok == true) {
                await auth.logout();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 🔹 SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.indigo,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  /// 🔹 CARD CONTAINER
  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// 🔹 COMMON TILE
  Widget _tile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  /// 🔹 DIVIDER
  Widget _divider() {
    return const Divider(height: 1);
  }
}