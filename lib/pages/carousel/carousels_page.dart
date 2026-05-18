// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../providers/carousel_provider.dart';
// import 'create_carousel_page.dart';
// import 'carousel_details_page.dart';

// class CarouselPage extends StatefulWidget {
//   const CarouselPage({super.key});

//   @override
//   State<CarouselPage> createState() => _CarouselPageState();
// }

// class _CarouselPageState extends State<CarouselPage> {
//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() {
//       context.read<CarouselProvider>().loadCarousels();
//     });
//   }

//   String formatDuration(int seconds) {
//     final m = seconds ~/ 60;
//     final s = seconds % 60;
//     return "${m}m ${s}s";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<CarouselProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Carousels"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const CreateCarouselPage()),
//               );
//             },
//           ),
//         ],
//       ),

//       body: Column(
//         children: [
//           /// SEARCH
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               decoration: const InputDecoration(
//                 hintText: "Search carousel...",
//                 prefixIcon: Icon(Icons.search),
//               ),
//               onChanged: provider.setSearch,
//             ),
//           ),

//           Expanded(
//             child: provider.loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: provider.filteredCarousels.length,
//                     itemBuilder: (_, i) {
//                       final c = provider.filteredCarousels[i];

//                       return Card(
//                         margin: const EdgeInsets.all(10),

//                         child: ListTile(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     CarouselDetailsPage(id: c.carouselId),
//                               ),
//                             );
//                           },

//                           title: Text(c.name),

//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text("Items: ${c.items.length}"),
//                               Text(
//                                 "Duration: ${formatDuration(c.totalDuration)}",
//                               ),
//                               Text("Status: ${c.status}"),
//                             ],
//                           ),

//                           trailing: PopupMenuButton(
//                             itemBuilder: (_) => [
//                               const PopupMenuItem(
//                                 value: "toggle",
//                                 child: Text("Toggle Status"),
//                               ),
//                               const PopupMenuItem(
//                                 value: "delete",
//                                 child: Text("Delete"),
//                               ),
//                             ],

//                             onSelected: (v) async {
//                               if (v == "toggle") {
//                                 await provider.toggleStatus(c);
//                               } else if (v == "delete") {
//                                 await provider.deleteCarousel(c.carouselId);
//                               }
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/carousel_provider.dart';
import '../../theme/app_colors.dart'; // adjust import path as needed
import 'create_carousel_page.dart';
import 'carousel_details_page.dart';

class CarouselPage extends StatefulWidget {
  const CarouselPage({super.key});

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CarouselProvider>().loadCarousels();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m}m ${s}s";
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return appColors.green;
      case 'inactive':
        return appColors.red;
      case 'draft':
        return appColors.orange;
      default:
        return appColors.accent;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return appColors.greenLight;
      case 'inactive':
        return appColors.redLight;
      case 'draft':
        return appColors.orangeLight;
      default:
        return appColors.accentLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarouselProvider>();

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
                Icons.view_carousel_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carousels',
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                Text(
                  '${provider.filteredCarousels.length} carousel${provider.filteredCarousels.length != 1 ? 's' : ''}',
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
            onPressed: () => provider.loadCarousels(),
          ),

          IconButton(
            tooltip: 'Add Carousel',
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCarouselPage()),
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
          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                style: TextStyle(color: appColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search carousel...',
                  hintStyle: TextStyle(
                    color: appColors.textMuted,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: appColors.textMuted,
                    size: 18,
                  ),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: appColors.textMuted,
                            size: 16,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                            Future.microtask(() => provider.setSearch(''));
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
                  setState(() => _search = v);
                  Future.microtask(() => provider.setSearch(v));
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── List ──
          Expanded(
            child: Builder(
              builder: (_) {
                if (provider.loading) {
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
                          'Loading carousels…',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredCarousels.isEmpty) {
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
                            Icons.view_carousel_outlined,
                            color: appColors.textMuted,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No carousels found',
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try adjusting your search',
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
                  onRefresh: () async => provider.loadCarousels(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: provider.filteredCarousels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final c = provider.filteredCarousels[i];
                      final statusColor = _statusColor(c.status);
                      final statusBg = _statusBgColor(c.status);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CarouselDetailsPage(id: c.carouselId),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(14),
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
                              /// ICON
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: appColors.accentLight,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  Icons.view_carousel_rounded,
                                  color: appColors.accent,
                                  size: 20,
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                        color: appColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 4),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.photo_library_rounded,
                                          size: 11,
                                          color: appColors.textMuted,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          "${c.items.length} items",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: appColors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                          Icons.timer_rounded,
                                          size: 11,
                                          color: appColors.textMuted,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          formatDuration(c.totalDuration),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: appColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    /// STATUS PILL
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            c.status.toUpperCase(),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 8.5,
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

                              /// POPUP MENU
                              PopupMenuButton(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: appColors.textMuted,
                                  size: 18,
                                ),
                                color: appColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: appColors.border),
                                ),
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: "toggle",
                                    height: 40,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.toggle_on_rounded,
                                          size: 16,
                                          color: appColors.accent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Toggle Status",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: appColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: "delete",
                                    height: 40,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_rounded,
                                          size: 16,
                                          color: appColors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: appColors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (v) async {
                                  if (v == "toggle") {
                                    await provider.toggleStatus(c);
                                  } else if (v == "delete") {
                                    await provider.deleteCarousel(c.carouselId);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
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
