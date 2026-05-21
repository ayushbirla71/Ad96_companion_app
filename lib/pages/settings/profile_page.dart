// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:cms_app/theme/app_colors.dart';
// import 'package:cms_app/theme/custom_app_bar.dart';
// import 'package:cms_app/services/api_service.dart';

// // ─── Model ────────────────────────────────────────────────────────────────────

// class AccountInfo {
//   final String userId, name, email, phoneNumber, role, joinedOn, avatar;

//   const AccountInfo({
//     required this.userId,
//     required this.name,
//     required this.email,
//     required this.phoneNumber,
//     required this.role,
//     required this.joinedOn,
//     required this.avatar,
//   });

//   factory AccountInfo.fromJson(Map<String, dynamic> j) {
//     final a = (j['account'] as Map<String, dynamic>?) ?? {};
//     return AccountInfo(
//       userId: a['user_id']?.toString() ?? '',
//       name: a['name']?.toString() ?? '',
//       email: a['email']?.toString() ?? '',
//       phoneNumber: a['phone_number']?.toString() ?? '',
//       role: a['role']?.toString() ?? '',
//       joinedOn: a['joined_on']?.toString() ?? '',
//       avatar: a['avatar']?.toString() ?? '',
//     );
//   }
// }

// // ─── Page ─────────────────────────────────────────────────────────────────────

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage>
//     with SingleTickerProviderStateMixin {
//   bool _loading = true;
//   AccountInfo? _account;
//   String? _error;

//   AnimationController? _fadeCtrl;
//   Animation<double>? _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     final ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeCtrl = ctrl;
//     _fadeAnim = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
//     _load();
//   }

//   @override
//   void dispose() {
//     _fadeCtrl?.dispose();
//     super.dispose();
//   }

//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final res = await ApiService.get('/user/account');
//       if (res.statusCode == 200) {
//         final json = jsonDecode(res.body) as Map<String, dynamic>;
//         if (mounted) {
//           setState(() => _account = AccountInfo.fromJson(json));
//           _fadeCtrl?.forward(from: 0);
//         }
//       } else {
//         throw Exception('Server error ${res.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) setState(() => _error = e.toString());
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   String _fmtDate(String iso) {
//     final d = DateTime.tryParse(iso);
//     if (d == null) return iso;
//     const months = [
//       '',
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${months[d.month]} ${d.day}, ${d.year}';
//   }

//   void _openEditDialog() {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.5),
//       builder: (_) => _EditAccountDialog(account: _account!, onUpdated: _load),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: appColors.bg,
//       appBar: CustomAppBar(title: 'My Profile', onRefresh: _load),
//       body: _loading
//           ? _loader()
//           : _error != null
//           ? _errorView()
//           : _fadeAnim != null
//           ? FadeTransition(opacity: _fadeAnim!, child: _body())
//           : _body(),
//     );
//   }

//   Widget _body() {
//     final a = _account!;
//     return SingleChildScrollView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Hero card ──
//           _heroCard(a),
//           const SizedBox(height: 20),

//           // ── Info cards ──
//           _sectionLabel('Account Details'),
//           const SizedBox(height: 10),
//           _infoCard(a),
//           const SizedBox(height: 20),

//           // ── Role card ──
//           _sectionLabel('Role & Access'),
//           const SizedBox(height: 10),
//           _roleCard(a),
//           const SizedBox(height: 24),

//           // ── Edit button ──
//           SizedBox(
//             width: double.infinity,
//             child: FilledButton.icon(
//               onPressed: _openEditDialog,
//               icon: const Icon(Icons.edit_rounded, size: 16),
//               label: const Text('Edit Account Information'),
//               style: FilledButton.styleFrom(
//                 backgroundColor: appColors.accent,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 textStyle: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─── Hero Card ─────────────────────────────────────────────────────────────

//   Widget _heroCard(AccountInfo a) => Container(
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [appColors.accent, const Color(0xFF1E40AF)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(24),
//       boxShadow: [
//         BoxShadow(
//           color: appColors.accent.withOpacity(0.35),
//           blurRadius: 20,
//           offset: const Offset(0, 8),
//         ),
//       ],
//     ),
//     child: Stack(
//       children: [
//         // Decorative circles
//         Positioned(
//           right: -24,
//           top: -24,
//           child: Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.06),
//             ),
//           ),
//         ),
//         Positioned(
//           left: -12,
//           bottom: -32,
//           child: Container(
//             width: 90,
//             height: 90,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.06),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(22),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   // Avatar
//                   Container(
//                     width: 72,
//                     height: 72,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.2),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.4),
//                         width: 2.5,
//                       ),
//                     ),
//                     child: ClipOval(
//                       child: a.avatar.isNotEmpty
//                           ? Image.network(
//                               a.avatar,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) =>
//                                   _avatarFallback(a.name),
//                             )
//                           : _avatarFallback(a.name),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           a.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: -0.4,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           a.email,
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.75),
//                             fontSize: 12,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 8),
//                         // Role badge
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.18),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.25),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(
//                                 Icons.shield_rounded,
//                                 size: 11,
//                                 color: Colors.white,
//                               ),
//                               const SizedBox(width: 5),
//                               Text(
//                                 a.role,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700,
//                                   letterSpacing: 0.3,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 18),
//               Divider(color: Colors.white.withOpacity(0.15), height: 1),
//               const SizedBox(height: 14),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today_rounded,
//                     size: 12,
//                     color: Colors.white.withOpacity(0.6),
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Member since ${_fmtDate(a.joinedOn)}',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.7),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );

//   Widget _avatarFallback(String name) => Container(
//     color: Colors.white.withOpacity(0.2),
//     child: Center(
//       child: Text(
//         name.isNotEmpty ? name[0].toUpperCase() : '?',
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 28,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     ),
//   );

