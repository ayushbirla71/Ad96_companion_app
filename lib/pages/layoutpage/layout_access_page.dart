import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      backgroundColor: const Color(0xffF8FAFC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Layouts',
          style: TextStyle(
            color: Color(0xff111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade500, Colors.deepPurple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Premium Layout Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Access advanced layout customization, live previews, section management and premium design controls directly from our website.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.92),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _openWebsite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.open_in_new_rounded),
                          SizedBox(width: 10),
                          Text(
                            'Visit Website',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // WEBSITE URL CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: Colors.indigo.shade600,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Official Website',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          websiteUrl,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FEATURES
            const Text(
              'Available Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xff111827),
              ),
            ),

            const SizedBox(height: 16),

            _featureTile(
              Icons.dashboard_customize_rounded,
              'Create Smart TV Layouts',
            ),

            _featureTile(Icons.slideshow_rounded, 'Schedule Ads & Campaigns'),

            _featureTile(Icons.live_tv_rounded, 'Live Content Streaming'),

            _featureTile(Icons.widgets_rounded, 'Dynamic Widgets Integration'),

            _featureTile(
              Icons.tv_rounded,
              'Android TV Digital Signage Support',
            ),

            _featureTile(Icons.cloud_sync_rounded, 'Real-Time Layout Updates'),

            _featureTile(
              Icons.view_carousel_rounded,
              'Carousel & Media Sections',
            ),

            _featureTile(
              Icons.analytics_rounded,
              'Playback Analytics & Reports',
            ),

            _featureTile(
              Icons.devices_other_rounded,
              'Multi-Device Screen Management',
            ),

            _featureTile(
              Icons.settings_suggest_rounded,
              'Advanced Screen Customization',
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.indigo.shade600),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
