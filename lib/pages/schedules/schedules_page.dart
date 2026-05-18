// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/schedule_provider.dart';
// import 'create_schedule_page.dart';
// import 'delete_schedule_page.dart';

// class SchedulesPage extends StatefulWidget {
//   const SchedulesPage({super.key});

//   @override
//   State<SchedulesPage> createState() => _SchedulesPageState();
// }

// class _SchedulesPageState extends State<SchedulesPage> {

//   String searchText = "";

//   String contentType = "all";

//   DateTime? fromDate;
//   DateTime? toDate;

//   @override
//   void initState() {
//     super.initState();

//     // 🔥 FIX: Replaced Future.microtask with addPostFrameCallback
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ScheduleProvider>().loadSchedules();
//     });
//   }

//   /// SAFE DATE PARSER
//   DateTime? parseDate(String? value) {
//     if (value == null || value.isEmpty) return null;

//     try {
//       return DateTime.parse(value);
//     } catch (_) {
//       return null;
//     }
//   }

//   /// SEARCH MATCH
//   bool matchSearch(String name, List groups) {

//     if (searchText.isEmpty) return true;

//     final s = searchText.toLowerCase();

//     if (name.toLowerCase().contains(s)) return true;

//     for (var g in groups) {
//       if (g.groupName.toLowerCase().contains(s)) {
//         return true;
//       }
//     }

//     return false;
//   }

//   /// DATE FILTER
//   bool matchDate(List groups) {

//     if (fromDate == null && toDate == null) return true;

//     for (var g in groups) {

//       final start = parseDate(g.fromDate);
//       final end = parseDate(g.toDate);

//       if (start == null || end == null) continue;

//       if (fromDate != null && start.isBefore(fromDate!)) {
//         return false;
//       }

//       if (toDate != null && end.isAfter(toDate!)) {
//         return false;
//       }
//     }

//     return true;
//   }

//   /// FILTER UI
//   void openFilter() {

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
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   DropdownButtonFormField<String>(
//                     value: contentType,
//                     decoration: const InputDecoration(
//                       labelText: "Content Type",
//                       border: OutlineInputBorder(),
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: "all", child: Text("All")),
//                       DropdownMenuItem(value: "ads", child: Text("Ads")),
//                       DropdownMenuItem(value: "live", child: Text("Live Content")),
//                       DropdownMenuItem(value: "carousel", child: Text("Carousels")),
//                     ],
//                     onChanged: (v) {
//                       setModalState(() {
//                         contentType = v!;
//                       });
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   ListTile(
//                     title: Text(
//                       "From: ${fromDate != null ? fromDate!.toLocal().toString().split(" ")[0] : "Select"}",
//                     ),
//                     trailing: const Icon(Icons.date_range),
//                     onTap: () async {

//                       final picked = await showDatePicker(
//                         context: context,
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime(2100),
//                         initialDate: DateTime.now(),
//                       );

//                       if (picked != null) {
//                         setModalState(() {
//                           fromDate = picked;
//                         });
//                       }
//                     },
//                   ),

//                   ListTile(
//                     title: Text(
//                       "To: ${toDate != null ? toDate!.toLocal().toString().split(" ")[0] : "Select"}",
//                     ),
//                     trailing: const Icon(Icons.date_range),
//                     onTap: () async {

//                       final picked = await showDatePicker(
//                         context: context,
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime(2100),
//                         initialDate: DateTime.now(),
//                       );

//                       if (picked != null) {
//                         setModalState(() {
//                           toDate = picked;
//                         });
//                       }
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   Row(
//                     children: [

//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {

//                             setState(() {
//                               contentType = "all";
//                               fromDate = null;
//                               toDate = null;
//                             });

//                             Navigator.pop(context);
//                           },
//                           child: const Text("Clear"),
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {});
//                             Navigator.pop(context);
//                           },
//                           child: const Text("Apply"),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   /// CARD UI
//   Widget buildCard({
//     required String title,
//     required int duration,
//     required List groups,
//     required dynamic data,
//   }) {

//     final totalGroups = groups.length;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

//       child: ExpansionTile(
//         title: Row(
//           children: [

//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),

//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade100,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 "$totalGroups groups",
//                 style: const TextStyle(fontSize: 12),
//               ),
//             ),

//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () {

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => DeleteSchedulePage(schedule: data),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),

