// import 'package:cms_app/pages/login/login_page.dart';
// import 'package:cms_app/pages/settings/privacy_policy_page.dart';
// import 'package:cms_app/pages/settings/profile_page.dart';
// import 'package:cms_app/pages/settings/terms_conditions_page.dart';
// import 'package:cms_app/pages/subscription/subscription_details_page.dart';
// import 'package:cms_app/providers/subscription_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   bool _notificationsEnabled = true;
//   bool _darkModeEnabled = false;

//   @override
//   Widget build(BuildContext context) {
//     final auth = context.read<AuthProvider>();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         title: const Text("Settings"),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           /// 🔹 PROFILE CARD
//           // Container(
//           //   padding: const EdgeInsets.all(16),
//           //   decoration: BoxDecoration(
//           //     gradient: const LinearGradient(
//           //       colors: [Color(0xFF3F7BD9), Color(0xFF1A4FB5)],
//           //     ),
//           //     borderRadius: BorderRadius.circular(16),
//           //   ),
//           //   child: const Row(
//           //     children: [
//           //       CircleAvatar(
//           //         radius: 28,
//           //         backgroundColor: Colors.white,
//           //         child: Icon(Icons.person, size: 30, color: Colors.indigo),
//           //       ),
//           //       SizedBox(width: 12),
//           //       Column(
//           //         crossAxisAlignment: CrossAxisAlignment.start,
//           //         children: [
//           //           Text(
//           //             "Admin User",
//           //             style: TextStyle(
//           //               color: Colors.white,
//           //               fontSize: 16,
//           //               fontWeight: FontWeight.bold,
//           //             ),
//           //           ),
//           //           Text(
//           //             "admin@cms.com",
//           //             style: TextStyle(color: Colors.white70),
//           //           ),
//           //         ],
//           //       )
//           //     ],
//           //   ),
//           // ),
//           const SizedBox(height: 20),

//           /// 🔹 ACCOUNT SECTION
//           _buildSectionTitle("Account"),
//           _buildCard([
//             _tile(
//               Icons.person_outline,
//               "Edit Profile",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ProfilePage()),
//                 );
//               },
//             ),
//             _divider(),
//             _tile(Icons.lock_outline, "Change Password"),
//             _divider(),

//             _tile(
//               Icons.workspace_premium,
//               "My Subscription",

//               onTap: () async {
//                 await context.read<SubscriptionProvider>().loadHistory();
//                 await context.read<SubscriptionProvider>().loadSubscription();

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const SubscriptionDetailsPage(),
//                   ),
//                 );
//               },
//             ),
//           ]),

//           const SizedBox(height: 16),

//           /// 🔹 PREFERENCES
//           // _buildSectionTitle("Preferences"),
//           // _buildCard([
//           //   SwitchListTile(
//           //     secondary: const Icon(Icons.notifications_active_outlined),
//           //     title: const Text("Push Notifications"),
//           //     value: _notificationsEnabled,
//           //     onChanged: (v) => setState(() => _notificationsEnabled = v),
//           //   ),
//           //   _divider(),
//           //   SwitchListTile(
//           //     secondary: const Icon(Icons.dark_mode_outlined),
//           //     title: const Text("Dark Mode"),
//           //     value: _darkModeEnabled,
//           //     onChanged: (v) => setState(() => _darkModeEnabled = v),
//           //   ),
//           //   _divider(),
//           //   _tile(Icons.language, "Language"),
//           // ]),
//           const SizedBox(height: 16),

//           /// 🔹 SUPPORT
//           _buildSectionTitle("Support & About"),
//           _buildCard([
//             _tile(Icons.help_outline, "Help Center"),
//             _divider(),
//             // _tile(Icons.privacy_tip_outlined, "Privacy Policy"),
//             _tile(
//               Icons.privacy_tip_outlined,
//               "Privacy Policy",

//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
//                 );
//               },
//             ),
//             _divider(),

//             _tile(
//               Icons.description_outlined,
//               "Terms & Conditions",

//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const TermsConditionsPage(),
//                   ),
//                 );
//               },
//             ),
//             _divider(),

//             const ListTile(
//               leading: Icon(Icons.info_outline),
//               title: Text("App Version"),
//               trailing: Text("v1.0.0", style: TextStyle(color: Colors.grey)),
//             ),
//           ]),

//           const SizedBox(height: 24),

//           /// 🔴 LOGOUT BUTTON
//           ElevatedButton.icon(
//             onPressed: () async {
//               final ok = await showDialog<bool>(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text("Logout"),
//                   content: const Text("Are you sure you want to logout?"),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: const Text("Cancel"),
//                     ),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.redAccent,
//                       ),
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text("Logout"),
//                     ),
//                   ],
//                 ),
//               );

//               if (ok == true) {
//                 await auth.logout();

//                 if (context.mounted) {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginPage()),
//                     (route) => false,
//                   );
//                 }
//               }
//             },
//             icon: const Icon(Icons.logout),
//             label: const Text("Logout"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.redAccent,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   /// 🔹 SECTION TITLE
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, left: 4),
//       child: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.indigo,
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }

//   /// 🔹 CARD CONTAINER
//   Widget _buildCard(List<Widget> children) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
//         ],
//       ),
//       child: Column(children: children),
//     );
//   }

