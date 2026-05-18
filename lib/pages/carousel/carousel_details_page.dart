// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/carousel_provider.dart';
// import 'edit_carousel_page.dart';

// class CarouselDetailsPage extends StatelessWidget {
//   final String id;

//   const CarouselDetailsPage({super.key, required this.id});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<CarouselProvider>();

//     final carousel = provider.carousels.firstWhere((c) => c.carouselId == id);

//     int totalDuration = carousel.items.fold(0, (sum, e) => sum + e.duration);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Carousel Details"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => EditCarouselPage(id: id)),
//               );
//             },
//           ),
//         ],
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               carousel.name,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             Text("Status: ${carousel.status}"),
//             Text("Items: ${carousel.items.length}"),

//             Text("Duration: ${totalDuration ~/ 60}m ${totalDuration % 60}s"),

//             const SizedBox(height: 20),

//             const Divider(),

//             const Text(
//               "Carousel Items",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             Expanded(
//               child: ListView.builder(
//                 itemCount: carousel.items.length,
//                 itemBuilder: (_, i) {
//                   final item = carousel.items[i];

//                   return Card(
//                     child: ListTile(
//                       leading: Text("${i + 1}"),
//                       title: Text(item.name ?? "Ad"),
//                       subtitle: Text("Duration: ${item.duration}s"),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/carousel_provider.dart';
import '../../theme/app_colors.dart';
import 'edit_carousel_page.dart';

class CarouselDetailsPage extends StatelessWidget {
  final String id;

  const CarouselDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarouselProvider>();

    final carousel = provider.carousels.firstWhere((c) => c.carouselId == id);

    final totalDuration = carousel.items.fold(0, (sum, e) => sum + e.duration);

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
          "Carousel Details",
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        actions: [
          IconButton(
            tooltip: "Edit Carousel",
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: appColors.accentLight,
                shape: BoxShape.circle,
                border: Border.all(color: appColors.accent.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.edit_rounded,
                color: appColors.accent,
                size: 17,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditCarouselPage(id: id)),
              );
            },
          ),
          const SizedBox(width: 4),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appColors.orange, const Color(0xFFEA580C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.view_carousel_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          carousel.name,
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: carousel.status == 'active'
                                    ? appColors.greenLight
                                    : appColors.orangeLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                carousel.status.toUpperCase(),
                                style: TextStyle(
                                  color: carousel.status == 'active'
                                      ? appColors.green
                                      : appColors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
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

            const SizedBox(height: 16),

            // ── Stats ──
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.layers_rounded,
                    title: 'Items',
                    value: '${carousel.items.length}',
                    color: appColors.accent,
                    bg: appColors.accentLight,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    icon: Icons.timer_rounded,
                    title: 'Duration',
                    value: '${totalDuration ~/ 60}m ${totalDuration % 60}s',
                    color: appColors.orange,
                    bg: appColors.orangeLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Text(
              "Carousel Items",
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                itemCount: carousel.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = carousel.items[i];

                  return Container(
                    padding: const EdgeInsets.all(14),
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
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: appColors.orangeLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "${i + 1}",
                              style: TextStyle(
                                color: appColors.orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name ?? "Ad",
                                style: TextStyle(
                                  color: appColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Duration: ${item.duration}s",
                                style: TextStyle(
                                  color: appColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.chevron_right_rounded,
                          color: appColors.textMuted,
                          size: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(18),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: appColors.textMuted, fontSize: 11),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
