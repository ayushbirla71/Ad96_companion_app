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
  // Local state for the UI toggles (Wire these up to your providers later)
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // --- ACCOUNT SECTION ---
          _buildSectionHeader("Account"),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Edit Profile Page
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Change Password Page
            },
          ),

          const Divider(height: 30),

          // --- PREFERENCES SECTION ---
          _buildSectionHeader("Preferences"),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text("Push Notifications"),
            value: _notificationsEnabled,
            activeColor: Colors.blue,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text("Dark Mode"),
            value: _darkModeEnabled,
            activeColor: Colors.blue,
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // TODO: Call your ThemeProvider to actually change the app theme
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            subtitle: const Text("English (US)"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show Language Picker
            },
          ),

          const Divider(height: 30),

          // --- ABOUT & SUPPORT SECTION ---
          _buildSectionHeader("Support & About"),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help Center"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open Help Center URL or Page
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open Privacy Policy
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("App Version"),
            trailing: Text(
              "v1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),

          const Divider(height: 30),

          // --- DANGER ZONE (LOGOUT) ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
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
                        foregroundColor: Colors.white,
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
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
          ),
          
          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }

  // Helper widget to create consistent section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}