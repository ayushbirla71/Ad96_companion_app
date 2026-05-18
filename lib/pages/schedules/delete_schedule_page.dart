// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../models/schedule.dart';
// import '../../services/api_service.dart';

// class DeleteSchedulePage extends StatefulWidget {
//   final ScheduleAd schedule;

//   const DeleteSchedulePage({super.key, required this.schedule});

//   @override
//   State<DeleteSchedulePage> createState() => _DeleteSchedulePageState();
// }

// class _DeleteSchedulePageState extends State<DeleteSchedulePage> {
//   String? selectedGroupId;
//   DateTime? selectedFrom;
//   DateTime? selectedTo;
//   bool deleting = false;

//   String selectedTimeRange = "today";
//   final DateFormat backendDateFormat = DateFormat('yyyy-MM-dd');

//   @override
//   void initState() {
//     super.initState();

//     // Auto-select the first group if exists
//     if (widget.schedule.groups.isNotEmpty) {
//       final firstGroup = widget.schedule.groups.first;
//       selectedGroupId = firstGroup.groupId;
//       selectedFrom = _parseDate(firstGroup.fromDate);
//       selectedTo = _parseDate(firstGroup.toDate);
//       selectedTimeRange = "today";
//     }
//   }

//   DateTime _parseDate(String dateStr) {
//     final parts = dateStr.split("-");
//     return DateTime(
//       int.parse(parts[2]),
//       int.parse(parts[1]),
//       int.parse(parts[0]),
//     );
//   }

//   String _fmt(DateTime d) => backendDateFormat.format(d);

//   List<DropdownMenuItem<String>> getTimeRangeOptions() {
//     if (selectedGroupId == null) return [];

//     final group = widget.schedule.groups
//         .firstWhere((g) => g.groupId == selectedGroupId);

//     final startDate = _parseDate(group.fromDate);
//     final endDate = _parseDate(group.toDate);
//     final today = DateTime.now();
//     final totalDays = group.totalDays;
//     final remainingDays = (endDate.difference(today).inDays).clamp(0, totalDays);

//     final isActiveToday =
//         today.isAfter(startDate.subtract(const Duration(days: 1))) &&
//         today.isBefore(endDate.add(const Duration(days: 1)));

//     final options = <DropdownMenuItem<String>>[];

//     if (isActiveToday) {
//       options.add(const DropdownMenuItem(value: "today", child: Text("Today")));
//     }

//     if (totalDays > 1 && (isActiveToday || remainingDays > 0)) {
//       options.add(
//           const DropdownMenuItem(value: "week", child: Text("This week")));
//     }

//     if (totalDays > 7) {
//       options.add(
//           const DropdownMenuItem(value: "month", child: Text("This month")));
//     }

//     options.add(const DropdownMenuItem(value: "custom", child: Text("Custom")));

//     return options;
//   }

//   Future<void> pickDate({required bool isFrom}) async {
//     final initial = isFrom
//         ? selectedFrom ?? DateTime.now()
//         : selectedTo ?? DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2035),
//     );

//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           selectedFrom = picked;
//         } else {
//           selectedTo = picked;
//         }
//       });
//     }
//   }

//   Map<String, String> getDateRangeForTimeOption() {
//     final today = DateTime.now();
//     switch (selectedTimeRange) {
//       case "today":
//         return {"from": _fmt(today), "to": _fmt(today)};
//       case "week":
//         final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
//         final endOfWeek = startOfWeek.add(const Duration(days: 6));
//         return {"from": _fmt(startOfWeek), "to": _fmt(endOfWeek)};
//       case "month":
//         final startOfMonth = DateTime(today.year, today.month, 1);
//         final endOfMonth = DateTime(today.year, today.month + 1, 0);
//         return {"from": _fmt(startOfMonth), "to": _fmt(endOfMonth)};
//       case "custom":
//         return {"from": _fmt(selectedFrom!), "to": _fmt(selectedTo!)};
//       default:
//         return {"from": _fmt(today), "to": _fmt(today)};
//     }
//   }

