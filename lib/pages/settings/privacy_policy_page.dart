// import 'package:flutter/material.dart';

// /// USE YOUR GLOBAL THEME
// const _c = _Colors();

// class _Colors {
//   const _Colors();
//   Color get accent => const Color(0xFF2563EB);
//   Color get accentLight => const Color(0xFFEFF6FF);
//   Color get green => const Color(0xFF059669);
//   Color get greenLight => const Color(0xFFECFDF5);
//   Color get orange => const Color(0xFFEA580C);
//   Color get orangeLight => const Color(0xFFFFF7ED);
//   Color get yellow => const Color(0xFFD97706);
//   Color get yellowLight => const Color(0xFFFFFBEB);
//   Color get purple => const Color(0xFF7C3AED);
//   Color get purpleLight => const Color(0xFFF5F3FF);
//   Color get red => const Color(0xFFDC2626);
//   Color get redLight => const Color(0xFFFEF2F2);
//   Color get teal => const Color(0xFF0891B2);
//   Color get tealLight => const Color(0xFFECFEFF);
//   Color get bg => const Color(0xFFF1F5F9);
//   Color get surface => const Color(0xFFFFFFFF);
//   Color get surfaceHigh => const Color(0xFFF8FAFC);
//   Color get textPrimary => const Color(0xFF0F172A);
//   Color get textSecondary => const Color(0xFF475569);
//   Color get textMuted => const Color(0xFF94A3B8);
//   Color get border => const Color(0xFFE2E8F0);
//   Color get borderLight => const Color(0xFFF1F5F9);
//   Color get shadow => const Color(0x08000000);
// }

// class PrivacyPolicyPage extends StatelessWidget {
//   const PrivacyPolicyPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _c.bg,

//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: _c.surface,
//         foregroundColor: _c.textPrimary,

//         title: const Text(
//           "Privacy Policy",
//           style: TextStyle(fontWeight: FontWeight.w800),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(18),

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,

//           children: [
//             _heroCard(),

//             const SizedBox(height: 24),

//             _section("Last Updated", "August 11, 2025"),

//             _section(
//               "About Demokrito",
//               "SRI SIVANANDA DEMOKRITO MARKET INSIGHTS SERVICES PRIVATE LIMITED "
//                   "(CIN U62090AP2024PTC117044), headquartered at "
//                   "B-5101, Aparna Amaravati One, Mangalagiri, "
//                   "Kunchanapalle, Tadepalle, Guntur – 522501, Andhra Pradesh.",
//             ),

//             _section(
//               "Scope & Applicability",
//               "This Privacy Policy applies to all Demokrito platforms, "
//                   "services, applications, and AI-powered systems.",
//             ),

//             _sectionTitle("Information We Collect"),

//             _bulletCard(
//               context,
//               title: "Personal Information",
//               icon: Icons.person_rounded,

//               items: [
//                 "Name",
//                 "Email address",
//                 "Phone number",
//                 "Company name",
//                 "Login credentials",
//                 "Location details",
//               ],
//             ),

//             _bulletCard(
//               context,
//               title: "Non-Personal Information",
//               icon: Icons.analytics_rounded,

//               items: [
//                 "IP address",
//                 "Browser/device type",
//                 "Operating system",
//                 "Usage analytics",
//                 "Referring URLs",
//               ],
//             ),

//             _sectionTitle("Platform-Specific Data"),

//             _platformCard(
//               context,
//               title: "Ad96 CMS Player",
//               description:
//                   "Campaign metadata, device identifiers, media files, "
//                   "scheduling information, and performance statistics.",
//               icon: Icons.tv_rounded,
//               color: _c.accent,
//               bg: _c.accentLight,
//             ),

//             _platformCard(
//               context,
//               title: "Demokrito TMS",
//               description:
//                   "Task-related media uploads used only for tracking and validation.",
//               icon: Icons.task_alt_rounded,
//               color: _c.green,
//               bg: _c.greenLight,
//             ),

//             _platformCard(
//               context,
//               title: "AI Models",
//               description:
//                   "Survey XML AI and validation models process client data "
//                   "strictly for contracted services.",
//               icon: Icons.auto_awesome_rounded,
//               color: _c.purple,
//               bg: _c.purpleLight,
//             ),