//   /// 🔹 COMMON TILE
//   // Widget _tile(IconData icon, String title) {
//   //   return ListTile(
//   //     leading: Icon(icon, color: Colors.indigo),
//   //     title: Text(title),
//   //     trailing: const Icon(Icons.chevron_right),
//   //     onTap: () {},
//   //   );
//   // }

//   Widget _tile(IconData icon, String title, {VoidCallback? onTap}) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.indigo),

//       title: Text(title),

//       trailing: const Icon(Icons.chevron_right),

//       onTap: onTap,
//     );
//   }

//   /// 🔹 DIVIDER
//   Widget _divider() {
//     return const Divider(height: 1);
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NEW UPDATED UI>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:cms_app/pages/login/login_page.dart';
import 'package:cms_app/pages/sales_contact_page.dart';
import 'package:cms_app/pages/settings/change_password_page.dart';
import 'package:cms_app/pages/settings/privacy_policy_page.dart';
import 'package:cms_app/pages/settings/profile_page.dart';
import 'package:cms_app/pages/settings/terms_conditions_page.dart';
import 'package:cms_app/pages/subscription/subscription_details_page.dart';
import 'package:cms_app/providers/subscription_provider.dart';
import 'package:cms_app/services/account_service.dart';
import 'package:cms_app/models/account_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cms_app/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  AccountInfo? _account;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final account = await AccountService.getAccount();

      if (mounted) {
        setState(() {
          _account = account;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: appColors.bg,
      appBar: AppBar(
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: appColors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: appColors.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.textSecondary,
              size: 15,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),

        centerTitle: false,
        titleSpacing: 4,

        title: Text(
          'Settings',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
        children: [
          // ── ACCOUNT ────────────────────────────────────────────────
          _sectionLabel('Account'),
          if (_account != null) ...[
            _settingsHeroCard(_account!),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 10),
          _card([
            _tile(
              icon: Icons.person_rounded,
              iconColor: appColors.accent,
              iconBg: appColors.accentLight,
              title: 'Edit Profile',
              onTap: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(account: _account!),
                  ),
                );

                if (updated == true) {
                  await _loadAccount();
                }
              },
            ),
            _divider(),
            _tile(
              icon: Icons.lock_rounded,
              iconColor: appColors.purple,
              iconBg: appColors.purpleLight,
              title: 'Change Password',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              ),
            ),
            _divider(),
            _tile(
              icon: Icons.workspace_premium_rounded,
              iconColor: appColors.yellow,
              iconBg: appColors.yellowLight,
              title: 'My Subscription',
              onTap: () async {
                await context.read<SubscriptionProvider>().loadHistory();
                await context.read<SubscriptionProvider>().loadSubscription();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionDetailsPage(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 20),

          // ── SUPPORT & ABOUT ────────────────────────────────────────
          _sectionLabel('Support & About'),
          const SizedBox(height: 10),
          _card([
            _tile(
              icon: Icons.help_rounded,
              iconColor: appColors.teal,
              iconBg: appColors.tealLight,
              title: 'Help Center',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesContactPage()),
                );
              },
            ),
            _divider(),
            _tile(
              icon: Icons.privacy_tip_rounded,
              iconColor: appColors.green,
              iconBg: appColors.greenLight,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                );
              },
            ),
            _divider(),
            _tile(
              icon: Icons.description_rounded,
              iconColor: appColors.orange,
              iconBg: appColors.orangeLight,
              title: 'Terms & Conditions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsConditionsPage(),
                  ),
                );
              },
            ),
            _divider(),
            // App Version (no onTap — kept as-is)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: appColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_rounded,
                      color: appColors.textMuted,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'App Version',
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'v1.0.13',
                    style: TextStyle(
                      color: appColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 28),

          // ── LOGOUT ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 40,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: appColors.redLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: appColors.red,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: appColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(
                              color: appColors.textSecondary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: appColors.textSecondary,
                                    side: BorderSide(color: appColors.border),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: appColors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
              icon: const Icon(Icons.logout_rounded, size: 17),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                backgroundColor: appColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsHeroCard(AccountInfo a) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(account: a)),
        );

        if (updated == true) {
          await _loadAccount();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appColors.accent, const Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: appColors.accent.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
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
              left: -12,
              bottom: -32,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2.5,
                          ),
                        ),
                        child: ClipOval(
                          child: a.avatar.isNotEmpty
                              ? Image.network(
                                  a.avatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _avatarFallback(a.name),
                                )
                              : _avatarFallback(a.name),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              a.email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.shield_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    a.role,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // const Icon(
                      //   Icons.chevron_right_rounded,
                      //   color: Colors.white,
                      // ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Divider(color: Colors.white.withOpacity(0.15), height: 1),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Member since ${_fmtDate(a.joinedOn)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
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
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  Widget _avatarFallback(String name) => Container(
    color: Colors.white.withOpacity(0.2),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
  // ─── Section label ────────────────────────────────────────────────────────

  Widget _sectionLabel(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 2, left: 2),
    child: Text(
      title,
      style: TextStyle(
        color: appColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.3,
      ),
    ),
  );

  // ─── Card container ───────────────────────────────────────────────────────

  Widget _card(List<Widget> children) => Container(
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
    child: Column(children: children),
  );

  // ─── Tile ─────────────────────────────────────────────────────────────────

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback? onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: appColors.textMuted,
            size: 18,
          ),
        ],
      ),
    ),
  );

  // ─── Divider ──────────────────────────────────────────────────────────────

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: appColors.borderLight,
    indent: 64,
  );
}
