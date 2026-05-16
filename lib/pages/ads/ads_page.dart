// import 'package:cms_app/utils/feature_access.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/ad_provider.dart';
// import 'ad_details_page.dart';
// import 'ad_create_page.dart';

// class AdsPage extends StatefulWidget {
//   const AdsPage({super.key});

//   @override
//   State<AdsPage> createState() => _AdsPageState();
// }

// class _AdsPageState extends State<AdsPage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadData();
//     });
//   }

//   void _loadData() {
//     context.read<AdProvider>().loadAds();
//   }

//   // 🎛️ MODAL FILTER UI
//   void openFilter() {
//     final adProvider = context.read<AdProvider>();

//     showModalBottomSheet(
//       context: context,
//       builder: (_) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     "Filters",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),

//                   /// STATUS DROPDOWN
//                   DropdownButtonFormField<String>(
//                     value: adProvider.statusFilter,
//                     decoration: const InputDecoration(
//                       labelText: "Status",
//                       border: OutlineInputBorder(),
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: "all", child: Text("All")),
//                       DropdownMenuItem(
//                         value: "pending",
//                         child: Text("Pending"),
//                       ),
//                       DropdownMenuItem(
//                         value: "processing",
//                         child: Text("Processing"),
//                       ),
//                       DropdownMenuItem(
//                         value: "completed",
//                         child: Text("Completed"),
//                       ),
//                     ],
//                     onChanged: (v) {
//                       setModalState(() {
//                         adProvider.setStatusFilter(v!);
//                       });
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   Row(
//                     children: [
//                       /// CLEAR BUTTON
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {
//                             adProvider.clearFilters();
//                             Navigator.pop(context);
//                           },
//                           child: const Text("Clear"),
//                         ),
//                       ),
//                       const SizedBox(width: 10),

//                       /// APPLY BUTTON
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // The provider already updates when onChanged fires,
//                             // so we just need to close the modal.
//                             Navigator.pop(context);
//                           },
//                           child: const Text("Apply"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final adProvider = context.watch<AdProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Ads"),
//         actions: [
//           IconButton(
//             tooltip: "Refresh",
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadData,
//           ),
//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: "Add Ad",

//             // onPressed: () {
//             //   Navigator.push(
//             //     context,
//             //     MaterialPageRoute(builder: (_) => const AddAdPage()),
//             //   );
//             // },
//             onPressed: () {
//               FeatureAccess.openStorageLimitedFeature(
//                 context: context,

//                 newFileSizeBytes: 0,

//                 page: const AddAdPage(),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // 🔍 SEARCH + FILTER TOGGLE
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search ad...",
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onChanged: (v) {
//                       Future.microtask(() {
//                         adProvider.setSearch(v);
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 IconButton(
//                   tooltip: "Filters",
//                   icon: const Icon(Icons.filter_list),
//                   onPressed: openFilter, // Trigger Bottom Sheet
//                 ),
//               ],
//             ),
//           ),

//           // 📺 ADS LIST
//           Expanded(
//             child: Builder(
//               builder: (_) {
//                 if (adProvider.loading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (adProvider.error != null) {
//                   return Center(child: Text(adProvider.error!));
//                 }

//                 if (adProvider.filteredAds.isEmpty) {
//                   return const Center(child: Text("No ads found"));
//                 }

//                 return RefreshIndicator(
//                   onRefresh: () async => _loadData(),
//                   child: ListView.builder(
//                     itemCount: adProvider.filteredAds.length,
//                     itemBuilder: (_, i) {
//                       final ad = adProvider.filteredAds[i];

//                       // Detect if the URL is a video or image
//                       final isVideo = _isVideo(ad.url ?? "");
//                       final icon = isVideo ? Icons.play_circle : Icons.image;

//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         child: ListTile(
//                           leading: Icon(icon),
//                           title: Text(
//                             ad.name,
//                             style: const TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                           subtitle: Text(ad.status),
//                           trailing: const Icon(Icons.chevron_right),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => AdDetailsPage(ad: ad),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // -----------------------------
//   // URL Type Detection
//   // -----------------------------
//   bool _isVideo(String url) {
//     try {
//       final path = Uri.parse(url).path.toLowerCase();
//       return path.endsWith('.mp4') ||
//           path.endsWith('.mov') ||
//           path.endsWith('.webm');
//     } catch (_) {
//       return false;
//     }
//   }

//   bool _isImage(String url) {
//     try {
//       final path = Uri.parse(url).path.toLowerCase();
//       return path.endsWith('.jpeg') ||
//           path.endsWith('.jpg') ||
//           path.endsWith('.png') ||
//           path.endsWith('.gif');
//     } catch (_) {
//       return false;
//     }
//   }
// }

import 'package:cms_app/utils/feature_access.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import 'ad_details_page.dart';
import 'ad_create_page.dart';
import 'package:cms_app/theme/app_colors.dart';

// ─── Colour palette ───────────────────────────────────────────────────────────
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

class AdsPage extends StatefulWidget {
  const AdsPage({super.key});

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<AdProvider>().loadAds();
  }

  // ─── Filter bottom sheet ───────────────────────────────────────────────────
  void openFilter() {
    final adProvider = context.read<AdProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: appColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appColors.accentLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: appColors.accent,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status label
                  Text(
                    'Status',
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status options as chips
                  Wrap(
                    spacing: 8,
                    children: ['all', 'pending', 'processing', 'completed'].map(
                      (s) {
                        final isSelected = adProvider.statusFilter == s;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              adProvider.setStatusFilter(s);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? appColors.accent
                                  : appColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? appColors.accent
                                    : appColors.border,
                              ),
                            ),
                            child: Text(
                              s[0].toUpperCase() + s.substring(1),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : appColors.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            adProvider.clearFilters();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: appColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: appColors.border),
                            ),
                            child: Center(
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: appColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: appColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── URL helpers ───────────────────────────────────────────────────────────
  bool _isVideo(String url) {
    try {
      final path = Uri.parse(url).path.toLowerCase();
      return path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.webm');
    } catch (_) {
      return false;
    }
  }

  bool _isImage(String url) {
    try {
      final path = Uri.parse(url).path.toLowerCase();
      return path.endsWith('.jpeg') ||
          path.endsWith('.jpg') ||
          path.endsWith('.png') ||
          path.endsWith('.gif');
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = context.watch<AdProvider>();

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

        titleSpacing: 16,

        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appColors.accent, const Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ads',
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                Text(
                  '${adProvider.filteredAds.length} ad${adProvider.filteredAds.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: appColors.textMuted,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: appColors.surfaceHigh,
                shape: BoxShape.circle,
                border: Border.all(color: appColors.border),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: appColors.textSecondary,
                size: 17,
              ),
            ),
            onPressed: _loadData,
          ),

          IconButton(
            tooltip: 'Add Ad',
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: appColors.accentLight,
                shape: BoxShape.circle,
                border: Border.all(color: appColors.accent.withOpacity(0.3)),
              ),
              child: Icon(Icons.add_rounded, color: appColors.accent, size: 18),
            ),
            onPressed: () {
              FeatureAccess.openStorageLimitedFeature(
                context: context,
                newFileSizeBytes: 0,
                page: const AddAdPage(),
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
      body: Column(
        children: [
          // ── Search + Filter ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: appColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search ad...',
                        hintStyle: TextStyle(
                          color: appColors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: appColors.textMuted,
                          size: 18,
                        ),
                        suffixIcon: adProvider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: appColors.textMuted,
                                  size: 16,
                                ),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  Future.microtask(
                                    () => adProvider.setSearch(''),
                                  );
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                      onChanged: (v) {
                        Future.microtask(() => adProvider.setSearch(v));
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter button
                GestureDetector(
                  onTap: openFilter,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: adProvider.statusFilter != 'all'
                          ? appColors.accentLight
                          : appColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: adProvider.statusFilter != 'all'
                            ? appColors.accent.withOpacity(0.4)
                            : appColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: adProvider.statusFilter != 'all'
                          ? appColors.accent
                          : appColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Ads list ──
          Expanded(
            child: Builder(
              builder: (_) {
                if (adProvider.loading) {
                  return Center(
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
                          'Loading ads…',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (adProvider.error != null) {
                  return Center(
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
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load ads',
                            style: TextStyle(
                              color: appColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            adProvider.error!,
                            style: TextStyle(
                              color: appColors.textSecondary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _loadData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: appColors.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Try Again',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (adProvider.filteredAds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: appColors.surfaceHigh,
                            shape: BoxShape.circle,
                            border: Border.all(color: appColors.border),
                          ),
                          child: Icon(
                            Icons.campaign_outlined,
                            color: appColors.textMuted,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ads found',
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: appColors.accent,
                  backgroundColor: appColors.surface,
                  onRefresh: () async => _loadData(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: adProvider.filteredAds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final ad = adProvider.filteredAds[i];
                      final isVideo = _isVideo(ad.url ?? '');
                      return _AdCard(ad: ad, isVideo: isVideo);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ad Card ──────────────────────────────────────────────────────────────────

class _AdCard extends StatelessWidget {
  final dynamic ad;
  final bool isVideo;
  const _AdCard({required this.ad, required this.isVideo});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed':
        return appColors.green;
      case 'processing':
        return appColors.yellow;
      case 'pending':
        return appColors.orange;
      default:
        return appColors.textMuted;
    }
  }

  Color _statusBg(String s) {
    switch (s.toLowerCase()) {
      case 'completed':
        return appColors.greenLight;
      case 'processing':
        return appColors.yellowLight;
      case 'pending':
        return appColors.orangeLight;
      default:
        return appColors.surfaceHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(ad.status ?? '');
    final sb = _statusBg(ad.status ?? '');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
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
            // Media type icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isVideo ? appColors.purpleLight : appColors.accentLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isVideo
                      ? appColors.purple.withOpacity(0.2)
                      : appColors.accent.withOpacity(0.2),
                ),
              ),
              child: Icon(
                isVideo ? Icons.play_circle_rounded : Icons.image_rounded,
                color: isVideo ? appColors.purple : appColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.name ?? '—',
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: sb,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sc.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: sc,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (ad.status ?? 'unknown').toUpperCase(),
                              style: TextStyle(
                                color: sc,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Media type label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: appColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: appColors.border),
                        ),
                        child: Text(
                          isVideo ? 'Video' : 'Image',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Arrow
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: appColors.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: appColors.border),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: appColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