//             _sectionTitle("How We Use Information"),

//             _bulletCard(
//               context,
//               title: "Purpose of Use",
//               icon: Icons.settings_rounded,

//               items: [
//                 "Operating services",
//                 "Customer support",
//                 "Security monitoring",
//                 "Notifications",
//                 "Performance improvements",
//                 "Payment processing",
//               ],
//             ),

//             _section(
//               "Cookies & Tracking",
//               "Cookies are used to improve user experience and service functionality.",
//             ),

//             _section(
//               "Sharing of Information",
//               "We do not sell personal information. Data is shared only "
//                   "with trusted providers under strict confidentiality.",
//             ),

//             _sectionTitle("Data Security"),

//             _bulletCard(
//               context,
//               title: "Security Measures",
//               icon: Icons.security_rounded,

//               items: [
//                 "AWS secure hosting",
//                 "HTTPS/TLS encryption",
//                 "AES-256 encryption",
//                 "Role-Based Access Control",
//                 "Multi-Factor Authentication",
//                 "Audit logging",
//                 "Incident response procedures",
//               ],
//             ),

//             _sectionTitle("Privacy Commitments"),

//             _commitmentCard(
//               title: "AI Training Exclusion",
//               description:
//                   "Client and respondent data is never used to train AI models.",
//               color: _c.green,
//               bg: _c.greenLight,
//             ),

//             _commitmentCard(
//               title: "Limited Purpose Usage",
//               description: "Data is processed only for requested services.",
//               color: _c.orange,
//               bg: _c.orangeLight,
//             ),

//             _commitmentCard(
//               title: "Confidentiality",
//               description:
//                   "All client information remains confidential and protected.",
//               color: _c.teal,
//               bg: _c.tealLight,
//             ),

//             _section(
//               "Your Rights",
//               "You may request access, correction, or deletion of your data.",
//             ),

//             _section(
//               "Children’s Privacy",
//               "Our services are not intended for children under 13.",
//             ),

//             _section(
//               "Changes to This Policy",
//               "We may update this policy periodically. Continued use "
//                   "implies acceptance of updates.",
//             ),

//             const SizedBox(height: 24),

//             _contactCard(),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   /// HERO
//   Widget _heroCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.all(26),

//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [_c.accent, _c.teal],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),

//         borderRadius: BorderRadius.circular(28),

//         boxShadow: [
//           BoxShadow(
//             color: _c.accent.withOpacity(0.2),
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),

//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.14),
//               shape: BoxShape.circle,
//             ),

//             child: const Icon(
//               Icons.privacy_tip_rounded,
//               color: Colors.white,
//               size: 34,
//             ),
//           ),

//           const SizedBox(height: 18),

//           const Text(
//             "Privacy Policy",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 32,
//               fontWeight: FontWeight.w900,
//               letterSpacing: -1,
//             ),
//           ),

//           const SizedBox(height: 10),

//           Text(
//             "Your privacy and data security are important to us.",
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.9),
//               fontSize: 15,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// SECTION TITLE
//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10, bottom: 14),

//       child: Text(
//         title,
//         style: TextStyle(
//           color: _c.textPrimary,
//           fontSize: 24,
//           fontWeight: FontWeight.w800,
//           letterSpacing: -0.5,
//         ),
//       ),
//     );
//   }

//   /// NORMAL CARD
//   Widget _section(String title, String content) {
//     return Container(
//       width: double.infinity,

//       margin: const EdgeInsets.only(bottom: 16),

//       padding: const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         color: _c.surface,

//         borderRadius: BorderRadius.circular(22),

//         border: Border.all(color: _c.border),

//         boxShadow: [
//           BoxShadow(
//             color: _c.shadow,
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: _c.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//             ),
//           ),

//           const SizedBox(height: 10),

//           Text(
//             content,
//             style: TextStyle(
//               color: _c.textSecondary,
//               fontSize: 14,
//               height: 1.7,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// BULLET CARD
//   Widget _bulletCard(
//     BuildContext context, {
//     required String title,
//     required List<String> items,
//     required IconData icon,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),