//  Future<void> deleteSchedule() async {
//   if (selectedGroupId == null) return;

//   setState(() => deleting = true);

//   final dateRange = getDateRangeForTimeOption();

//   final payload = {
//     "adId": widget.schedule.adId,
//     "contentId": widget.schedule.contentId,

//     "groupId": selectedGroupId == "all" ? null : selectedGroupId,

//     "startDate": dateRange["from"],
//     "endDate": dateRange["to"],

//     "timeRangeType": selectedTimeRange,

//     "contentType": widget.schedule.contentType,
//   };

//   print(widget.schedule);

//   print("DELETE PAYLOAD >>> $payload");

//   try {
//     final response = await ApiService.post(
//       "/schedule/multiple-delete",
//       payload,
//     );

//     final result = jsonDecode(response.body);

//     print("DELETE RESPONSE >>> $result");

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Schedule deleted successfully")),
//       );

//       Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result["error"] ?? "Delete failed")),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: $e")),
//     );
//   }

//   setState(() => deleting = false);
// }

//   @override
//   Widget build(BuildContext context) {
//     final schedule = widget.schedule;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Delete Schedule")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Ad: ${schedule.adName}",
//               style: const TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             const Text("Select a group:", style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             ...schedule.groups.map(
//               (g) => Card(
//                 margin: const EdgeInsets.symmetric(vertical: 4),
//                 child: RadioListTile<String>(
//                   title: Text(g.groupName),
//                   subtitle: Text("${g.fromDate} → ${g.toDate}"),
//                   value: g.groupId,
//                   groupValue: selectedGroupId,
//                   onChanged: (val) {
//                     setState(() {
//                       selectedGroupId = val;
//                       final group = schedule.groups.firstWhere(
//                         (grp) => grp.groupId == val,
//                       );
//                       selectedFrom = _parseDate(group.fromDate);
//                       selectedTo = _parseDate(group.toDate);
//                       selectedTimeRange = "today";
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const Divider(),
//             if (selectedGroupId != null) ...[
//               const SizedBox(height: 12),
//               const Text("Select time range:", style: TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade400),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: DropdownButton<String>(
//                   value: selectedTimeRange,
//                   isExpanded: true,
//                   underline: const SizedBox(),
//                   items: getTimeRangeOptions(),
//                   onChanged: (val) {
//                     setState(() => selectedTimeRange = val!);
//                   },
//                   hint: const Text("Select Time Range"),
//                 ),
//               ),
//               if (selectedTimeRange == "custom") ...[
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => pickDate(isFrom: true),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade400),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(selectedFrom != null
//                                   ? DateFormat('yyyy-MM-dd').format(selectedFrom!)
//                                   : "Select From"),
//                               const Icon(Icons.calendar_today, size: 20),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => pickDate(isFrom: false),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade400),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(selectedTo != null
//                                   ? DateFormat('yyyy-MM-dd').format(selectedTo!)
//                                   : "Select To"),
//                               const Icon(Icons.calendar_today, size: 20),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: deleting ? null : deleteSchedule,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child: deleting
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                       )
//                     : const Text("Delete Schedule"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<NEW UPDATED UI>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import '../../services/api_service.dart';

// ─── Colour palette ───────────────────────────────────────────────────────────
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

class DeleteSchedulePage extends StatefulWidget {
  final ScheduleAd schedule;

  const DeleteSchedulePage({super.key, required this.schedule});

  @override
  State<DeleteSchedulePage> createState() => _DeleteSchedulePageState();
}

class _DeleteSchedulePageState extends State<DeleteSchedulePage> {
  String? selectedGroupId;
  DateTime? selectedFrom;
  DateTime? selectedTo;
  bool deleting = false;

