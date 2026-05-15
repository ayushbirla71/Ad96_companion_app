import 'package:flutter/material.dart';

/// USE YOUR GLOBAL THEME
const _c = _Colors();

class _Colors {
  const _Colors();
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
  Color get bg => const Color(0xFFF1F5F9);
  Color get surface => const Color(0xFFFFFFFF);
  Color get surfaceHigh => const Color(0xFFF8FAFC);
  Color get textPrimary => const Color(0xFF0F172A);
  Color get textSecondary => const Color(0xFF475569);
  Color get textMuted => const Color(0xFF94A3B8);
  Color get border => const Color(0xFFE2E8F0);
  Color get borderLight => const Color(0xFFF1F5F9);
  Color get shadow => const Color(0x08000000);
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _c.bg,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: _c.surface,
        foregroundColor: _c.textPrimary,

        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _heroCard(),

            const SizedBox(height: 24),

            _section("Last Updated", "August 11, 2025"),

            _section(
              "About Demokrito",
              "SRI SIVANANDA DEMOKRITO MARKET INSIGHTS SERVICES PRIVATE LIMITED "
                  "(CIN U62090AP2024PTC117044), headquartered at "
                  "B-5101, Aparna Amaravati One, Mangalagiri, "
                  "Kunchanapalle, Tadepalle, Guntur – 522501, Andhra Pradesh.",
            ),

            _section(
              "Scope & Applicability",
              "This Privacy Policy applies to all Demokrito platforms, "
                  "services, applications, and AI-powered systems.",
            ),

            _sectionTitle("Information We Collect"),

            _bulletCard(
              context,
              title: "Personal Information",
              icon: Icons.person_rounded,

              items: [
                "Name",
                "Email address",
                "Phone number",
                "Company name",
                "Login credentials",
                "Location details",
              ],
            ),

            _bulletCard(
              context,
              title: "Non-Personal Information",
              icon: Icons.analytics_rounded,

              items: [
                "IP address",
                "Browser/device type",
                "Operating system",
                "Usage analytics",
                "Referring URLs",
              ],
            ),

            _sectionTitle("Platform-Specific Data"),

            _platformCard(
              context,
              title: "Ad96 CMS Player",
              description:
                  "Campaign metadata, device identifiers, media files, "
                  "scheduling information, and performance statistics.",
              icon: Icons.tv_rounded,
              color: _c.accent,
              bg: _c.accentLight,
            ),

            _platformCard(
              context,
              title: "Demokrito TMS",
              description:
                  "Task-related media uploads used only for tracking and validation.",
              icon: Icons.task_alt_rounded,
              color: _c.green,
              bg: _c.greenLight,
            ),

            _platformCard(
              context,
              title: "AI Models",
              description:
                  "Survey XML AI and validation models process client data "
                  "strictly for contracted services.",
              icon: Icons.auto_awesome_rounded,
              color: _c.purple,
              bg: _c.purpleLight,
            ),

            _sectionTitle("How We Use Information"),

            _bulletCard(
              context,
              title: "Purpose of Use",
              icon: Icons.settings_rounded,

              items: [
                "Operating services",
                "Customer support",
                "Security monitoring",
                "Notifications",
                "Performance improvements",
                "Payment processing",
              ],
            ),

            _section(
              "Cookies & Tracking",
              "Cookies are used to improve user experience and service functionality.",
            ),

            _section(
              "Sharing of Information",
              "We do not sell personal information. Data is shared only "
                  "with trusted providers under strict confidentiality.",
            ),

            _sectionTitle("Data Security"),

            _bulletCard(
              context,
              title: "Security Measures",
              icon: Icons.security_rounded,

              items: [
                "AWS secure hosting",
                "HTTPS/TLS encryption",
                "AES-256 encryption",
                "Role-Based Access Control",
                "Multi-Factor Authentication",
                "Audit logging",
                "Incident response procedures",
              ],
            ),

            _sectionTitle("Privacy Commitments"),

            _commitmentCard(
              title: "AI Training Exclusion",
              description:
                  "Client and respondent data is never used to train AI models.",
              color: _c.green,
              bg: _c.greenLight,
            ),

            _commitmentCard(
              title: "Limited Purpose Usage",
              description: "Data is processed only for requested services.",
              color: _c.orange,
              bg: _c.orangeLight,
            ),

            _commitmentCard(
              title: "Confidentiality",
              description:
                  "All client information remains confidential and protected.",
              color: _c.teal,
              bg: _c.tealLight,
            ),

            _section(
              "Your Rights",
              "You may request access, correction, or deletion of your data.",
            ),

            _section(
              "Children’s Privacy",
              "Our services are not intended for children under 13.",
            ),

            _section(
              "Changes to This Policy",
              "We may update this policy periodically. Continued use "
                  "implies acceptance of updates.",
            ),

            const SizedBox(height: 24),

            _contactCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// HERO
  Widget _heroCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(26),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_c.accent, _c.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: _c.accent.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.privacy_tip_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Privacy Policy",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Your privacy and data security are important to us.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),

      child: Text(
        title,
        style: TextStyle(
          color: _c.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  /// NORMAL CARD
  Widget _section(String title, String content) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _c.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: _c.border),

        boxShadow: [
          BoxShadow(
            color: _c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: TextStyle(
              color: _c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            content,
            style: TextStyle(
              color: _c.textSecondary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  /// BULLET CARD
  Widget _bulletCard(
    BuildContext context, {
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _c.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _c.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _c.accent),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _c.textPrimary,
                    fontSize: MediaQuery.of(context).size.width < 380 ? 15 : 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),

              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),

                      width: 8,
                      height: 8,

                      decoration: BoxDecoration(
                        color: _c.accent,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          color: _c.textSecondary,
                          height: 1.5,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PLATFORM CARD
  Widget _platformCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _c.border),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _c.textPrimary,

                    fontSize: MediaQuery.of(context).size.width < 380 ? 15 : 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: TextStyle(
                    color: _c.textSecondary,
                    height: 1.5,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// COMMITMENT CARD
  Widget _commitmentCard({
    required String title,
    required String description,
    required Color color,
    required Color bg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(Icons.verified_user_rounded, color: color),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _c.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: TextStyle(color: _c.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// CONTACT CARD
  Widget _contactCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _c.border),
      ),

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: _c.accentLight,
              shape: BoxShape.circle,
            ),

            child: Icon(Icons.mail_outline_rounded, color: _c.accent, size: 34),
          ),

          const SizedBox(height: 18),

          Text(
            "Contact Us",
            style: TextStyle(
              color: _c.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "For privacy concerns or data access requests",
            textAlign: TextAlign.center,

            style: TextStyle(color: _c.textSecondary),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

            decoration: BoxDecoration(
              color: _c.accentLight,
              borderRadius: BorderRadius.circular(14),
            ),

            child: Text(
              "privacy@demokrito.com",
              style: TextStyle(
                color: _c.accent,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