//         subtitle: Text("Duration: ${duration}s"),

//         children: groups.map<Widget>((g) {

//           return ListTile(
//             title: Text(g.groupName),
//             subtitle: Text("${g.fromDate} → ${g.toDate}"),
//             trailing: Text(g.completedPercentage),
//           );

//         }).toList(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {

//     final provider = context.watch<ScheduleProvider>();

//     var ads = provider.ads
//         .where((a) => matchSearch(a.adName, a.groups))
//         .where((a) => matchDate(a.groups))
//         .toList();

//     var liveContents = provider.liveContents
//         .where((l) => matchSearch(l.contentName, l.groups))
//         .where((l) => matchDate(l.groups))
//         .toList();

//     var carousels = provider.carousels
//         .where((c) => matchSearch(c.carouselName, c.groups))
//         .where((c) => matchDate(c.groups))
//         .toList();

//     return Scaffold(

//       appBar: AppBar(
//         title: const Text("Schedules"),
//         actions: [

//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {

//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const CreateSchedulePage(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),

//       body: Column(
//         children: [

//           /// SEARCH + FILTER
//           Padding(
//             padding: const EdgeInsets.all(12),

//             child: Row(
//               children: [

//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search schedules...",
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),

//                     onChanged: (v) {
//                       // Safe to use microtask here if you want to debounce slightly,
//                       // or just setState directly.
//                       Future.microtask(() {
//                         setState(() {
//                           searchText = v;
//                         });
//                       });
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 10),

//                 IconButton(
//                   icon: const Icon(Icons.filter_list),
//                   onPressed: openFilter,
//                 ),
//               ],
//             ),
//           ),

//           Expanded(

//             child: provider.loading
//                 ? const Center(child: CircularProgressIndicator())

//                 : RefreshIndicator(
//                     onRefresh: provider.loadSchedules,

//                     child: ListView(
//                       children: [

//                         if ((contentType == "all" || contentType == "ads") &&
//                             ads.isNotEmpty)
//                           const Padding(
//                             padding: EdgeInsets.all(12),
//                             child: Text(
//                               "Ads",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),

//                         if (contentType == "all" || contentType == "ads")
//                           ...ads.map((ad) => buildCard(
//                                 title: ad.adName,
//                                 duration: ad.adDuration,
//                                 groups: ad.groups,
//                                 data: ad,
//                               )),

//                         if ((contentType == "all" || contentType == "live") &&
//                             liveContents.isNotEmpty)
//                           const Padding(
//                             padding: EdgeInsets.all(12),
//                             child: Text(
//                               "Live Content",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),

//                         if (contentType == "all" || contentType == "live")
//                           ...liveContents.map((live) => buildCard(
//                                 title: live.contentName,
//                                 duration: live.contentDuration,
//                                 groups: live.groups,
//                                 data: live,
//                               )),

//                         if ((contentType == "all" ||
//                                 contentType == "carousel") &&
//                             carousels.isNotEmpty)
//                           const Padding(
//                             padding: EdgeInsets.all(12),
//                             child: Text(
//                               "Carousels",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),

