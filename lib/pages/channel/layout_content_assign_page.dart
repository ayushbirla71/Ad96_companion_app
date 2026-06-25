import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_dialogs.dart';

// ─────────────────────────────────────────────
// Models / helpers
// ─────────────────────────────────────────────

String _generateId() =>
    DateTime.now().millisecondsSinceEpoch.toString() +
    (1000 + (9000 * (DateTime.now().microsecond / 1000000)).round()).toString();

String _formatDuration(int seconds) {
  if (seconds <= 0) return '0s';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (m == 0) return '${s}s';
  if (s == 0) return '${m}m';
  return '${m}m ${s}s';
}

bool _isVideoFile(String url) {
  final clean = url.split('?').first.toLowerCase();
  return clean.endsWith('.mp4') ||
      clean.endsWith('.webm') ||
      clean.endsWith('.ogg') ||
      clean.endsWith('.mov');
}

/// Static date / time helpers (no dialog needed)
Map<String, String> _getStaticDateRange() {
  final now = DateTime.now();
  final start = now.toUtc().toIso8601String();
  final end = DateTime(
    now.year,
    now.month,
    now.day,
    23,
    59,
    59,
  ).toUtc().toIso8601String();
  return {'startDate': start, 'endDate': end};
}

/// Default time slots: now → 23:59
List<Map<String, String>> _defaultTimeSlots() {
  final now = TimeOfDay.now();
  final startH = now.hour.toString().padLeft(2, '0');
  final startM = now.minute.toString().padLeft(2, '0');
  return [
    {'start': '$startH:$startM', 'end': '23:59'},
  ];
}

// ─────────────────────────────────────────────
// Main Page
// ─────────────────────────────────────────────

class LayoutContentAssignPage extends StatefulWidget {
  final Map<String, dynamic> layout;
  final String contentId;

  const LayoutContentAssignPage({
    super.key,
    required this.layout,
    required this.contentId,
  });

  @override
  State<LayoutContentAssignPage> createState() =>
      _LayoutContentAssignPageState();
}

class _LayoutContentAssignPageState extends State<LayoutContentAssignPage> {
  late final AppColors appColors;

  // zone_id → list of assigned content items
  final Map<String, List<Map<String, dynamic>>> _zoneContents = {};
  // zone_id → muted
  final Map<String, bool> _zoneMuteSettings = {};

  // static time data
  final List<Map<String, String>> _timeSlots = _defaultTimeSlots();
  final Map<String, String> _dateRange = _getStaticDateRange();

  @override
  void initState() {
    super.initState();
    appColors = AppColors();
    _initZones();
  }

  void _initZones() {
    final zones = widget.layout['zones'] as List? ?? [];
    for (final z in zones) {
      final id = z['zone_id'] as String;
      _zoneContents[id] = [];
      _zoneMuteSettings[id] = z['is_muted'] ?? false;
    }
  }

  List<Map<String, dynamic>> get _zones =>
      List<Map<String, dynamic>>.from(widget.layout['zones'] ?? []);

  bool _zoneHasContent(String zoneId) =>
      (_zoneContents[zoneId]?.isNotEmpty) ?? false;

  void _toggleMute(String zoneId) {
    setState(() {
      final currently = _zoneMuteSettings[zoneId] ?? false;
      if (currently) {
        // unmute this, mute all others
        for (final k in _zoneMuteSettings.keys) {
          _zoneMuteSettings[k] = k != zoneId;
        }
      } else {
        _zoneMuteSettings[zoneId] = true;
      }
    });
  }

  // void _openZoneDialog(Map<String, dynamic> zone) async {
  //   await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => _ZoneAssignSheet(
  //       zone: zone,
  //       layout: widget.layout,
  //       timeSlots: _timeSlots,
  //       assignedItems: List.from(_zoneContents[zone['zone_id']] ?? []),
  //       onSave: (items) {
  //         setState(() {
  //           _zoneContents[zone['zone_id']] = items;
  //         });
  //       },
  //     ),
  //   );
  // }

