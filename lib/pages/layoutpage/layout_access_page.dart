// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LayoutAccessPage extends StatelessWidget {
//   const LayoutAccessPage({super.key});

//   final String websiteUrl = 'https://cms.ad96.in/';

//   Future<void> _openWebsite() async {
//     final Uri url = Uri.parse(websiteUrl);

//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF8FAFC),

//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         centerTitle: true,
//         title: const Text(
//           'Layouts',
//           style: TextStyle(
//             color: Color(0xff111827),
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // TOP BANNER
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(28),
//                 gradient: LinearGradient(
//                   colors: [Colors.indigo.shade500, Colors.deepPurple.shade400],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),

//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: 64,
//                     width: 64,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(.15),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(
//                       Icons.dashboard_customize_rounded,
//                       color: Colors.white,
//                       size: 34,
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   const Text(
//                     'Premium Layout Management',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 26,
//                       fontWeight: FontWeight.w700,
//                       height: 1.2,
//                     ),
//                   ),

//                   const SizedBox(height: 14),

//                   Text(
//                     'Access advanced layout customization, live previews, section management and premium design controls directly from our website.',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(.92),
//                       fontSize: 15,
//                       height: 1.6,
//                     ),
//                   ),

//                   const SizedBox(height: 28),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: _openWebsite,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.indigo,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                       ),
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.open_in_new_rounded),
//                           SizedBox(width: 10),
//                           Text(
//                             'Visit Website',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // WEBSITE URL CARD
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(22),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.indigo.shade50,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Icon(
//                       Icons.language_rounded,
//                       color: Colors.indigo.shade600,
//                     ),
//                   ),

//                   const SizedBox(width: 14),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Official Website',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),

//                         const SizedBox(height: 4),

//                         Text(
//                           websiteUrl,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xff111827),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // FEATURES
//             const Text(
//               'Available Features',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xff111827),
//               ),
//             ),

//             const SizedBox(height: 16),

//             _featureTile(
//               Icons.dashboard_customize_rounded,
//               'Create Smart TV Layouts',
//             ),

//             _featureTile(Icons.slideshow_rounded, 'Schedule Ads & Campaigns'),

//             _featureTile(Icons.live_tv_rounded, 'Live Content Streaming'),

//             _featureTile(Icons.widgets_rounded, 'Dynamic Widgets Integration'),

//             _featureTile(
//               Icons.tv_rounded,
//               'Android TV Digital Signage Support',
//             ),

//             _featureTile(Icons.cloud_sync_rounded, 'Real-Time Layout Updates'),

//             _featureTile(
//               Icons.view_carousel_rounded,
//               'Carousel & Media Sections',
//             ),

//             _featureTile(
//               Icons.analytics_rounded,
//               'Playback Analytics & Reports',
//             ),

//             _featureTile(
//               Icons.devices_other_rounded,
//               'Multi-Device Screen Management',
//             ),

//             _featureTile(
//               Icons.settings_suggest_rounded,
//               'Advanced Screen Customization',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _featureTile(IconData icon, String title) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.indigo.shade50,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(icon, color: Colors.indigo.shade600),
//           ),

//           const SizedBox(width: 14),

//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xff111827),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cms_app/theme/app_colors.dart';

class LayoutAccessPage extends StatelessWidget {
  const LayoutAccessPage({super.key});

  final String websiteUrl = 'https://cms.ad96.in/';

  Future<void> _openWebsite() async {
    final Uri url = Uri.parse(websiteUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

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

        centerTitle: false,
        titleSpacing: 4,

        title: Text(
          'Layouts',
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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero banner ───────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appColors.accent, const Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: appColors.accent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -24,
                    top: -24,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -14,
                    bottom: -36,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.dashboard_customize_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Premium Layout\nManagement',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Access advanced layout customization, live previews, section management and premium design controls directly from our website.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openWebsite,
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 17,
                            ),
                            label: const Text(
                              'Visit Website',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: appColors.accent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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
            const SizedBox(height: 16),

            // ── Website URL card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(16),
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: appColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: appColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Official Website',
                          style: TextStyle(
                            fontSize: 11,
                            color: appColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          websiteUrl,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: appColors.accent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: appColors.textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Available Features label ──────────────────────────────
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: appColors.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: appColors.accent,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Available Features',
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Feature tiles ─────────────────────────────────────────
            _featureTile(
              Icons.dashboard_customize_rounded,
              'Create Smart TV Layouts',
              appColors.accent,
              appColors.accentLight,
            ),

            _featureTile(
              Icons.slideshow_rounded,
              'Schedule Ads & Campaigns',
              appColors.purple,
              appColors.purpleLight,
            ),

            _featureTile(
              Icons.live_tv_rounded,
              'Live Content Streaming',
              appColors.red,
              appColors.redLight,
            ),

            _featureTile(
              Icons.widgets_rounded,
              'Dynamic Widgets Integration',
              appColors.orange,
              appColors.orangeLight,
            ),

            _featureTile(
              Icons.tv_rounded,
              'Android TV Digital Signage Support',
              appColors.teal,
              appColors.tealLight,
            ),

            _featureTile(
              Icons.cloud_sync_rounded,
              'Real-Time Layout Updates',
              appColors.green,
              appColors.greenLight,
            ),

            _featureTile(
              Icons.view_carousel_rounded,
              'Carousel & Media Sections',
              appColors.purple,
              appColors.purpleLight,
            ),

            _featureTile(
              Icons.analytics_rounded,
              'Playback Analytics & Reports',
              appColors.accent,
              appColors.accentLight,
            ),

            _featureTile(
              Icons.devices_other_rounded,
              'Multi-Device Screen Management',
              appColors.teal,
              appColors.tealLight,
            ),

            _featureTile(
              Icons.settings_suggest_rounded,
              'Advanced Screen Customization',
              appColors.orange,
              appColors.orangeLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String title, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.border),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: appColors.textPrimary,
              ),
            ),
          ),
          Icon(Icons.check_circle_rounded, color: appColors.green, size: 18),
        ],
      ),
    );
  }
}