//                         if (contentType == "all" ||
//                             contentType == "carousel")
//                           ...carousels.map((carousel) => buildCard(
//                                 title: carousel.contentName,
//                                 duration: carousel.carouselDuration,
//                                 groups: carousel.groups,
//                                 data: carousel,
//                               )),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import 'create_schedule_page.dart';
import 'delete_schedule_page.dart';
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

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  String searchText = '';
  String contentType = 'all';
  DateTime? fromDate;
  DateTime? toDate;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadSchedules();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Logic (untouched) ────────────────────────────────────────────────────

  DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  bool matchSearch(String name, List groups) {
    if (searchText.isEmpty) return true;
    final s = searchText.toLowerCase();
    if (name.toLowerCase().contains(s)) return true;
    for (var g in groups) {
      if (g.groupName.toLowerCase().contains(s)) return true;
    }
    return false;
  }

  bool matchDate(List groups) {
    if (fromDate == null && toDate == null) return true;
    for (var g in groups) {
      final start = parseDate(g.fromDate);
      final end = parseDate(g.toDate);
      if (start == null || end == null) continue;
      if (fromDate != null && start.isBefore(fromDate!)) return false;
      if (toDate != null && end.isAfter(toDate!)) return false;
    }
    return true;
  }

  bool get _hasActiveFilters =>
      contentType != 'all' || fromDate != null || toDate != null;

  String _fmtDate(DateTime d) {
    const m = [
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
    return '${m[d.month]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  // ─── Filter bottom sheet ──────────────────────────────────────────────────

  void openFilter() {
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
              child: SingleChildScrollView(
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

                    // Content Type label
                    Text(
                      'Content Type',
                      style: TextStyle(
                        color: appColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Content type chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            {'value': 'all', 'label': 'All'},
                            {'value': 'ads', 'label': 'Ads'},
                            {'value': 'live', 'label': 'Live Content'},
                            {'value': 'carousel', 'label': 'Carousels'},
                            {'value': 'layout', 'label': 'Layouts'},
                          ].map((item) {
                            final isSelected = contentType == item['value'];
                            return GestureDetector(
                              onTap: () => setModalState(
                                () => contentType = item['value']!,
                              ),
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
                                  item['label']!,
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
                          }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Date range label
                    Text(
                      'Date Range',
                      style: TextStyle(
                        color: appColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // From date
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: fromDate ?? DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: appColors.accent,
                                onPrimary: Colors.white,
                                surface: appColors.surface,
                                onSurface: appColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setModalState(() => fromDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: fromDate != null
                              ? appColors.accentLight
                              : appColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: fromDate != null
                                ? appColors.accent.withOpacity(0.4)
                                : appColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 15,
                              color: fromDate != null
                                  ? appColors.accent
                                  : appColors.textMuted,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              fromDate != null
                                  ? 'From: ${_fmtDate(fromDate!)}'
                                  : 'From: Select date',
                              style: TextStyle(
                                color: fromDate != null
                                    ? appColors.accent
                                    : appColors.textMuted,
                                fontSize: 13,
                                fontWeight: fromDate != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: appColors.textMuted,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // To date
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: toDate ?? DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: appColors.accent,
                                onPrimary: Colors.white,
                                surface: appColors.surface,
                                onSurface: appColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setModalState(() => toDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: toDate != null
                              ? appColors.accentLight
                              : appColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: toDate != null
                                ? appColors.accent.withOpacity(0.4)
                                : appColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 15,
                              color: toDate != null
                                  ? appColors.accent
                                  : appColors.textMuted,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              toDate != null
                                  ? 'To: ${_fmtDate(toDate!)}'
                                  : 'To: Select date',
                              style: TextStyle(
                                color: toDate != null
                                    ? appColors.accent
                                    : appColors.textMuted,
                                fontSize: 13,
                                fontWeight: toDate != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: appColors.textMuted,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                contentType = 'all';
                                fromDate = null;
                                toDate = null;
                              });
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
                            onTap: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
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
              ),
            );
          },
        );
      },
    );
  }

  // ─── Schedule card (untouched logic) ─────────────────────────────────────

  Widget buildCard({
    required String title,
    required int duration,
    required List groups,
    required dynamic data,
    required Color typeColor,
    required Color typeBg,
    required IconData typeIcon,
  }) {
    final totalGroups = groups.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            childrenPadding: EdgeInsets.zero,
            collapsedBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: typeColor, size: 18),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.accentLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: appColors.accent.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '$totalGroups group${totalGroups != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: appColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeleteSchedulePage(schedule: data),
                      ),
                    );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: appColors.redLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: appColors.red.withOpacity(0.2)),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      color: appColors.red,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                'Duration: ${duration}s',
                style: TextStyle(color: appColors.textMuted, fontSize: 11),
              ),
            ),
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                decoration: BoxDecoration(
                  color: appColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appColors.borderLight),
                ),
                child: Column(
                  children: groups.asMap().entries.map<Widget>((entry) {
                    final i = entry.key;
                    final g = entry.value;
                    final isLast = i == groups.length - 1;

                    // Parse completion percentage
                    final pctStr = g.completedPercentage
                        .toString()
                        .replaceAll('%', '')
                        .trim();
                    final pct = (double.tryParse(pctStr) ?? 0).clamp(0, 100);
                    final pctColor = pct >= 80
                        ? appColors.green
                        : pct >= 40
                        ? appColors.yellow
                        : appColors.orange;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: appColors.accentLight,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(
                                  Icons.group_work_rounded,
                                  color: appColors.accent,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.groupName,
                                      style: TextStyle(
                                        color: appColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${g.fromDate} → ${g.toDate}',
                                      style: TextStyle(
                                        color: appColors.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: pctColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: pctColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  g.completedPercentage,
                                  style: TextStyle(
                                    color: pctColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: appColors.borderLight,
                            indent: 56,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section header ───────────────────────────────────────────────────────

  Widget _sectionHeader(String label, int count, Color color, Color bg) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    var ads = provider.ads
        .where((a) => matchSearch(a.adName, a.groups))
        .where((a) => matchDate(a.groups))
        .toList();

    var liveContents = provider.liveContents
        .where((l) => matchSearch(l.contentName, l.groups))
        .where((l) => matchDate(l.groups))
        .toList();

    var carousels = provider.carousels
        .where((c) => matchSearch(c.carouselName, c.groups))
        .where((c) => matchDate(c.groups))
        .toList();

    var layouts = provider.layouts
        .where((l) => matchSearch(l.contentName, l.groups))
        .where((l) => matchDate(l.groups))
        .toList();

    return Scaffold(
      backgroundColor: appColors.bg,
      // appBar: AppBar(
      //   backgroundColor: appColors.surface,
      //   surfaceTintColor: Colors.transparent,
      //   elevation: 0,
      //   titleSpacing: 16,
      //   title: Row(
      //     children: [
      //       Container(
      //         width: 34,
      //         height: 34,
      //         decoration: BoxDecoration(
      //           gradient: LinearGradient(
      //             colors: [appColors.yellow, const Color(0xFFB45309)],
      //             begin: Alignment.topLeft,
      //             end: Alignment.bottomRight,
      //           ),
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //         child: const Icon(
      //           Icons.event_note_rounded,
      //           color: Colors.white,
      //           size: 18,
      //         ),
      //       ),
      //       const SizedBox(width: 10),
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             'Schedules',
      //             style: TextStyle(
      //               color: appColors.textPrimary,
      //               fontSize: 15,
      //               fontWeight: FontWeight.w700,
      //               letterSpacing: -0.3,
      //               height: 1.1,
      //             ),
      //           ),
      //           Text(
      //             '${ads.length + liveContents.length + carousels.length} item${(ads.length + liveContents.length + carousels.length) != 1 ? 's' : ''}',
      //             style: TextStyle(
      //               color: appColors.textMuted,
      //               fontSize: 10,
      //               height: 1,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Container(
      //         width: 34,
      //         height: 34,
      //         decoration: BoxDecoration(
      //           color: appColors.accentLight,
      //           shape: BoxShape.circle,
      //           border: Border.all(color: appColors.accent.withOpacity(0.3)),
      //         ),
      //         child: Icon(Icons.add_rounded, color: appColors.accent, size: 18),
      //       ),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => const CreateSchedulePage()),
      //         );
      //       },
      //     ),
      //     const SizedBox(width: 4),
      //   ],
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     child: Container(height: 1, color: appColors.border),
      //   ),
      // ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,

        leadingWidth: 64,

        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: appColors.surfaceHigh,
                  shape: BoxShape.circle,
                  border: Border.all(color: appColors.border),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: appColors.textPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
        ),

        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appColors.yellow, const Color(0xFFB45309)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedules',
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                Text(
                  // '${ads.length + liveContents.length + carousels.length} item${(ads.length + liveContents.length + carousels.length) != 1 ? 's' : ''}',
                  '${ads.length + liveContents.length + carousels.length + layouts.length} item${(ads.length + liveContents.length + carousels.length + layouts.length) != 1 ? 's' : ''}',
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
                MaterialPageRoute(builder: (_) => const CreateSchedulePage()),
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
                        hintText: 'Search schedules...',
                        hintStyle: TextStyle(
                          color: appColors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: appColors.textMuted,
                          size: 18,
                        ),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: appColors.textMuted,
                                  size: 16,
                                ),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  Future.microtask(() {
                                    setState(() => searchText = '');
                                  });
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
                        setState(() {});
                        Future.microtask(() {
                          setState(() => searchText = v);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: openFilter,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hasActiveFilters
                          ? appColors.accentLight
                          : appColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasActiveFilters
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
                      color: _hasActiveFilters
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

          // ── List ──
          Expanded(
            child: provider.loading
                ? Center(
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
                          'Loading schedules…',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: appColors.accent,
                    backgroundColor: appColors.surface,
                    onRefresh: provider.loadSchedules,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: [
                        // ── Ads section ──
                        if ((contentType == 'all' || contentType == 'ads') &&
                            ads.isNotEmpty)
                          _sectionHeader(
                            'Ads',
                            ads.length,
                            appColors.accent,
                            appColors.accentLight,
                          ),
                        if (contentType == 'all' || contentType == 'ads')
                          ...ads.map(
                            (ad) => buildCard(
                              title: ad.adName,
                              duration: ad.adDuration,
                              groups: ad.groups,
                              data: ad,
                              typeColor: appColors.accent,
                              typeBg: appColors.accentLight,
                              typeIcon: Icons.campaign_rounded,
                            ),
                          ),

                        // ── Live Content section ──
                        if ((contentType == 'all' || contentType == 'live') &&
                            liveContents.isNotEmpty)
                          _sectionHeader(
                            'Live Content',
                            liveContents.length,
                            appColors.red,
                            appColors.redLight,
                          ),
                        if (contentType == 'all' || contentType == 'live')
                          ...liveContents.map(
                            (live) => buildCard(
                              title: live.contentName,
                              duration: live.contentDuration,
                              groups: live.groups,
                              data: live,
                              typeColor: appColors.red,
                              typeBg: appColors.redLight,
                              typeIcon: Icons.stream_rounded,
                            ),
                          ),

                        // ── Carousels section ──
                        if ((contentType == 'all' ||
                                contentType == 'carousel') &&
                            carousels.isNotEmpty)
                          _sectionHeader(
                            'Carousels',
                            carousels.length,
                            appColors.orange,
                            appColors.orangeLight,
                          ),
                        if (contentType == 'all' || contentType == 'carousel')
                          ...carousels.map(
                            (carousel) => buildCard(
                              title: carousel.contentName,
                              duration: carousel.carouselDuration,
                              groups: carousel.groups,
                              data: carousel,
                              typeColor: appColors.orange,
                              typeBg: appColors.orangeLight,
                              typeIcon: Icons.view_carousel_rounded,
                            ),
                          ),

                        // ── Layouts section ──
                        if ((contentType == 'all' || contentType == 'layout') &&
                            layouts.isNotEmpty)
                          _sectionHeader(
                            'Layouts',
                            layouts.length,
                            appColors.purple,
                            appColors.purpleLight,
                          ),

                        if (contentType == 'all' || contentType == 'layout')
                          ...layouts.map(
                            (layout) => buildCard(
                              title: layout.contentName,
                              duration: 0,
                              groups: layout.groups,
                              data: layout,
                              typeColor: appColors.purple,
                              typeBg: appColors.purpleLight,
                              typeIcon: Icons.dashboard_customize_rounded,
                            ),
                          ),

                        // ── Empty state ──
                        if (ads.isEmpty &&
                            liveContents.isEmpty &&
                            carousels.isEmpty &&
                            layouts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: appColors.surfaceHigh,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColors.border),
                                  ),
                                  child: Icon(
                                    Icons.event_busy_rounded,
                                    color: appColors.textMuted,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No schedules found',
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
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