  void _openZoneDialog(Map<String, dynamic> zone) async {
    // Auto assigned zone
    if (zone["content_type_allowed"] == "video_input_media") {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("This zone automatically uses selected live content"),
      //   ),
      // );
      AppDialogs.showValidationError(
        context,
        appColors,
        "This zone automatically uses selected live content",
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ZoneAssignSheet(
        zone: zone,
        layout: widget.layout,
        timeSlots: _timeSlots,
        assignedItems: List.from(_zoneContents[zone['zone_id']] ?? []),
        onSave: (items) {
          setState(() {
            _zoneContents[zone['zone_id']] = items;
          });
        },
      ),
    );
  }

  // bool get _allZonesAssigned {
  //   for (final z in _zones) {
  //     if (!_zoneHasContent(z['zone_id'])) return false;
  //   }
  //   return true;
  // }

  bool get _allZonesAssigned {
    for (final z in _zones) {
      if (z["content_type_allowed"] == "video_input_media") {
        continue;
      }

      if (!_zoneHasContent(z['zone_id'])) {
        return false;
      }
    }

    return true;
  }

  void _onSchedule() {
    final zoneContents = Map<String, List<Map<String, dynamic>>>.from(
      _zoneContents,
    );

    // Auto assign live content to video_input_media zones
    for (final zone in _zones) {
      if (zone["content_type_allowed"] == "video_input_media") {
        final zoneId = zone["zone_id"];

        zoneContents[zoneId] = [
          {
            "id": "live-${DateTime.now().millisecondsSinceEpoch}",
            "content_id": widget.contentId,
            "content_type": "live_content",
            "content_type_allowed": "video_input_media",
            "name": widget.layout['name'],
            "display_order": 1,
            "duration": 0,
            "time_slots": _timeSlots,
            "start_time": _dateRange['startDate'],
            "end_time": _dateRange['endDate'],
          },
        ];
      }
    }

    // Validate only non-video_input_media zones
    final unassigned = _zones
        .where(
          (z) =>
              z["content_type_allowed"] != "video_input_media" &&
              ((zoneContents[z["zone_id"]] ?? []).isEmpty),
        )
        .map((z) => z["name"])
        .toList();

    if (unassigned.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please assign content to: ${unassigned.join(', ')}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final payload = {
      'zone_mute_settings': _zoneMuteSettings,
      'schedule_id': 'schedule-${DateTime.now().millisecondsSinceEpoch}',
      'content_id': widget.layout['layout_id'],
      'name': widget.layout['name'],
      'schedule_date_type': 'today',
      'start_time': _dateRange['startDate'],
      'end_time': _dateRange['endDate'],
      'time_slots': _timeSlots,
      'zone_contents': zoneContents.entries.map((e) {
        return {
          'zone_id': e.key,
          'content_type_allowed': e.value.first['content_type_allowed'],

          'content_items': e.value.map((item) {
            return {
              ...item,
              'start_time': _dateRange['startDate'],
              'end_time': _dateRange['endDate'],
            };
          }).toList(),
        };
      }).toList(),
      'status': 'scheduled',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    print("Schedule Payload =>");
    print(jsonEncode(payload));

    Navigator.pop(context, payload);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = widget.layout['orientation'] == 'landscape';

    return Scaffold(
      backgroundColor: appColors.bg,
      appBar: AppBar(
        backgroundColor: appColors.surface,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: appColors.border),
              color: appColors.surface,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.layout['name'] ?? 'Layout',
              style: TextStyle(
                color: appColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              'Tap zones to assign content',
              style: TextStyle(color: appColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time slot badge
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ..._timeSlots.map(
                        (s) => _badge(
                          icon: Icons.access_time_rounded,
                          label: '${s['start']} – ${s['end']}',
                          color: appColors.accent,
                        ),
                      ),
                      _badge(
                        icon: Icons.calendar_today_rounded,
                        label: 'Today',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Layout Preview
                  _sectionLabel('Layout Preview'),
                  const SizedBox(height: 10),
                  _LayoutPreviewWidget(
                    layout: widget.layout,
                    zoneContents: _zoneContents,
                    onZoneTap: _openZoneDialog,
                  ),
                  const SizedBox(height: 24),

                  // Zone Assignments
                  _sectionLabel('Zone Assignments'),
                  const SizedBox(height: 10),
                  ..._zones.map(
                    (zone) => _ZoneAssignmentRow(
                      zone: zone,
                      items: _zoneContents[zone['zone_id']] ?? [],
                      isMuted: _zoneMuteSettings[zone['zone_id']] ?? false,
                      onMuteTap: () => _toggleMute(zone['zone_id']),
                      onAssignTap: () => _openZoneDialog(zone),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom CTA
          _BottomBar(
            enabled: _allZonesAssigned,
            onSchedule: _onSchedule,
            appColors: appColors,
          ),
        ],
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: appColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 15,
    ),
  );
}

// ─────────────────────────────────────────────
// Layout Preview Widget
// ─────────────────────────────────────────────

class _LayoutPreviewWidget extends StatelessWidget {
  final Map<String, dynamic> layout;
  final Map<String, List<Map<String, dynamic>>> zoneContents;
  final void Function(Map<String, dynamic>) onZoneTap;

  const _LayoutPreviewWidget({
    required this.layout,
    required this.zoneContents,
    required this.onZoneTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = layout['orientation'] == 'landscape';
    final double w = isLandscape ? double.infinity : 200;
    final double h = isLandscape ? 200 : 340;
    final bgColor = _parseColor(
      layout['background_color'] ?? '#1a1a2e',
      Colors.black,
    );
    final zones = List<Map<String, dynamic>>.from(layout['zones'] ?? []);

    return Center(
      child: Container(
        width: isLandscape ? double.infinity : w,
        height: h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: zones.map((zone) {
                final hasContent =
                    (zoneContents[zone['zone_id']]?.isNotEmpty) ?? false;
                final color = _parseColor(
                  zone['color'] ?? '#3b82f6',
                  Colors.blue,
                );
                final x = (zone['x'] as num).toDouble() / 100;
                final y = (zone['y'] as num).toDouble() / 100;
                final zw = (zone['width'] as num).toDouble() / 100;
                final zh = (zone['height'] as num).toDouble() / 100;
                final br = (zone['border_radius'] as num?)?.toDouble() ?? 4;
                final type = zone['content_type_allowed'] ?? 'media';

                return Positioned(
                  left: x * constraints.maxWidth,
                  top: y * constraints.maxHeight,
                  width: zw * constraints.maxWidth,
                  height: zh * constraints.maxHeight,
                  child: GestureDetector(
                    onTap: () => onZoneTap(zone),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(br),
                        border: hasContent
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            zone['name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            type == 'media'
                                ? 'Media Zone'
                                : type == 'video_input_media'
                                ? 'Media + Video'
                                : 'Widget Zone',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 7,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Text(
                          //   hasContent ? 'Assigned ✓' : 'Click to assign',
                          //   style: const TextStyle(
                          //     color: Colors.white60,
                          //     fontSize: 7,
                          //   ),
                          //   textAlign: TextAlign.center,
                          // ),
                          Text(
                            type == 'video_input_media'
                                ? 'Live Auto Assigned ✓'
                                : hasContent
                                ? 'Assigned ✓'
                                : 'Click to assign',
                            style: TextStyle(
                              color: type == 'video_input_media'
                                  ? Colors.greenAccent
                                  : Colors.white60,
                              fontSize: 7,
                              fontWeight: type == 'video_input_media'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

Color _parseColor(dynamic colorValue, Color fallback) {
  if (colorValue == null) return fallback;

  final color = colorValue.toString().trim();

  try {
    // HEX
    if (color.startsWith('#')) {
      String hex = color.replaceFirst('#', '');

      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      return Color(int.parse(hex, radix: 16));
    }

    // HSL
    if (color.startsWith('hsl')) {
      final match = RegExp(
        r'hsl\(([\d.]+),\s*([\d.]+)%?,\s*([\d.]+)%?\)',
      ).firstMatch(color);

      if (match != null) {
        final h = double.parse(match.group(1)!);
        final s = double.parse(match.group(2)!) / 100;
        final l = double.parse(match.group(3)!) / 100;

        return HSLColor.fromAHSL(1.0, h, s, l).toColor();
      }
    }

    // RGB support
    if (color.startsWith('rgb')) {
      final match = RegExp(r'rgb\((\d+),\s*(\d+),\s*(\d+)\)').firstMatch(color);

      if (match != null) {
        return Color.fromARGB(
          255,
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
        );
      }
    }
  } catch (e) {
    debugPrint('Color parse error: $e');
  }

  return fallback;
}

// ─────────────────────────────────────────────
// Zone Assignment Row
// ─────────────────────────────────────────────

class _ZoneAssignmentRow extends StatelessWidget {
  final Map<String, dynamic> zone;
  final List<Map<String, dynamic>> items;
  final bool isMuted;
  final VoidCallback onMuteTap;
  final VoidCallback onAssignTap;

  const _ZoneAssignmentRow({
    required this.zone,
    required this.items,
    required this.isMuted,
    required this.onMuteTap,
    required this.onAssignTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = zone['content_type_allowed'] ?? 'media';
    final isMedia = type == 'media' || type == 'video_input_media';
    final zoneColor = _parseColor(zone['color'] ?? '#3b82f6', Colors.blue);
    final hasContent = items.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: zoneColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row(
                    //   children: [
                    //     Text(
                    //       zone['name'] ?? '',
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.w600,
                    //         color: appColors.textPrimary,
                    //         fontSize: 14,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 8),
                    //     _TypeBadge(isMedia: isMedia, type: type),
                    //     if (hasContent) ...[
                    //       const SizedBox(width: 6),
                    //       _GreenBadge(
                    //         label: isMedia
                    //             ? '${items.length} items'
                    //             : '${items.length} widget',
                    //       ),
                    //     ],
                    //   ],
                    // ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          zone['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: appColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),

                        _TypeBadge(isMedia: isMedia, type: type),

                        if (hasContent)
                          _GreenBadge(
                            label: isMedia
                                ? '${items.length} items'
                                : '${items.length} widget',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Mute toggle
              GestureDetector(
                onTap: onMuteTap,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isMuted
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    size: 16,
                    color: isMuted ? Colors.red : Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Assign / Edit
              GestureDetector(
                // onTap: onAssignTap,
                onTap: type == 'video_input_media' ? null : onAssignTap,
                child: Container(
                  width: 95,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: appColors.border),
                    borderRadius: BorderRadius.circular(10),
                    color: type == 'video_input_media'
                        ? Colors.green.withOpacity(.08)
                        : appColors.surface,
                  ),

                  child: Text(
                    type == 'video_input_media'
                        ? 'Assigned'
                        : hasContent
                        ? 'Edit'
                        : 'Assign',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: type == 'video_input_media'
                          ? Colors.green
                          : appColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isMedia;
  final String type;

  const _TypeBadge({required this.isMedia, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isMedia
            ? Colors.blue.withOpacity(0.12)
            : Colors.purple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMedia ? Icons.play_circle_outline_rounded : Icons.widgets_rounded,
            size: 11,
            color: isMedia ? Colors.blue : Colors.purple,
          ),
          const SizedBox(width: 4),
          Text(
            isMedia
                ? type == 'video_input_media'
                      ? 'Media+Video'
                      : 'Media'
                : 'Widget',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isMedia ? Colors.blue : Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenBadge extends StatelessWidget {
  final String label;

  const _GreenBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 11,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom Bar
// ─────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onSchedule;
  final AppColors appColors;

  const _BottomBar({
    required this.enabled,
    required this.onSchedule,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: appColors.surface,
        border: Border(top: BorderSide(color: appColors.border)),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: enabled ? onSchedule : null,
        icon: const Icon(Icons.calendar_month_rounded, size: 18),
        label: const Text('Schedule Layout'),
        style: FilledButton.styleFrom(
          backgroundColor: appColors.accent,
          disabledBackgroundColor: appColors.accent.withOpacity(0.4),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Zone Assign Sheet
// ─────────────────────────────────────────────

class _ZoneAssignSheet extends StatefulWidget {
  final Map<String, dynamic> zone;
  final Map<String, dynamic> layout;
  final List<Map<String, String>> timeSlots;
  final List<Map<String, dynamic>> assignedItems;
  final void Function(List<Map<String, dynamic>>) onSave;

  const _ZoneAssignSheet({
    required this.zone,
    required this.layout,
    required this.timeSlots,
    required this.assignedItems,
    required this.onSave,
  });

  @override
  State<_ZoneAssignSheet> createState() => _ZoneAssignSheetState();
}

class _ZoneAssignSheetState extends State<_ZoneAssignSheet> {
  late final AppColors appColors;
  late List<Map<String, dynamic>> _assigned;

  final String _selectedContentType = 'ad';
  String _contentType = 'ad'; // 'ad' | 'carousel' | 'live_content'

  List<dynamic> _ads = [];
  List<dynamic> _carousels = [];
  List<dynamic> _liveContent = [];
  List<dynamic> _widgets = [];

  bool _loading = false;
  String _search = '';
  int _page = 1;
  final int _perPage = 8;

  List<dynamic> _logoAssets = [];
  bool _uploadingLogo = false;

  Future<void> _fetchLogoAssets() async {
    try {
      final res = await ApiService.get('/assets');
      final data = jsonDecode(res.body);

      print("data logo >>>>>> $data");

      final assets = data['data'] as List? ?? [];

      setState(() {
        _logoAssets = assets
            .where((item) => item['asset_type'] == 'logo')
            .toList();
      });

      print("Logo Assets => $_logoAssets");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _uploadLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result == null) return;

      final file = result.files.first;
      debugPrint("Selected file: ${file.name}");
      debugPrint("Path: ${file.path}");
      debugPrint("Size: ${file.size}");

      setState(() {
        _uploadingLogo = true;
      });

      final ext = file.extension ?? "png";

      final generateRes = await ApiService.post("/asset/generate-upload-url", {
        "fileName": "logo-${DateTime.now().millisecondsSinceEpoch}.$ext",
        "fileType": "image/${file.extension ?? 'png'}",
      });

      debugPrint("Generate URL Status: ${generateRes.statusCode}");
      debugPrint("Generate URL Body: ${generateRes.body}");

      final uploadData = jsonDecode(generateRes.body);

      final uploadUrl = uploadData["data"]["uploadUrl"] as String;
      final key = uploadData["data"]["key"] as String;

      debugPrint("Upload URL: $uploadUrl");
      debugPrint("Key: $key");

      final bytes = await File(file.path!).readAsBytes();
      debugPrint("Uploading to S3...");

      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {"Content-Type": "image/${file.extension ?? 'png'}"},
        body: bytes,
      );

      debugPrint("S3 Status: ${response.statusCode}");
      debugPrint("S3 Response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Upload failed");
      }

      final confirmRes = await ApiService.post("/asset/confirm-upload", {
        "key": key,
        "fileName": file.name,
        "fileType": "image/${file.extension ?? 'png'}",
        "fileSize": file.size,
        "assetType": "logo",
      });

      debugPrint("Confirm Status: ${confirmRes.statusCode}");
      debugPrint("Confirm Body: ${confirmRes.body}");

      await _fetchLogoAssets();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logo uploaded successfully")),
      );
    } catch (e, s) {
      debugPrint("UPLOAD ERROR: $e");
      debugPrint("$s");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _uploadingLogo = false;
      });
    }
  }

  bool _validateWidgetRequiredFields() {
    if (_isMedia) return true;

    if (_assigned.isEmpty) {
      AppDialogs.showValidationError(
        context,
        appColors,
        'Please select a widget',
      );
      return false;
    }

    final widgetItem = _assigned.first;

    final widgetDef = _widgets.firstWhere(
      (w) => w['widget_definition_id'] == widgetItem['content_id'],
      orElse: () => null,
    );

    if (widgetDef == null) return true;

    final requiredFields = List<String>.from(
      widgetDef['config_schema']?['required'] ?? [],
    );

    final config = Map<String, dynamic>.from(widgetItem['widget_config'] ?? {});

    final missingFields = <String>[];

    for (final field in requiredFields) {
      final value = config[field];

      if (value == null || value.toString().trim().isEmpty) {
        missingFields.add(field);
      }
    }

    if (missingFields.isNotEmpty) {
      AppDialogs.showValidationError(
        context,
        appColors,
        'Please fill required fields:\n\n${missingFields.join('\n')}',
      );
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    appColors = AppColors();
    _assigned = List.from(widget.assignedItems);
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      await Future.wait([
        _fetchAds(),
        _fetchCarousels(),
        _fetchLiveContent(),
        _fetchWidgets(),
        _fetchLogoAssets(),
      ]);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isImage(String url) {
    final clean = url.split('?').first.toLowerCase();

    return clean.endsWith('.jpg') ||
        clean.endsWith('.jpeg') ||
        clean.endsWith('.png') ||
        clean.endsWith('.gif') ||
        clean.endsWith('.webp');
  }

  Future<void> _fetchAds() async {
    try {
      final res = await ApiService.get('/ads/all');
      final data = jsonDecode(res.body);
      // if (mounted)

      //   setState(() {
      //     _ads = (data['ads'] as List? ?? [])
      //         .where((a) => a['url'] != null)
      //         .toList();
      //   });

      final zoneType = widget.zone['content_type_allowed'];

      List<dynamic> ads = (data['ads'] as List? ?? [])
          .where((a) => a['url'] != null)
          .toList();

      // Filter according to zone type
      if (zoneType == "media") {
        // Media zone -> Only images
        ads = ads.where((a) => _isImage(a['url'])).toList();
      }

      if (mounted) {
        setState(() {
          _ads = ads;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchCarousels() async {
    try {
      final res = await ApiService.get('/carousel/all');
      final data = jsonDecode(res.body);

      // if (mounted) setState(() => _carousels = data['data'] ?? []);
      final zoneType = widget.zone['content_type_allowed'];

      List<dynamic> carousels = data['data'] ?? [];

      if (zoneType == "media") {
        // Media zone -> only carousels containing image ads
        carousels = carousels.where((carousel) {
          final items = carousel['items'] as List? ?? [];

          return items.isNotEmpty &&
              items.every((item) {
                final url = item['Ad']?['url'];
                return url != null && _isImage(url);
              });
        }).toList();
      }

      if (mounted) {
        setState(() {
          _carousels = carousels;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchLiveContent() async {
    try {
      final res = await ApiService.get('/live-content/all');
      final data = jsonDecode(res.body);
      if (mounted) setState(() => _liveContent = data['data'] ?? []);
    } catch (_) {}
  }

  Future<void> _fetchWidgets() async {
    try {
      final res = await ApiService.get('/widgets');
      final data = jsonDecode(res.body);
      if (mounted)
        setState(() => _widgets = data is List ? data : (data['data'] ?? []));
    } catch (_) {}
  }

  bool get _isMedia {
    final t = widget.zone['content_type_allowed'] ?? 'media';
    return t == 'media' || t == 'video_input_media';
  }

  List<dynamic> get _filtered {
    List<dynamic> data = [];
    if (_contentType == 'ad') data = _ads;
    if (_contentType == 'carousel') data = _carousels;
    if (_contentType == 'live_content') data = _liveContent;

    return data.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      return name.contains(_search.toLowerCase());
    }).toList();
  }

  List<dynamic> get _paginated {
    final f = _filtered;
    final start = (_page - 1) * _perPage;
    final end = (start + _perPage).clamp(0, f.length);
    return start < f.length ? f.sublist(start, end) : [];
  }

  int get _totalPages => (_filtered.length / _perPage).ceil().clamp(1, 9999);

  void _addContent(dynamic item, String type) {
    final timeSlots = widget.timeSlots
        .map((s) => Map<String, String>.from(s))
        .toList();

    String id = '';
    String name = item['name'] ?? '';
    String clientName = '';
    int duration = 0;

    if (type == 'ad') {
      id = item['ad_id'] ?? '';
      clientName = item['client_name'] ?? item['Client']?['name'] ?? '';
      duration = (item['duration'] as num?)?.toInt() ?? 0;
    } else if (type == 'carousel') {
      id = item['carousel_id'] ?? '';
      clientName = item['Client']?['name'] ?? '';
      duration = (item['total_duration'] as num?)?.toInt() ?? 0;
    } else {
      id = item['live_content_id'] ?? '';
      clientName = item['Client']?['name'] ?? '';
      duration = (item['duration'] as num?)?.toInt() ?? 0;
    }

    setState(() {
      _assigned.add({
        'id': _generateId(),
        'content_id': id,
        'content_type': type,
        'content_type_allowed': widget.zone['content_type_allowed'],
        'name': name,
        'client_name': clientName,
        'duration': duration,
        'display_order': _assigned.length + 1,
        'time_slots': timeSlots,
      });
    });
  }

  void _removeContent(String itemId) {
    setState(() => _assigned.removeWhere((i) => i['id'] == itemId));
  }

  void _save() {
    if (_assigned.isEmpty) {
      AppDialogs.showValidationError(
        context,
        appColors,
        'Please add at least one content item',
      );
      return;
    }
    if (!_validateWidgetRequiredFields()) {
      return;
    }
    widget.onSave(_assigned);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final zoneName = widget.zone['name'] ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: appColors.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: appColors.surface,
                border: Border(bottom: BorderSide(color: appColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isMedia
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isMedia
                          ? Icons.play_circle_outline_rounded
                          : Icons.widgets_rounded,
                      color: _isMedia ? Colors.blue : Colors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isMedia
                              ? 'Assign Content to Zone: $zoneName'
                              : 'Assign Widgets to Zone: $zoneName',
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          _isMedia
                              ? 'Add advertisements, carousels or live content'
                              : 'Select widgets to display in this zone',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: appColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Time constraint banner
                        _TimeConstraintBanner(
                          timeSlots: widget.timeSlots,
                          appColors: appColors,
                        ),
                        const SizedBox(height: 16),

                        if (_isMedia)
                          _MediaAssignContent(
                            zoneType: widget.zone['content_type_allowed'],
                            ads: _ads,
                            carousels: _carousels,
                            liveContent: _liveContent,
                            assigned: _assigned,
                            contentType: _contentType,
                            search: _search,
                            page: _page,
                            totalPages: _totalPages,
                            paginated: _paginated,
                            appColors: appColors,
                            onContentTypeChange: (t) => setState(() {
                              _contentType = t;
                              _page = 1;
                              _search = '';
                            }),
                            onSearchChange: (s) => setState(() {
                              _search = s;
                              _page = 1;
                            }),
                            onPageChange: (p) => setState(() => _page = p),
                            onAdd: _addContent,
                            onRemove: _removeContent,
                            onUpdateSlots: (itemId, slots) {
                              setState(() {
                                final idx = _assigned.indexWhere(
                                  (i) => i['id'] == itemId,
                                );
                                if (idx >= 0)
                                  _assigned[idx]['time_slots'] = slots;
                              });
                            },
                          )
                        else
                          _WidgetAssignContent(
                            widgets: _widgets,
                            assigned: _assigned,
                            appColors: appColors,
                            logoAssets: _logoAssets,
                            onUploadLogo: _uploadLogo,
                            uploadingLogo: _uploadingLogo,
                            onSelectWidget: (w) {
                              setState(() {
                                // only 1 widget allowed per zone
                                final defaultConfig = <String, dynamic>{};
                                final props =
                                    (w['config_schema']?['properties']
                                        as Map?) ??
                                    {};
                                props.forEach((k, v) {
                                  defaultConfig[k] = v['default'] ?? '';
                                });
                                _assigned = [
                                  {
                                    'id': _generateId(),
                                    'content_id': w['widget_definition_id'],
                                    'content_type': 'widget',
                                    'content_type_allowed': 'widget',

                                    'name': w['type'],
                                    'widget_type': w['type'],

                                    'asset_id': null,

                                    'duration': 0,
                                    'display_order': 1,

                                    'widget_config': defaultConfig,

                                    'time_slots': widget.timeSlots
                                        .map((s) => Map<String, String>.from(s))
                                        .toList(),
                                  },
                                ];
                              });
                            },
                            onRemove: _removeContent,
                            onUpdateConfig: (itemId, key, val) {
                              setState(() {
                                final idx = _assigned.indexWhere(
                                  (i) => i['id'] == itemId,
                                );

                                if (idx < 0) return;

                                if (key == '__asset_id') {
                                  _assigned[idx]['asset_id'] = val;
                                  return;
                                }

                                (_assigned[idx]['widget_config'] as Map)[key] =
                                    val;
                              });
                            },
                            allWidgetDefs: _widgets,
                          ),
                      ],
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              decoration: BoxDecoration(
                color: appColors.surface,
                border: Border(top: BorderSide(color: appColors.border)),
              ),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: appColors.accent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    child: const Text('Save Zone Assignment'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: appColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Time Constraint Banner
// ─────────────────────────────────────────────

class _TimeConstraintBanner extends StatelessWidget {
  final List<Map<String, String>> timeSlots;
  final AppColors appColors;

  const _TimeConstraintBanner({
    required this.timeSlots,
    required this.appColors,
  });

  int _totalMinutes() {
    int total = 0;
    for (final s in timeSlots) {
      final start = _timeToMin(s['start'] ?? '00:00');
      final end = _timeToMin(s['end'] ?? '23:59');
      total += (end - start).clamp(0, 9999);
    }
    return total;
  }

  int _timeToMin(String t) {
    final parts = t.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalMinutes();
    final h = total ~/ 60;
    final m = total % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Color(0xFFB45309),
              ),
              const SizedBox(width: 6),
              Text(
                'Layout Time Constraint',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ...timeSlots.map(
                (s) => _slotBadge('Allowed: ${s['start']} – ${s['end']}'),
              ),
              _slotBadge('Total: ${h}h ${m}m', secondary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slotBadge(String text, {bool secondary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: secondary
            ? Colors.grey.withOpacity(0.1)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: secondary
              ? Colors.grey.withOpacity(0.3)
              : const Color(0xFFFCD34D),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!secondary)
            const Icon(
              Icons.access_time_rounded,
              size: 11,
              color: Color(0xFFB45309),
            ),
          if (!secondary) const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: secondary ? Colors.grey[700] : const Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Media Assign Content
// ─────────────────────────────────────────────

class _MediaAssignContent extends StatelessWidget {
  final String zoneType;

  final List<dynamic> ads, carousels, liveContent;
  final List<Map<String, dynamic>> assigned;
  final String contentType, search;
  final int page, totalPages;
  final List<dynamic> paginated;
  final AppColors appColors;
  final void Function(String) onContentTypeChange;
  final void Function(String) onSearchChange;
  final void Function(int) onPageChange;
  final void Function(dynamic, String) onAdd;
  final void Function(String) onRemove;
  final void Function(String, List<Map<String, String>>) onUpdateSlots;

  const _MediaAssignContent({
    required this.zoneType,
    required this.ads,
    required this.carousels,
    required this.liveContent,
    required this.assigned,
    required this.contentType,
    required this.search,
    required this.page,
    required this.totalPages,
    required this.paginated,
    required this.appColors,
    required this.onContentTypeChange,
    required this.onSearchChange,
    required this.onPageChange,
    required this.onAdd,
    required this.onRemove,
    required this.onUpdateSlots,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content type dropdown
        Row(
          children: [
            Text(
              'Add Content Type: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: appColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ContentTypeDropdown(
                value: contentType,
                zoneType: zoneType,
                onChange: onContentTypeChange,
                appColors: appColors,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Available list
        Text(
          'Available ${contentType == 'ad'
              ? 'Advertisements'
              : contentType == 'carousel'
              ? 'Carousels'
              : 'Live Content'}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: appColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        // Search
        TextField(
          onChanged: onSearchChange,
          style: TextStyle(color: appColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: appColors.textMuted),
            prefixIcon: Icon(Icons.search_rounded, color: appColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: appColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: appColors.border),
            ),
            filled: true,
            fillColor: appColors.surface,
          ),
        ),
        const SizedBox(height: 8),

        // List
        ...paginated.map(
          (item) => _AvailableContentItem(
            item: item,
            contentType: contentType,
            appColors: appColors,
            onAdd: () => onAdd(item, contentType),
          ),
        ),

        // Pagination
        _Pagination(
          page: page,
          totalPages: totalPages,
          onPrev: page > 1 ? () => onPageChange(page - 1) : null,
          onNext: page < totalPages ? () => onPageChange(page + 1) : null,
          appColors: appColors,
        ),
        const SizedBox(height: 20),

        // Assigned content
        Text(
          'Assigned Content (${assigned.length})',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: appColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        if (assigned.isEmpty)
          _EmptyAssigned(appColors: appColors)
        else
          ...assigned.map(
            (item) => _AssignedContentItem(
              item: item,
              appColors: appColors,
              onRemove: () => onRemove(item['id']),
              onUpdateSlots: (slots) => onUpdateSlots(item['id'], slots),
            ),
          ),
      ],
    );
  }
}

class _ContentTypeDropdown extends StatelessWidget {
  final String value;
  final String zoneType;
  final void Function(String) onChange;
  final AppColors appColors;

  const _ContentTypeDropdown({
    super.key,
    required this.value,
    required this.zoneType,
    required this.onChange,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: (v) => v != null ? onChange(v) : null,
          dropdownColor: appColors.surface,
          style: TextStyle(color: appColors.textPrimary, fontSize: 14),
          items: [
            const DropdownMenuItem(
              value: 'ad',
              child: Row(
                children: [
                  Icon(Icons.play_arrow_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Advertisement'),
                ],
              ),
            ),

            const DropdownMenuItem(
              value: 'carousel',
              child: Row(
                children: [
                  Icon(Icons.image_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Carousel'),
                ],
              ),
            ),

            if (zoneType == "video_input_media")
              const DropdownMenuItem(
                value: 'live_content',
                child: Row(
                  children: [
                    Icon(Icons.radio_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Live Content'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvailableContentItem extends StatelessWidget {
  final dynamic item;
  final String contentType;
  final AppColors appColors;
  final VoidCallback onAdd;

  const _AvailableContentItem({
    required this.item,
    required this.contentType,
    required this.appColors,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    String name = item['name'] ?? '';
    String sub = '';

    if (contentType == 'ad') {
      sub =
          '${item['client_name'] ?? item['Client']?['name'] ?? ''} · ${_formatDuration((item['duration'] as num?)?.toInt() ?? 0)}';
    } else if (contentType == 'carousel') {
      sub =
          '${item['Client']?['name'] ?? ''} · ${(item['items'] as List?)?.length ?? 0} slides · ${_formatDuration((item['total_duration'] as num?)?.toInt() ?? 0)}';
    } else {
      sub =
          '${(item['content_type'] ?? '').toString().toUpperCase()} · ${item['status'] ?? ''}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(color: appColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(color: appColors.border),
                borderRadius: BorderRadius.circular(8),
                color: appColors.bg,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedContentItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final AppColors appColors;
  final VoidCallback onRemove;
  final void Function(List<Map<String, String>>) onUpdateSlots;

  const _AssignedContentItem({
    required this.item,
    required this.appColors,
    required this.onRemove,
    required this.onUpdateSlots,
  });

  @override
  Widget build(BuildContext context) {
    final slots = List<Map<String, String>>.from(
      ((item['time_slots'] as List?) ?? []).map(
        (s) => Map<String, String>.from(s),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item['content_type'] ?? '',
                  style: const TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: appColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Time slots
          ...slots.asMap().entries.map((e) {
            final idx = e.key;
            final slot = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'Start',
                      value: slot['start'] ?? '09:00',
                      appColors: appColors,
                      onChanged: (v) {
                        final updated = List<Map<String, String>>.from(slots);
                        updated[idx] = {...updated[idx], 'start': v};
                        onUpdateSlots(updated);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'to',
                      style: TextStyle(color: appColors.textMuted),
                    ),
                  ),
                  Expanded(
                    child: _TimeField(
                      label: 'End',
                      value: slot['end'] ?? '17:00',
                      appColors: appColors,
                      onChanged: (v) {
                        final updated = List<Map<String, String>>.from(slots);
                        updated[idx] = {...updated[idx], 'end': v};
                        onUpdateSlots(updated);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      final updated = List<Map<String, String>>.from(slots)
                        ..removeAt(idx);
                      onUpdateSlots(updated);
                    },
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Colors.red.shade300,
                    ),
                  ),
                ],
              ),
            );
          }),

          TextButton.icon(
            onPressed: () {
              final updated = List<Map<String, String>>.from(slots)
                ..add({'start': '09:00', 'end': '17:00'});
              onUpdateSlots(updated);
            },
            icon: const Icon(Icons.add_rounded, size: 14),
            label: const Text('Add Slot', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final AppColors appColors;
  final void Function(String) onChanged;

  const _TimeField({
    required this.label,
    required this.value,
    required this.appColors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final parts = value.split(':');
        final initial = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );
        if (picked != null) {
          final h = picked.hour.toString().padLeft(2, '0');
          final m = picked.minute.toString().padLeft(2, '0');
          onChanged('$h:$m');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: appColors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: appColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 14,
              color: appColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: appColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAssigned extends StatelessWidget {
  final AppColors appColors;

  const _EmptyAssigned({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.tv_off_rounded, size: 36, color: appColors.textMuted),
          const SizedBox(height: 8),
          Text(
            'No content assigned',
            style: TextStyle(
              color: appColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Select content from the list above',
            style: TextStyle(color: appColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page, totalPages;
  final VoidCallback? onPrev, onNext;
  final AppColors appColors;

  const _Pagination({
    required this.page,
    required this.totalPages,
    this.onPrev,
    this.onNext,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PagBtn(label: 'Prev', onTap: onPrev, appColors: appColors),
          Text(
            'Page $page of $totalPages',
            style: TextStyle(color: appColors.textMuted, fontSize: 13),
          ),
          _PagBtn(label: 'Next', onTap: onNext, appColors: appColors),
        ],
      ),
    );
  }
}

class _PagBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppColors appColors;

  const _PagBtn({required this.label, this.onTap, required this.appColors});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: enabled ? appColors.surface : appColors.border,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? appColors.border : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: enabled ? appColors.textPrimary : appColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget Assign Content
// ─────────────────────────────────────────────

class _WidgetAssignContent extends StatelessWidget {
  final List<dynamic> widgets;
  final List<Map<String, dynamic>> assigned;
  final AppColors appColors;
  final void Function(Map<String, dynamic>) onSelectWidget;
  final void Function(String) onRemove;
  final void Function(String, String, dynamic) onUpdateConfig;
  final List<dynamic> allWidgetDefs;
  final List<dynamic> logoAssets;
  final Future<void> Function() onUploadLogo;
  final bool uploadingLogo;

  const _WidgetAssignContent({
    required this.widgets,
    required this.assigned,
    required this.appColors,
    required this.onSelectWidget,
    required this.onRemove,
    required this.onUpdateConfig,
    required this.allWidgetDefs,
    required this.logoAssets,
    required this.onUploadLogo,
    required this.uploadingLogo,
  });

  static const _widgetIcons = {
    'clock_analog': Icons.radio_button_checked_rounded,
    'clock_digital': Icons.access_time_rounded,
    'calendar': Icons.calendar_month_rounded,
    'logo': Icons.image_rounded,
    'emoji': Icons.emoji_emotions_rounded,
    'sliding_text': Icons.text_fields_rounded,
    'ticker': Icons.text_fields_rounded,
    'countdown_timer': Icons.timer_rounded,
    'heading': Icons.title_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final selectedItem = assigned.isNotEmpty ? assigned.first : null;
    final selectedDef = selectedItem != null
        ? allWidgetDefs.firstWhere(
            (w) => w['widget_definition_id'] == selectedItem['content_id'],
            orElse: () => null,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Widgets',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),

        // Widget grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemCount: widgets.length,
          itemBuilder: (_, i) {
            final w = widgets[i];
            final isSelected =
                selectedItem?['content_id'] == w['widget_definition_id'];
            final icon = _widgetIcons[w['type']] ?? Icons.widgets_rounded;
            final label = (w['type'] as String)
                .replaceAll('_', ' ')
                .split(' ')
                .map((s) => s[0].toUpperCase() + s.substring(1))
                .join(' ');

            return GestureDetector(
              onTap: () => onSelectWidget(Map<String, dynamic>.from(w)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? appColors.accent.withOpacity(0.08)
                      : appColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? appColors.accent : appColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? appColors.accent
                                  : appColors.bg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icon,
                              size: 22,
                              color: isSelected
                                  ? Colors.white
                                  : appColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: appColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Config form
        if (selectedItem != null && selectedDef != null) ...[
          Text(
            (selectedDef['type'] as String).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          _WidgetConfigForm(
            item: selectedItem,
            widgetDef: selectedDef,
            appColors: appColors,
            onUpdateConfig: onUpdateConfig,
            logoAssets: logoAssets,
            onUploadLogo: onUploadLogo,
            uploadingLogo: uploadingLogo,
          ),
          const SizedBox(height: 12),
        ],

        // Selected widgets summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Widgets (${assigned.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: appColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              if (assigned.isEmpty)
                Text(
                  'No widgets selected',
                  style: TextStyle(color: appColors.textMuted, fontSize: 12),
                )
              else
                Wrap(
                  spacing: 8,
                  children: assigned.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item['name'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: appColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => onRemove(item['id']),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: appColors.accent,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WidgetConfigForm extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, dynamic> widgetDef;
  final AppColors appColors;
  final void Function(String, String, dynamic) onUpdateConfig;
  final List<dynamic> logoAssets;
  final Future<void> Function() onUploadLogo;
  final bool uploadingLogo;

  const _WidgetConfigForm({
    required this.item,
    required this.widgetDef,
    required this.appColors,
    required this.onUpdateConfig,
    required this.logoAssets,
    required this.onUploadLogo,
    required this.uploadingLogo,
  });

  @override
  Widget build(BuildContext context) {
    final props = (widgetDef['config_schema']?['properties'] as Map?) ?? {};
    final required = List<String>.from(
      widgetDef['config_schema']?['required'] ?? [],
    );
    final config = Map<String, dynamic>.from(item['widget_config'] ?? {});

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: props.entries.map<Widget>((e) {
          final key = e.key;
          final schema = e.value as Map;
          final widgetType = widgetDef['type'];
          final val = config[key]?.toString() ?? '';
          final isRequired = required.contains(key);
          final isColor =
              key.toLowerCase().contains('color') || key == 'background';
          final enums = schema['enum'] as List?;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      key,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: appColors.textPrimary,
                      ),
                    ),
                    if (isRequired)
                      const Text(
                        ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (enums != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: appColors.bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: appColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: enums.contains(val) ? val : null,
                        onChanged: (v) => v != null
                            ? onUpdateConfig(item['id'], key, v)
                            : null,
                        dropdownColor: appColors.surface,
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontSize: 13,
                        ),
                        isExpanded: true,
                        items: enums
                            .map<DropdownMenuItem<String>>(
                              (opt) => DropdownMenuItem(
                                value: opt.toString(),
                                child: Text(opt.toString()),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                else if (isColor)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          // Color picker tap – show simple hex input
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(val, Colors.black),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: appColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: val,
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: appColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: appColors.border),
                            ),
                            filled: true,
                            fillColor: appColors.bg,
                          ),
                          onChanged: (v) => onUpdateConfig(item['id'], key, v),
                        ),
                      ),
                    ],
                  )
                else if (widgetType == "logo" && key == "url")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: val.isNotEmpty ? val : null,
                        decoration: InputDecoration(
                          hintText: "Select a logo",
                          hintStyle: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: logoAssets.map((asset) {
                          return DropdownMenuItem<String>(
                            value: asset['storage_key'],
                            child: Text(
                              asset['name'] ?? 'Logo',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        // onChanged: (v) {
                        //   if (v != null) {
                        //     onUpdateConfig(item['id'], key, v);
                        //   }
                        // },
                        onChanged: (v) {
                          if (v == null) return;

                          final asset = logoAssets.firstWhere(
                            (a) => a['storage_key'] == v,
                            orElse: () => {},
                          );

                          onUpdateConfig(item['id'], key, v);

                          if (asset.isNotEmpty) {
                            onUpdateConfig(
                              item['id'],
                              '__asset_id',
                              asset['asset_id'],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: uploadingLogo ? null : onUploadLogo,
                          icon: uploadingLogo
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.cloud_upload_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            uploadingLogo ? "Uploading..." : "Upload Logo",
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: appColors.accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: appColors.accent
                                .withOpacity(0.4),
                            disabledForegroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  TextFormField(
                    initialValue: val,
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      filled: true,
                      fillColor: appColors.bg,
                    ),
                    onChanged: (v) => onUpdateConfig(item['id'], key, v),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
