import 'package:flutter/material.dart';

/// GLOBAL COLORS
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

  Color get textPrimary => const Color(0xFF0F172A);

  Color get textSecondary => const Color(0xFF475569);

  Color get border => const Color(0xFFE2E8F0);

  Color get shadow => const Color(0x08000000);
}

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _c.bg,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: _c.surface,
        foregroundColor: _c.textPrimary,

        title: const Text(
          "Terms & Conditions",
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
              "Terms Overview",
              "These Terms and Conditions govern your use of services "
                  "provided by SRI SIVANANDA DEMOKRITO MARKET INSIGHTS "
                  "SERVICES PRIVATE LIMITED.",
            ),

            _sectionTitle("Covered Platforms"),

            _bulletCard(
              context,
              title: "Services Covered",
              icon: Icons.apps_rounded,

              items: [
                "Ad96 CMS Player",
                "Demokrito TMS",
                "Survey XML Tools",
                "Data Validation Tools",
                "Future AI-powered applications",
              ],
            ),

            _section(
              "Acceptance of Terms",
              "By registering, accessing, or using any of our services, "
                  "you agree to comply with these Terms and Conditions.",
            ),

            _sectionTitle("Description of Services"),

            _platformCard(
              context,
              title: "Ad96 CMS Player",
              description:
                  "Advertising CRM platform for managing campaigns, "
                  "uploading media, scheduling ads, and displaying "
                  "content on connected TV devices.",
              icon: Icons.tv_rounded,
              color: _c.accent,
              bg: _c.accentLight,
            ),

            _platformCard(
              context,
              title: "Demokrito TMS",
              description:
                  "Task management mobile application for attendance, "
                  "proof uploads, departmental monitoring, and "
                  "business operations.",
              icon: Icons.task_alt_rounded,
              color: _c.green,
              bg: _c.greenLight,
            ),

            _platformCard(
              context,
              title: "Survey XML & Validation Tools",
              description:
                  "AI-powered market research tools for XML generation, "
                  "survey scripting, validation logic, and structured outputs.",
              icon: Icons.auto_awesome_rounded,
              color: _c.purple,
              bg: _c.purpleLight,
            ),

            _platformCard(
              context,
              title: "Future AI Projects",
              description:
                  "Additional AI-driven products for automation, "
                  "data processing, cleaning, insights, and analytics.",
              icon: Icons.psychology_rounded,
              color: _c.orange,
              bg: _c.orangeLight,
            ),

            _sectionTitle("User Accounts"),

            _section(
              "Account Responsibility",
              "Users must provide accurate account information and "
                  "are responsible for maintaining account confidentiality.",
            ),

            _sectionTitle("Acceptable Use"),

            _bulletCard(
              context,
              title: "User Responsibilities",
              icon: Icons.gavel_rounded,

              items: [
                "Comply with all applicable laws",
                "Avoid unlawful activities",
                "Avoid fraudulent usage",
                "Respect platform policies",
                "Use services responsibly",
              ],
            ),

            _sectionTitle("Content Submission"),

            _section(
              "User Content",
              "Users retain ownership of uploaded ads, media, survey "
                  "data, validation rules, and research inputs. "
                  "The Company only receives a limited license necessary "
                  "to provide services.",
            ),

            _commitmentCard(
              title: "AI Training Protection",
              description:
                  "Survey data, validation files, and research inputs "
                  "are never used to train AI models without consent.",
              color: _c.green,
              bg: _c.greenLight,
            ),

            _sectionTitle("Payments & Refunds"),

            _section(
              "Billing Terms",
              "Some services may require payment. Unless otherwise stated, "
                  "all payments are non-refundable and governed by "
                  "the applicable Refund Policy.",
            ),

            _sectionTitle("Termination"),

            _section(
              "Account Suspension",
              "The Company reserves the right to suspend or terminate "
                  "accounts that violate these Terms.",
            ),

            _sectionTitle("Limitation of Liability"),

            _section(
              "Liability Disclaimer",
              "The Company shall not be liable for indirect, incidental, "
                  "special, or consequential damages related to the use "
                  "of our Services.",
            ),

            _sectionTitle("Privacy & Data Use"),

            _platformCard(
              context,
              title: "Privacy Compliance",
              description:
                  "Each platform follows strict privacy and data "
                  "protection practices as outlined in the Privacy Policy.",
              icon: Icons.privacy_tip_rounded,
              color: _c.teal,
              bg: _c.tealLight,
            ),

            _sectionTitle("Children’s Policy"),

            _section(
              "Children Under 13",
              "Our services are not intended for children under "
                  "13 years of age.",
            ),

            _sectionTitle("Google Play Compliance"),

            _section(
              "Android Applications",
              "Users of Android-based applications must comply "
                  "with Google Play policies and Terms of Service.",
            ),

            _sectionTitle("Changes to Terms"),

            _section(
              "Updates",
              "The Company may update these Terms at any time. "
                  "Continued use constitutes acceptance of updated Terms.",
            ),

            _sectionTitle("Governing Law"),

            _section(
              "Jurisdiction",
              "These Terms are governed by the laws of India. "
                  "Disputes shall fall under the jurisdiction of "
                  "courts in Guntur, Andhra Pradesh.",
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
              Icons.gavel_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Terms & Conditions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Please review the rules, policies, and conditions "
            "for using our services.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
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
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),

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
            "Company Contact",
            style: TextStyle(
              color: _c.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "SRI SIVANANDA DEMOKRITO MARKET INSIGHTS "
            "SERVICES PRIVATE LIMITED",

            textAlign: TextAlign.center,

            style: TextStyle(color: _c.textSecondary, height: 1.5),
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