  String selectedTimeRange = 'today';
  final DateFormat backendDateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    if (widget.schedule.groups.isNotEmpty) {
      final firstGroup = widget.schedule.groups.first;
      selectedGroupId = firstGroup.groupId;
      selectedFrom = _parseDate(firstGroup.fromDate);
      selectedTo = _parseDate(firstGroup.toDate);
      selectedTimeRange = 'today';
    }
  }

  // ─── Logic (untouched) ────────────────────────────────────────────────────

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  String _fmt(DateTime d) => backendDateFormat.format(d);

  List<DropdownMenuItem<String>> getTimeRangeOptions() {
    if (selectedGroupId == null) return [];

    final group = widget.schedule.groups.firstWhere(
      (g) => g.groupId == selectedGroupId,
    );

    final startDate = _parseDate(group.fromDate);
    final endDate = _parseDate(group.toDate);
    final today = DateTime.now();
    final totalDays = group.totalDays;
    final remainingDays = (endDate.difference(today).inDays).clamp(
      0,
      totalDays,
    );

    final isActiveToday =
        today.isAfter(startDate.subtract(const Duration(days: 1))) &&
        today.isBefore(endDate.add(const Duration(days: 1)));

    final options = <DropdownMenuItem<String>>[];

    if (isActiveToday) {
      options.add(const DropdownMenuItem(value: 'today', child: Text('Today')));
    }

    if (totalDays > 1 && (isActiveToday || remainingDays > 0)) {
      options.add(
        const DropdownMenuItem(value: 'week', child: Text('This week')),
      );
    }

    if (totalDays > 7) {
      options.add(
        const DropdownMenuItem(value: 'month', child: Text('This month')),
      );
    }

    options.add(const DropdownMenuItem(value: 'custom', child: Text('Custom')));

    return options;
  }

  Future<void> pickDate({required bool isFrom}) async {
    final initial = isFrom
        ? selectedFrom ?? DateTime.now()
        : selectedTo ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: _c.accent,
            onPrimary: Colors.white,
            surface: _c.surface,
            onSurface: _c.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          selectedFrom = picked;
        } else {
          selectedTo = picked;
        }
      });
    }
  }

  Map<String, String> getDateRangeForTimeOption() {
    final today = DateTime.now();
    switch (selectedTimeRange) {
      case 'today':
        return {'from': _fmt(today), 'to': _fmt(today)};
      case 'week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return {'from': _fmt(startOfWeek), 'to': _fmt(endOfWeek)};
      case 'month':
        final startOfMonth = DateTime(today.year, today.month, 1);
        final endOfMonth = DateTime(today.year, today.month + 1, 0);
        return {'from': _fmt(startOfMonth), 'to': _fmt(endOfMonth)};
      case 'custom':
        return {'from': _fmt(selectedFrom!), 'to': _fmt(selectedTo!)};
      default:
        return {'from': _fmt(today), 'to': _fmt(today)};
    }
  }

  Future<void> deleteSchedule() async {
    if (selectedGroupId == null) return;

    setState(() => deleting = true);

    final dateRange = getDateRangeForTimeOption();

    final payload = {
      'adId': widget.schedule.adId,
      'contentId': widget.schedule.contentId,
      'groupId': selectedGroupId == 'all' ? null : selectedGroupId,
      'startDate': dateRange['from'],
      'endDate': dateRange['to'],
      'timeRangeType': selectedTimeRange,
      'contentType': widget.schedule.contentType,
    };

    print(widget.schedule);
    print('DELETE PAYLOAD >>> $payload');

    try {
      final response = await ApiService.post(
        '/schedule/multiple-delete',
        payload,
      );

      final result = jsonDecode(response.body);
      print('DELETE RESPONSE >>> $result');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Schedule deleted successfully'),
            backgroundColor: _c.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Delete failed'),
            backgroundColor: _c.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: _c.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    setState(() => deleting = false);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final schedule = widget.schedule;

    return Scaffold(
      backgroundColor: _c.bg,
      appBar: AppBar(
        backgroundColor: _c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _c.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: _c.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _c.textSecondary,
              size: 15,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delete Schedule',
          style: TextStyle(
            color: _c.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _c.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Schedule info card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _c.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _c.redLight),
                boxShadow: [
                  BoxShadow(
                    color: _c.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _c.redLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_rounded, color: _c.red, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.adName,
                          style: TextStyle(
                            color: _c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You are about to delete this schedule',
                          style: TextStyle(color: _c.red, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Select group ──
            _sectionLabel('Select a Group'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: _c.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _c.border),
                boxShadow: [
                  BoxShadow(
                    color: _c.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: schedule.groups.asMap().entries.map((entry) {
                  final i = entry.key;
                  final g = entry.value;
                  final isLast = i == schedule.groups.length - 1;
                  final isSelected = selectedGroupId == g.groupId;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedGroupId = g.groupId;
                            final group = schedule.groups.firstWhere(
                              (grp) => grp.groupId == g.groupId,
                            );
                            selectedFrom = _parseDate(group.fromDate);
                            selectedTo = _parseDate(group.toDate);
                            selectedTimeRange = 'today';
                          });
                        },
                        borderRadius: BorderRadius.vertical(
                          top: i == 0 ? const Radius.circular(16) : Radius.zero,
                          bottom: isLast
                              ? const Radius.circular(16)
                              : Radius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Radio indicator
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? _c.accent : _c.border,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? _c.accent
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Group info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.groupName,
                                      style: TextStyle(
                                        color: _c.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.date_range_rounded,
                                          size: 11,
                                          color: _c.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${g.fromDate} → ${g.toDate}',
                                          style: TextStyle(
                                            color: _c.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _c.accentLight,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _c.accent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Selected',
                                    style: TextStyle(
                                      color: _c.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: _c.borderLight,
                          indent: 46,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),

            // ── Time range ──
            if (selectedGroupId != null) ...[
              const SizedBox(height: 24),
              _sectionLabel('Select Time Range'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _c.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _c.border),
                  boxShadow: [
                    BoxShadow(
                      color: _c.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedTimeRange,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: _c.surface,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _c.textMuted,
                  ),
                  style: TextStyle(
                    color: _c.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  items: getTimeRangeOptions(),
                  onChanged: (val) {
                    setState(() => selectedTimeRange = val!);
                  },
                  hint: Text(
                    'Select Time Range',
                    style: TextStyle(color: _c.textMuted),
                  ),
                ),
              ),

              // ── Custom date pickers ──
              if (selectedTimeRange == 'custom') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // From date
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickDate(isFrom: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selectedFrom != null
                                ? _c.accentLight
                                : _c.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedFrom != null
                                  ? _c.accent.withOpacity(0.4)
                                  : _c.border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _c.shadow,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: selectedFrom != null
                                    ? _c.accent
                                    : _c.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedFrom != null
                                      ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(selectedFrom!)
                                      : 'From date',
                                  style: TextStyle(
                                    color: selectedFrom != null
                                        ? _c.accent
                                        : _c.textMuted,
                                    fontSize: 12,
                                    fontWeight: selectedFrom != null
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // To date
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickDate(isFrom: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selectedTo != null
                                ? _c.accentLight
                                : _c.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedTo != null
                                  ? _c.accent.withOpacity(0.4)
                                  : _c.border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _c.shadow,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: selectedTo != null
                                    ? _c.accent
                                    : _c.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedTo != null
                                      ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(selectedTo!)
                                      : 'To date',
                                  style: TextStyle(
                                    color: selectedTo != null
                                        ? _c.accent
                                        : _c.textMuted,
                                    fontSize: 12,
                                    fontWeight: selectedTo != null
                                        ? FontWeight.w600
                                        : FontWeight.w400,
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
              ],
            ],

            const SizedBox(height: 32),

            // ── Delete button ──
            GestureDetector(
              onTap: deleting ? null : deleteSchedule,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: deleting ? _c.red.withOpacity(0.6) : _c.red,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: deleting
                      ? []
                      : [
                          BoxShadow(
                            color: _c.red.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Center(
                  child: deleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete Schedule',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section label ────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: _c.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
  );
}