//       padding: const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         color: _c.surface,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: _c.border),
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: _c.accentLight,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, color: _c.accent),
//               ),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: Text(
//                   title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: _c.textPrimary,
//                     fontSize: MediaQuery.of(context).size.width < 380 ? 15 : 18,
//                     fontWeight: FontWeight.w800,
//                     height: 1.2,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 18),

//           ...items.map(
//             (e) => Padding(
//               padding: const EdgeInsets.only(bottom: 12),

//               child: IntrinsicHeight(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,

//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(top: 7),

//                       width: 8,
//                       height: 8,

//                       decoration: BoxDecoration(
//                         color: _c.accent,
//                         shape: BoxShape.circle,
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     Expanded(
//                       child: Text(
//                         e,
//                         style: TextStyle(
//                           color: _c.textSecondary,
//                           height: 1.5,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// PLATFORM CARD
//   Widget _platformCard(
//     BuildContext context, {
//     required String title,
//     required String description,
//     required IconData icon,
//     required Color color,
//     required Color bg,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),

//       padding: const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         color: _c.surface,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: _c.border),
//       ),

//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),

//             decoration: BoxDecoration(
//               color: bg,
//               borderRadius: BorderRadius.circular(16),
//             ),

//             child: Icon(icon, color: color),
//           ),

//           const SizedBox(width: 16),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,

//               children: [
//                 Text(
//                   title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: _c.textPrimary,

//                     fontSize: MediaQuery.of(context).size.width < 380 ? 15 : 17,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 Text(
//                   description,
//                   style: TextStyle(
//                     color: _c.textSecondary,
//                     height: 1.5,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// COMMITMENT CARD
//   Widget _commitmentCard({
//     required String title,
//     required String description,
//     required Color color,
//     required Color bg,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),

//       padding: const EdgeInsets.all(18),

//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),

//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),

//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               shape: BoxShape.circle,
//             ),

//             child: Icon(Icons.verified_user_rounded, color: color),
//           ),

//           const SizedBox(width: 14),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,

//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: _c.textPrimary,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),

//                 const SizedBox(height: 5),

//                 Text(
//                   description,
//                   style: TextStyle(color: _c.textSecondary, height: 1.5),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// CONTACT CARD
//   Widget _contactCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.all(24),

//       decoration: BoxDecoration(
//         color: _c.surface,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: _c.border),
//       ),

//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),

//             decoration: BoxDecoration(
//               color: _c.accentLight,
//               shape: BoxShape.circle,
//             ),

//             child: Icon(Icons.mail_outline_rounded, color: _c.accent, size: 34),
//           ),

//           const SizedBox(height: 18),

//           Text(
//             "Contact Us",
//             style: TextStyle(
//               color: _c.textPrimary,
//               fontSize: 24,
//               fontWeight: FontWeight.w900,
//             ),
//           ),

//           const SizedBox(height: 10),

//           Text(
//             "For privacy concerns or data access requests",
//             textAlign: TextAlign.center,

//             style: TextStyle(color: _c.textSecondary),
//           ),

//           const SizedBox(height: 20),

//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

//             decoration: BoxDecoration(
//               color: _c.accentLight,
//               borderRadius: BorderRadius.circular(14),
//             ),

//             child: Text(
//               "privacy@demokrito.com",
//               style: TextStyle(
//                 color: _c.accent,
//                 fontWeight: FontWeight.w800,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
import 'package:flutter/material.dart';
import 'package:cms_app/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Privacy Policy',
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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card (mirrors DeviceGroupDetailsPage _heroCard) ──
            _heroCard(),
            const SizedBox(height: 20),

            // ── Last Updated ──
            _infoCard(
              icon: Icons.calendar_today_rounded,
              iconColor: appColors.accent,
              iconBg: appColors.accentLight,
              title: 'Last Updated',
              body: 'August 11, 2025',
            ),
            const SizedBox(height: 12),

            // ── About ──
            _infoCard(
              icon: Icons.business_rounded,
              iconColor: appColors.purple,
              iconBg: appColors.purpleLight,
              title: 'About Demokrito',
              body:
                  'SRI SIVANANDA DEMOKRITO MARKET INSIGHTS SERVICES PRIVATE LIMITED '
                  '(CIN U62090AP2024PTC117044), headquartered at '
                  'B-5101, Aparna Amaravati One, Mangalagiri, '
                  'Kunchanapalle, Tadepalle, Guntur – 522501, Andhra Pradesh.',
            ),
            const SizedBox(height: 12),

            // ── Scope ──
            _infoCard(
              icon: Icons.public_rounded,
              iconColor: appColors.teal,
              iconBg: appColors.tealLight,
              title: 'Scope & Applicability',
              body:
                  'This Privacy Policy applies to all Demokrito platforms, '
                  'services, applications, and AI-powered systems.',
            ),
            const SizedBox(height: 20),

            // ── Information We Collect ──
            _sectionLabel('Information We Collect'),
            const SizedBox(height: 10),

            _bulletCard(
              icon: Icons.person_rounded,
              iconColor: appColors.accent,
              iconBg: appColors.accentLight,
              title: 'Personal Information',
              items: const [
                'Name',
                'Email address',
                'Phone number',
                'Company name',
                'Login credentials',
                'Location details',
              ],
            ),
            const SizedBox(height: 12),

            _bulletCard(
              icon: Icons.analytics_rounded,
              iconColor: appColors.purple,
              iconBg: appColors.purpleLight,
              title: 'Non-Personal Information',
              items: const [
                'IP address',
                'Browser / device type',
                'Operating system',
                'Usage analytics',
                'Referring URLs',
              ],
            ),
            const SizedBox(height: 20),

            // ── Platform-Specific Data ──
            _sectionLabel('Platform-Specific Data'),
            const SizedBox(height: 10),

            _platformCard(
              icon: Icons.tv_rounded,
              iconColor: appColors.accent,
              iconBg: appColors.accentLight,
              title: 'Ad96 CMS Player',
              body:
                  'Campaign metadata, device identifiers, media files, '
                  'scheduling information, and performance statistics.',
            ),
            const SizedBox(height: 12),

            _platformCard(
              icon: Icons.task_alt_rounded,
              iconColor: appColors.green,
              iconBg: appColors.greenLight,
              title: 'Demokrito TMS',
              body:
                  'Task-related media uploads used only for tracking and validation.',
            ),
            const SizedBox(height: 12),

            _platformCard(
              icon: Icons.auto_awesome_rounded,
              iconColor: appColors.purple,
              iconBg: appColors.purpleLight,
              title: 'AI Models',
              body:
                  'Survey XML AI and validation models process client data '
                  'strictly for contracted services.',
            ),
            const SizedBox(height: 20),

            // ── How We Use Information ──
            _sectionLabel('How We Use Information'),
            const SizedBox(height: 10),

            _bulletCard(
              icon: Icons.settings_rounded,
              iconColor: appColors.teal,
              iconBg: appColors.tealLight,
              title: 'Purpose of Use',
              items: const [
                'Operating services',
                'Customer support',
                'Security monitoring',
                'Notifications',
                'Performance improvements',
                'Payment processing',
              ],
            ),
            const SizedBox(height: 20),

            // ── Policies ──
            _sectionLabel('Policies'),
            const SizedBox(height: 10),

            _infoCard(
              icon: Icons.cookie_rounded,
              iconColor: appColors.yellow,
              iconBg: appColors.yellowLight,
              title: 'Cookies & Tracking',
              body:
                  'Cookies are used to improve user experience and service functionality.',
            ),
            const SizedBox(height: 12),

            _infoCard(
              icon: Icons.share_rounded,
              iconColor: appColors.orange,
              iconBg: appColors.orangeLight,
              title: 'Sharing of Information',
              body:
                  'We do not sell personal information. Data is shared only '
                  'with trusted providers under strict confidentiality.',
            ),
            const SizedBox(height: 20),

            // ── Data Security ──
            _sectionLabel('Data Security'),
            const SizedBox(height: 10),

            _bulletCard(
              icon: Icons.security_rounded,
              iconColor: appColors.green,
              iconBg: appColors.greenLight,
              title: 'Security Measures',
              items: const [
                'AWS secure hosting',
                'HTTPS / TLS encryption',
                'AES-256 encryption',
                'Role-Based Access Control',
                'Multi-Factor Authentication',
                'Audit logging',
                'Incident response procedures',
              ],
            ),
            const SizedBox(height: 20),

            // ── Privacy Commitments ──
            _sectionLabel('Privacy Commitments'),
            const SizedBox(height: 10),

            _commitmentCard(
              icon: Icons.model_training_rounded,
              iconColor: appColors.green,
              iconBg: appColors.greenLight,
              title: 'AI Training Exclusion',
              body:
                  'Client and respondent data is never used to train AI models.',
            ),
            const SizedBox(height: 10),

            _commitmentCard(
              icon: Icons.adjust_rounded,
              iconColor: appColors.orange,
              iconBg: appColors.orangeLight,
              title: 'Limited Purpose Usage',
              body: 'Data is processed only for requested services.',
            ),
            const SizedBox(height: 10),

            _commitmentCard(
              icon: Icons.lock_rounded,
              iconColor: appColors.teal,
              iconBg: appColors.tealLight,
              title: 'Confidentiality',
              body:
                  'All client information remains confidential and protected.',
            ),
            const SizedBox(height: 20),

            // ── Additional ──
            _sectionLabel('Additional Information'),
            const SizedBox(height: 10),

            _infoCard(
              icon: Icons.manage_accounts_rounded,
              iconColor: appColors.accent,
              iconBg: appColors.accentLight,
              title: 'Your Rights',
              body:
                  'You may request access, correction, or deletion of your data.',
            ),
            const SizedBox(height: 12),

            _infoCard(
              icon: Icons.child_care_rounded,
              iconColor: appColors.orange,
              iconBg: appColors.orangeLight,
              title: "Children's Privacy",
              body: 'Our services are not intended for children under 13.',
            ),
            const SizedBox(height: 12),

            _infoCard(
              icon: Icons.update_rounded,
              iconColor: appColors.purple,
              iconBg: appColors.purpleLight,
              title: 'Changes to This Policy',
              body:
                  'We may update this policy periodically. Continued use '
                  'implies acceptance of updates.',
            ),
            const SizedBox(height: 20),

            // ── Contact ──
            _contactCard(),
          ],
        ),
      ),
    );
  }

  // ─── Hero Card ─────────────────────────────────────────────────────────────

  Widget _heroCard() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [appColors.accent, const Color(0xFF1E40AF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: appColors.accent.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: -20,
          top: -20,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          left: -15,
          bottom: -35,
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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.privacy_tip_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your privacy and data security are important to us.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _HeroBadge(
                    icon: Icons.shield_rounded,
                    label: 'GDPR Compliant',
                  ),
                  const SizedBox(width: 8),
                  _HeroBadge(icon: Icons.lock_rounded, label: 'AES-256'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── Section Label ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Row(
    children: [
      Text(
        text,
        style: TextStyle(
          color: appColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    ],
  );

  // ─── Info Card ─────────────────────────────────────────────────────────────

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String body,
  }) => Container(
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: appColors.textSecondary,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── Bullet Card ───────────────────────────────────────────────────────────

  Widget _bulletCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required List<String> items,
  }) => Container(
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: appColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: appColors.borderLight,
                  indent: 16,
                ),
                const SizedBox(height: 6),
              ],
            ],
          );
        }),
      ],
    ),
  );

  // ─── Platform Card ─────────────────────────────────────────────────────────

  Widget _platformCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String body,
  }) => Container(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: appColors.textSecondary,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── Commitment Card ───────────────────────────────────────────────────────

  Widget _commitmentCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String body,
  }) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: iconBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: iconColor.withOpacity(0.15)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: TextStyle(
                  color: appColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── Contact Card ──────────────────────────────────────────────────────────

  Widget _contactCard() => Container(
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
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: appColors.accentLight,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.mail_outline_rounded,
                color: appColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'For privacy concerns or data access requests',
                    style: TextStyle(color: appColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(height: 1, thickness: 1, color: appColors.borderLight),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: appColors.accentLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appColors.accent.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.alternate_email_rounded,
                color: appColors.accent,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'privacy@demokrito.com',
                style: TextStyle(
                  color: appColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
        Icon(icon, color: Colors.white, size: 11),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