//   // ─── Info Card ─────────────────────────────────────────────────────────────

//   Widget _infoCard(AccountInfo a) => Container(
//     decoration: BoxDecoration(
//       color: appColors.surface,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: appColors.border),
//       boxShadow: [
//         BoxShadow(
//           color: appColors.shadow,
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Column(
//       children: [
//         _infoRow(
//           icon: Icons.person_rounded,
//           iconColor: appColors.accent,
//           iconBg: appColors.accentLight,
//           label: 'Full Name',
//           value: a.name,
//           isFirst: true,
//         ),
//         _divider(),
//         _infoRow(
//           icon: Icons.email_rounded,
//           iconColor: appColors.purple,
//           iconBg: appColors.purpleLight,
//           label: 'Email Address',
//           value: a.email,
//         ),
//         _divider(),
//         _infoRow(
//           icon: Icons.phone_rounded,
//           iconColor: appColors.teal,
//           iconBg: appColors.tealLight,
//           label: 'Phone Number',
//           value: a.phoneNumber.isNotEmpty ? a.phoneNumber : '—',
//           isLast: true,
//         ),
//       ],
//     ),
//   );

//   Widget _roleCard(AccountInfo a) => Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: appColors.surface,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: appColors.border),
//       boxShadow: [
//         BoxShadow(
//           color: appColors.shadow,
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Row(
//       children: [
//         Container(
//           width: 44,
//           height: 44,
//           decoration: BoxDecoration(
//             color: appColors.greenLight,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             Icons.verified_user_rounded,
//             color: appColors.green,
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 a.role,
//                 style: TextStyle(
//                   color: appColors.textPrimary,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 'Full system access',
//                 style: TextStyle(color: appColors.textMuted, fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: appColors.greenLight,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: appColors.green.withOpacity(0.25)),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 6,
//                 height: 6,
//                 decoration: BoxDecoration(
//                   color: appColors.green,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 5),
//               Text(
//                 'ACTIVE',
//                 style: TextStyle(
//                   color: appColors.green,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );

//   Widget _infoRow({
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBg,
//     required String label,
//     required String value,
//     bool isFirst = false,
//     bool isLast = false,
//   }) => Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     child: Row(
//       children: [
//         Container(
//           width: 38,
//           height: 38,
//           decoration: BoxDecoration(
//             color: iconBg,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: iconColor, size: 17),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: appColors.textMuted,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: appColors.textPrimary,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );

//   Widget _divider() => Divider(
//     height: 1,
//     thickness: 1,
//     color: appColors.borderLight,
//     indent: 68,
//   );

//   Widget _sectionLabel(String text) => Text(
//     text,
//     style: TextStyle(
//       color: appColors.textPrimary,
//       fontSize: 15,
//       fontWeight: FontWeight.w700,
//       letterSpacing: -0.2,
//     ),
//   );

//   Widget _loader() => Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           width: 44,
//           height: 44,
//           child: CircularProgressIndicator(
//             color: appColors.accent,
//             strokeWidth: 2.5,
//             strokeCap: StrokeCap.round,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'Loading profile…',
//           style: TextStyle(color: appColors.textMuted, fontSize: 13),
//         ),
//       ],
//     ),
//   );

//   Widget _errorView() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: appColors.orangeLight,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.cloud_off_rounded,
//               color: appColors.orange,
//               size: 36,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Could not load profile',
//             style: TextStyle(
//               color: appColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _error ?? 'An unexpected error occurred.',
//             style: TextStyle(color: appColors.textSecondary, fontSize: 13),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           FilledButton.icon(
//             onPressed: _load,
//             icon: const Icon(Icons.refresh_rounded, size: 16),
//             label: const Text('Try Again'),
//             style: FilledButton.styleFrom(
//               backgroundColor: appColors.accent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// // ─── Edit Account Dialog ──────────────────────────────────────────────────────

// class _EditAccountDialog extends StatefulWidget {
//   final AccountInfo account;
//   final VoidCallback onUpdated;

//   const _EditAccountDialog({required this.account, required this.onUpdated});

//   @override
//   State<_EditAccountDialog> createState() => _EditAccountDialogState();
// }

// class _EditAccountDialogState extends State<_EditAccountDialog> {
//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _newPassCtrl = TextEditingController();
//   final _confirmPassCtrl = TextEditingController();

//   bool _obscureNew = true;
//   bool _obscureConfirm = true;
//   bool _saving = false;
//   String? _errorMsg;

//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl.text = widget.account.name;
//     _emailCtrl.text = widget.account.email;
//     _phoneCtrl.text = widget.account.phoneNumber;
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _emailCtrl.dispose();
//     _phoneCtrl.dispose();
//     _newPassCtrl.dispose();
//     _confirmPassCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     final newPass = _newPassCtrl.text.trim();
//     final confirmPass = _confirmPassCtrl.text.trim();

//     if (newPass.isNotEmpty && newPass != confirmPass) {
//       setState(() => _errorMsg = 'Passwords do not match.');
//       return;
//     }

//     setState(() {
//       _saving = true;
//       _errorMsg = null;
//     });

//     try {
//       final body = <String, dynamic>{
//         'name': _nameCtrl.text.trim(),
//         'email': _emailCtrl.text.trim(),
//         'phone_number': _phoneCtrl.text.trim(),
//       };
//       if (newPass.isNotEmpty) {
//         body['newPassword'] = newPass;
//         body['confirmPassword'] = confirmPass;
//       }

//       final res = await ApiService.post('/user/update', body);

//       if (res.statusCode == 200) {
//         if (mounted) {
//           Navigator.pop(context);
//           widget.onUpdated();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Account updated successfully'),
//               backgroundColor: appColors.green,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           );
//         }
//       } else {
//         final json = jsonDecode(res.body);
//         throw Exception(
//           json['message']?.toString() ?? 'Server error ${res.statusCode}',
//         );
//       }
//     } catch (e) {
//       if (mounted) setState(() => _errorMsg = e.toString());
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
//       child: Container(
//         decoration: BoxDecoration(
//           color: appColors.surface,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.12),
//               blurRadius: 32,
//               offset: const Offset(0, 12),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ── Header ──
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: appColors.accentLight,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(
//                       Icons.edit_rounded,
//                       color: appColors.accent,
//                       size: 17,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Edit Account Information',
//                       style: TextStyle(
//                         color: appColors.textPrimary,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: appColors.surfaceHigh,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: appColors.border),
//                       ),
//                       child: Icon(
//                         Icons.close_rounded,
//                         color: appColors.textSecondary,
//                         size: 15,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Divider(height: 20, thickness: 1, color: appColors.borderLight),

//             // ── Form ──
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                 child: Column(
//                   children: [
//                     // Error banner
//                     if (_errorMsg != null) ...[
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: appColors.redLight,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: appColors.red.withOpacity(0.2),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.error_outline_rounded,
//                               color: appColors.red,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 _errorMsg!,
//                                 style: TextStyle(
//                                   color: appColors.red,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 14),
//                     ],

//                     _field(
//                       ctrl: _nameCtrl,
//                       label: 'Name',
//                       hint: 'Enter your name',
//                       icon: Icons.person_outline_rounded,
//                     ),
//                     const SizedBox(height: 14),
//                     _field(
//                       ctrl: _emailCtrl,
//                       label: 'Email',
//                       hint: 'Enter your email',
//                       icon: Icons.email_outlined,
//                       keyboardType: TextInputType.emailAddress,
//                     ),
//                     const SizedBox(height: 14),
//                     _field(
//                       ctrl: _phoneCtrl,
//                       label: 'Phone Number',
//                       hint: 'Enter phone number',
//                       icon: Icons.phone_outlined,
//                       keyboardType: TextInputType.phone,
//                     ),
//                     const SizedBox(height: 20),

//                     // Password section header
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Divider(
//                             color: appColors.borderLight,
//                             height: 1,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Text(
//                             'Change Password (optional)',
//                             style: TextStyle(
//                               color: appColors.textMuted,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Divider(
//                             color: appColors.borderLight,
//                             height: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 14),

//                     _passwordField(
//                       ctrl: _newPassCtrl,
//                       label: 'New Password',
//                       hint: 'Enter new password',
//                       obscure: _obscureNew,
//                       onToggle: () =>
//                           setState(() => _obscureNew = !_obscureNew),
//                     ),
//                     const SizedBox(height: 14),
//                     _passwordField(
//                       ctrl: _confirmPassCtrl,
//                       label: 'Confirm Password',
//                       hint: 'Confirm new password',
//                       obscure: _obscureConfirm,
//                       onToggle: () =>
//                           setState(() => _obscureConfirm = !_obscureConfirm),
//                     ),
//                     const SizedBox(height: 20),

//                     // Submit button
//                     SizedBox(
//                       width: double.infinity,
//                       child: FilledButton.icon(
//                         onPressed: _saving ? null : _submit,
//                         icon: _saving
//                             ? SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Icon(Icons.save_rounded, size: 16),
//                         label: Text(_saving ? 'Updating…' : 'Update'),
//                         style: FilledButton.styleFrom(
//                           backgroundColor: appColors.accent,
//                           foregroundColor: Colors.white,
//                           disabledBackgroundColor: appColors.accent.withOpacity(
//                             0.6,
//                           ),
//                           disabledForegroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           textStyle: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _field({
//     required TextEditingController ctrl,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType? keyboardType,
//   }) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: TextStyle(
//           color: appColors.textSecondary,
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       const SizedBox(height: 6),
//       TextFormField(
//         controller: ctrl,
//         keyboardType: keyboardType,
//         style: TextStyle(
//           color: appColors.textPrimary,
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
//           prefixIcon: Icon(icon, color: appColors.textMuted, size: 17),
//           filled: true,
//           fillColor: appColors.surfaceHigh,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 13,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: appColors.border),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: appColors.border),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: appColors.accent, width: 1.5),
//           ),
//         ),
//       ),
//     ],
//   );

//   Widget _passwordField({
//     required TextEditingController ctrl,
//     required String label,
//     required String hint,
//     required bool obscure,
//     required VoidCallback onToggle,
//   }) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: TextStyle(
//           color: appColors.textSecondary,
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       const SizedBox(height: 6),
//       TextFormField(
//         controller: ctrl,
//         obscureText: obscure,
//         style: TextStyle(
//           color: appColors.textPrimary,
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
//           prefixIcon: Icon(
//             Icons.lock_outline_rounded,
//             color: appColors.textMuted,
//             size: 17,
//           ),
//           suffixIcon: IconButton(
//             onPressed: onToggle,
//             icon: Icon(
//               obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
//               color: appColors.textMuted,
//               size: 17,
//             ),
//           ),
//           filled: true,
//           fillColor: appColors.surfaceHigh,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 13,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: appColors.border),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: appColors.border),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: appColors.accent, width: 1.5),
//           ),
//         ),
//       ),
//     ],
//   );
// }

// <<<<<<<<<<<<<<<<< NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cms_app/theme/app_colors.dart';
import 'package:cms_app/theme/custom_app_bar.dart';
import 'package:cms_app/services/api_service.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class AccountInfo {
  final String userId, name, email, phoneNumber, role, joinedOn, avatar;

  const AccountInfo({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.joinedOn,
    required this.avatar,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> j) {
    final a = (j['account'] as Map<String, dynamic>?) ?? {};
    return AccountInfo(
      userId: a['user_id']?.toString() ?? '',
      name: a['name']?.toString() ?? '',
      email: a['email']?.toString() ?? '',
      phoneNumber: a['phone_number']?.toString() ?? '',
      role: a['role']?.toString() ?? '',
      joinedOn: a['joined_on']?.toString() ?? '',
      avatar: a['avatar']?.toString() ?? '',
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  AccountInfo? _account;
  String? _error;

  AnimationController? _fadeCtrl;
  Animation<double>? _fadeAnim;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeCtrl = ctrl;
    _fadeAnim = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.get('/user/account');
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        if (mounted) {
          setState(() => _account = AccountInfo.fromJson(json));
          _fadeCtrl?.forward(from: 0);
        }
      } else {
        throw Exception('Server error ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  void _openEditDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => _EditAccountDialog(account: _account!, onUpdated: _load),
    );
  }

  // ── NEW: separate reset password dialog ──
  void _openResetPasswordDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => _ResetPasswordDialog(onUpdated: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.bg,
      appBar: CustomAppBar(title: 'My Profile', onRefresh: _load),
      body: _loading
          ? _loader()
          : _error != null
          ? _errorView()
          : _fadeAnim != null
          ? FadeTransition(opacity: _fadeAnim!, child: _body())
          : _body(),
    );
  }

  Widget _body() {
    final a = _account!;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero card ──
          _heroCard(a),
          const SizedBox(height: 20),

          // ── Info card ──
          _sectionLabel('Account Details'),
          const SizedBox(height: 10),
          _infoCard(a),
          const SizedBox(height: 20),

          // ── Role card ──
          _sectionLabel('Role & Access'),
          const SizedBox(height: 10),
          _roleCard(a),
          const SizedBox(height: 24),

          // ── Edit account button ──
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openEditDialog,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit Account Information'),
              style: FilledButton.styleFrom(
                backgroundColor: appColors.accent,
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
          const SizedBox(height: 12),

          // ── Reset password button ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openResetPasswordDialog,
              icon: Icon(
                Icons.lock_reset_rounded,
                size: 16,
                color: appColors.purple,
              ),
              label: Text(
                'Reset Password',
                style: TextStyle(
                  color: appColors.purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: appColors.purple.withOpacity(0.4)),
                backgroundColor: appColors.purpleLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero Card ─────────────────────────────────────────────────────────────

  Widget _heroCard(AccountInfo a) => Container(
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
  );

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

  // ─── Info Card ─────────────────────────────────────────────────────────────

  Widget _infoCard(AccountInfo a) => Container(
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
      children: [
        _infoRow(
          icon: Icons.person_rounded,
          iconColor: appColors.accent,
          iconBg: appColors.accentLight,
          label: 'Full Name',
          value: a.name,
        ),
        _divider(),
        _infoRow(
          icon: Icons.email_rounded,
          iconColor: appColors.purple,
          iconBg: appColors.purpleLight,
          label: 'Email Address',
          value: a.email,
        ),
        _divider(),
        _infoRow(
          icon: Icons.phone_rounded,
          iconColor: appColors.teal,
          iconBg: appColors.tealLight,
          label: 'Phone Number',
          value: a.phoneNumber.isNotEmpty ? a.phoneNumber : '—',
        ),
      ],
    ),
  );

  Widget _roleCard(AccountInfo a) => Container(
    padding: const EdgeInsets.all(16),
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
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: appColors.greenLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.verified_user_rounded,
            color: appColors.green,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.role,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Full system access',
                style: TextStyle(color: appColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: appColors.greenLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: appColors.green.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: appColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'ACTIVE',
                style: TextStyle(
                  color: appColors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: appColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: appColors.borderLight,
    indent: 68,
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: appColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
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
            color: appColors.accent,
            strokeWidth: 2.5,
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading profile…',
          style: TextStyle(color: appColors.textMuted, fontSize: 13),
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
              color: appColors.orangeLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: appColors.orange,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Could not load profile',
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'An unexpected error occurred.',
            style: TextStyle(color: appColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: appColors.accent,
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
}

// ─── Edit Account Dialog (name, email, phone only) ────────────────────────────

class _EditAccountDialog extends StatefulWidget {
  final AccountInfo account;
  final VoidCallback onUpdated;

  const _EditAccountDialog({required this.account, required this.onUpdated});

  @override
  State<_EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<_EditAccountDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _saving = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.account.name;
    _emailCtrl.text = widget.account.email;
    _phoneCtrl.text = widget.account.phoneNumber;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _errorMsg = null;
    });

    try {
      final body = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone_number': _phoneCtrl.text.trim(),
      };

      final res = await ApiService.put('/user/update', body);

      if (res.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          widget.onUpdated();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account updated successfully'),
              backgroundColor: appColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        final json = jsonDecode(res.body);
        throw Exception(
          json['message']?.toString() ?? 'Server error ${res.statusCode}',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: appColors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: appColors.accent,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Account Information',
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: appColors.surfaceHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: appColors.border),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: appColors.textSecondary,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 20, thickness: 1, color: appColors.borderLight),

            // ── Form ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // Error banner
                    if (_errorMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: appColors.redLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appColors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: appColors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: TextStyle(
                                  color: appColors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    _field(
                      ctrl: _nameCtrl,
                      label: 'Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      ctrl: _emailCtrl,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      ctrl: _phoneCtrl,
                      label: 'Phone Number',
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _submit,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 16),
                        label: Text(_saving ? 'Updating…' : 'Update'),
                        style: FilledButton.styleFrom(
                          backgroundColor: appColors.accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: appColors.accent.withOpacity(
                            0.6,
                          ),
                          disabledForegroundColor: Colors.white,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: appColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(
          color: appColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: appColors.textMuted, size: 17),
          filled: true,
          fillColor: appColors.surfaceHigh,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: appColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: appColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: appColors.accent, width: 1.5),
          ),
        ),
      ),
    ],
  );
}

// ─── Reset Password Dialog (password fields only) ─────────────────────────────

class _ResetPasswordDialog extends StatefulWidget {
  final VoidCallback onUpdated;
  const _ResetPasswordDialog({required this.onUpdated});

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  String? _errorMsg;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPass = _newPassCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (newPass.isEmpty) {
      setState(() => _errorMsg = 'Please enter a new password.');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorMsg = 'Passwords do not match.');
      return;
    }

    final passwordRegex = RegExp(
      r'^(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$',
    );

    if (!passwordRegex.hasMatch(newPass)) {
      setState(() {
        _errorMsg =
            'Password must be at least 8 characters long and include at least one number and one special character.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMsg = null;
    });

    try {
      final body = <String, dynamic>{
        'newPassword': newPass,
        'confirmPassword': confirmPass,
      };

      final res = await ApiService.put('/user/update', body);

      if (res.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          widget.onUpdated();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password reset successfully'),
              backgroundColor: appColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        final json = jsonDecode(res.body);
        throw Exception(
          json['message']?.toString() ?? 'Server error ${res.statusCode}',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: appColors.purpleLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: appColors.purple,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: appColors.surfaceHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: appColors.border),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: appColors.textSecondary,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 20, thickness: 1, color: appColors.borderLight),

            // ── Form ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appColors.purpleLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appColors.purple.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: appColors.purple,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Enter your new password below. This will update your login credentials.',
                            style: TextStyle(
                              color: appColors.purple,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error banner
                  if (_errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: appColors.redLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: appColors.red.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: appColors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMsg!,
                              style: TextStyle(
                                color: appColors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // New password
                  _passwordField(
                    ctrl: _newPassCtrl,
                    label: 'New Password',
                    hint: 'Enter new password',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 14),

                  // Confirm password
                  _passwordField(
                    ctrl: _confirmPassCtrl,
                    label: 'Confirm Password',
                    hint: 'Confirm new password',
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.lock_reset_rounded, size: 16),
                      label: Text(_saving ? 'Resetting…' : 'Reset Password'),
                      style: FilledButton.styleFrom(
                        backgroundColor: appColors.purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: appColors.purple.withOpacity(
                          0.6,
                        ),
                        disabledForegroundColor: Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: appColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        style: TextStyle(
          color: appColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: appColors.textMuted,
            size: 17,
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: appColors.textMuted,
              size: 17,
            ),
          ),
          filled: true,
          fillColor: appColors.surfaceHigh,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: appColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: appColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: appColors.purple, width: 1.5),
          ),
        ),
      ),
    ],
  );
}
