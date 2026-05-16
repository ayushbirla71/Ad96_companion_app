import 'dart:convert';
import 'package:cms_app/pages/ads/preview_popup.dart';
import 'package:cms_app/theme/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../../models/ad.dart';
import '../../services/api_service.dart';
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

// ─── Safe parsers ─────────────────────────────────────────────────────────────
int _parseInt(dynamic v, [int fb = 0]) {
  if (v == null) return fb;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fb;
  return fb;
}

double _parseDouble(dynamic v, [double fb = 0]) {
  if (v == null) return fb;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fb;
  return fb;
}

String _str(dynamic v, [String fb = '']) {
  if (v == null) return fb;
  if (v is String) return v.trim().isEmpty ? fb : v;
  return v.toString();
}

DateTime _date(dynamic v) => DateTime.tryParse(_str(v)) ?? DateTime.now();

// ─── Models ───────────────────────────────────────────────────────────────────

class AdDetail {
  final String id, name, status;
  final int duration;
  final DateTime createdAt;
  final AdKpis kpis;
  final List<AdPerformance> performance;
  final List<AdDeviceDist> deviceDistribution;
  final List<AdHourly> hourlyData;
  final List<AdLog> logs;

  const AdDetail({
    required this.id,
    required this.name,
    required this.status,
    required this.duration,
    required this.createdAt,
    required this.kpis,
    required this.performance,
    required this.deviceDistribution,
    required this.hourlyData,
    required this.logs,
  });

  factory AdDetail.fromJson(Map<String, dynamic> j) {
    final ad = (j['ad'] as Map<String, dynamic>?) ?? {};
    return AdDetail(
      id: _str(ad['id']),
      name: _str(ad['name'], 'Unknown Ad'),
      status: _str(ad['status'], 'unknown'),
      duration: _parseInt(ad['duration']),
      createdAt: _date(ad['createdDate']),
      kpis: AdKpis.fromJson((j['kpis'] as Map<String, dynamic>?) ?? {}),
      performance: ((j['performance'] as List?) ?? [])
          .map((e) => AdPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
      deviceDistribution: ((j['deviceDistribution'] as List?) ?? [])
          .map((e) => AdDeviceDist.fromJson(e as Map<String, dynamic>))
          .toList(),
      hourlyData: ((j['hourlyData'] as List?) ?? [])
          .map((e) => AdHourly.fromJson(e as Map<String, dynamic>))
          .toList(),
      logs: ((j['logs'] as List?) ?? [])
          .map((e) => AdLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdKpis {
  final int totalPlays, avgWatchTime, impressions;
  final double engagementRate;
  const AdKpis({
    required this.totalPlays,
    required this.avgWatchTime,
    required this.impressions,
    required this.engagementRate,
  });
  factory AdKpis.fromJson(Map<String, dynamic> j) => AdKpis(
    totalPlays: _parseInt(j['totalPlays']),
    avgWatchTime: _parseInt(j['avgWatchTime']),
    impressions: _parseInt(j['impressions']),
    engagementRate: _parseDouble(j['engagementRate']),
  );
}

class AdPerformance {
  final String date;
  final int plays, impressions;
  const AdPerformance({
    required this.date,
    required this.plays,
    required this.impressions,
  });
  factory AdPerformance.fromJson(Map<String, dynamic> j) => AdPerformance(
    date: _str(j['date']),
    plays: _parseInt(j['plays']),
    impressions: _parseInt(j['impressions']),
  );
}

class AdDeviceDist {
  final String name;
  final int plays, value;
  const AdDeviceDist({
    required this.name,
    required this.plays,
    required this.value,
  });
  factory AdDeviceDist.fromJson(Map<String, dynamic> j) => AdDeviceDist(
    name: _str(j['name'], 'unknown'),
    plays: _parseInt(j['plays']),
    value: _parseInt(j['value']),
  );
}

class AdHourly {
  final String hour;
  final int plays;
  const AdHourly({required this.hour, required this.plays});
  factory AdHourly.fromJson(Map<String, dynamic> j) =>
      AdHourly(hour: _str(j['hour']), plays: _parseInt(j['plays']));
}

class AdLog {
  final String id, device, deviceType, location, status;
  final DateTime playDate;
  final int duration, engagement;
  const AdLog({
    required this.id,
    required this.device,
    required this.deviceType,
    required this.location,
    required this.status,
    required this.playDate,
    required this.duration,
    required this.engagement,
  });
  factory AdLog.fromJson(Map<String, dynamic> j) => AdLog(
    id: _str(j['id']),
    device: _str(j['device'], 'Unknown'),
    deviceType: _str(j['deviceType'], 'unknown'),
    location: _str(j['location']),
    status: _str(j['status'], 'unknown'),
    playDate: _date(j['playDate']),
    duration: _parseInt(j['duration']),
    engagement: _parseInt(j['engagement']),
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdDetailsPage extends StatefulWidget {
  final dynamic ad;
  const AdDetailsPage({super.key, required this.ad});

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

const _kLogsPerPage = 8;

class _AdDetailsPageState extends State<AdDetailsPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  AdDetail? _detail;
  String? _error;
  int _logPage = 0;

  String _preset = 'Last 30 Days';
  DateTimeRange? _customRange;

  AnimationController? _fadeCtrl;
  Animation<double>? _fadeAnim;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeCtrl = ctrl;
    _fadeAnim = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl?.dispose();
    super.dispose();
  }

  void openPreview(String url) {
    showDialog(
      context: context,

      barrierColor: Colors.black.withOpacity(0.85),

      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),

        child: PreviewPopup(url: url),
      ),
    );
  }

  // ─── Date range ────────────────────────────────────────────────────────────

  DateTimeRange _getRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_preset) {
      case 'Today':
        return DateTimeRange(start: today, end: today);
      case 'Yesterday':
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: y, end: y);
      case 'Last 7 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case 'Last 14 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 13)),
          end: today,
        );
      case 'Last 30 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
      case 'This Month':
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: today,
        );
      case 'Custom':
        return _customRange ??
            DateTimeRange(
              start: today.subtract(const Duration(days: 29)),
              end: today,
            );
      default:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
    }
  }

  String _iso(DateTime d) => d.toUtc().toIso8601String();

  // ─── Load ──────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _logPage = 0;
    });
    try {
      final range = _getRange();
      final res = await ApiService.get(
        '/ads/details/${widget.ad.id}'
        '?start_date=${_iso(range.start)}&end_date=${_iso(range.end)}',
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        if (mounted) {
          setState(() => _detail = AdDetail.fromJson(json));
          _fadeCtrl?.forward(from: 0);
        }
      } else {
        throw Exception('Server error ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

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

  String _fmtDateShort(DateTime d) {
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
    return '${m[d.month]} ${d.day}';
  }

  String _fmtTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '$h:$min $period';
  }

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

  IconData _deviceIcon(String name) {
    switch (name.toLowerCase()) {
      case 'tv':
        return Icons.tv_rounded;
      case 'signage':
        return Icons.monitor_rounded;
      case 'mobile':
        return Icons.smartphone_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: appColors.bg,
  //     appBar: AppBar(
  //       backgroundColor: appColors.surface,
  //       surfaceTintColor: Colors.transparent,
  //       elevation: 0,
  //       leading: IconButton(
  //         icon: Container(
  //           width: 34,
  //           height: 34,
  //           decoration: BoxDecoration(
  //             color: appColors.surfaceHigh,
  //             shape: BoxShape.circle,
  //             border: Border.all(color: appColors.border),
  //           ),
  //           child: Icon(
  //             Icons.arrow_back_ios_new_rounded,
  //             color: appColors.textSecondary,
  //             size: 15,
  //           ),
  //         ),
  //         onPressed: () => Navigator.pop(context),
  //       ),
  //       title: Text(
  //         'Ad Details',
  //         style: TextStyle(
  //           color: appColors.textPrimary,
  //           fontSize: 15,
  //           fontWeight: FontWeight.w700,
  //           letterSpacing: -0.3,
  //         ),
  //       ),
  //       actions: [
  //         IconButton(
  //           icon: Container(
  //             width: 34,
  //             height: 34,
  //             decoration: BoxDecoration(
  //               color: appColors.surfaceHigh,
  //               shape: BoxShape.circle,
  //               border: Border.all(color: appColors.border),
  //             ),
  //             child: Icon(
  //               Icons.refresh_rounded,
  //               color: appColors.textSecondary,
  //               size: 17,
  //             ),
  //           ),
  //           onPressed: _load,
  //         ),
  //         const SizedBox(width: 4),
  //       ],
  //       bottom: PreferredSize(
  //         preferredSize: const Size.fromHeight(1),
  //         child: Container(height: 1, color: appColors.border),
  //       ),
  //     ),
  //     body: _loading
  //         ? _loader()
  //         : _error != null
  //         ? _errorView()
  //         : _fadeAnim != null
  //         ? FadeTransition(opacity: _fadeAnim!, child: _body())
  //         : _body(),
  //   );
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.bg,

      appBar: CustomAppBar(title: "Ad Details", onRefresh: _load),

      body: _loading
          ? _loader()
          : _error != null
          ? _errorView()
          : _fadeAnim != null
          ? FadeTransition(opacity: _fadeAnim!, child: _body())
          : _body(),
    );
  }
  // ─── Body ──────────────────────────────────────────────────────────────────

  Widget _body() {
    final d = _detail!;
    return RefreshIndicator(
      color: appColors.accent,
      backgroundColor: appColors.surface,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ad info card ──
            _adInfoCard(d),
            const SizedBox(height: 16),

            // ── Date filter row ──
            _dateFilterRow(),
            const SizedBox(height: 20),

            // ── KPI grid ──
            _kpiGrid(d.kpis),
            const SizedBox(height: 20),

            // ── Performance ──
            _sectionLabel('Performance Over Time'),
            const SizedBox(height: 10),
            _performanceChart(d.performance),
            const SizedBox(height: 20),

            // ── Device Distribution ──
            _sectionLabel('Device Distribution'),
            const SizedBox(height: 10),
            _deviceDistribution(d.deviceDistribution),
            const SizedBox(height: 20),

            // ── Peak Hours ──
            _sectionLabel('Peak Hours'),
            const SizedBox(height: 10),
            _hourlyChart(d.hourlyData),
            const SizedBox(height: 20),

            // ── Play Logs ──
            _sectionLabel(
              'Play Logs',
              badge: d.logs.length.toString(),
              badgeColor: appColors.accent,
            ),
            const SizedBox(height: 10),
            _logsPaginated(d.logs),
          ],
        ),
      ),
    );
  }

  // ─── Ad Info Card ──────────────────────────────────────────────────────────

  Widget _adInfoCard(AdDetail d) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [appColors.accent, const Color(0xFF1E40AF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: appColors.accent.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Decorative circles
        Positioned(
          right: -20,
          top: -20,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          left: -10,
          bottom: -30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status + duration row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(d.status).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _statusColor(d.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          d.status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(d.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${d.duration}s duration',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// AD NAME
                  Expanded(
                    child: Text(
                      d.name,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// EYE BUTTON
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.95, end: 1),
                    duration: const Duration(milliseconds: 400),

                    curve: Curves.easeOutBack,

                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },

                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,

                      child: StatefulBuilder(
                        builder: (context, setBtnState) {
                          bool isHovered = false;

                          return StatefulBuilder(
                            builder: (context, refresh) {
                              return MouseRegion(
                                onEnter: (_) {
                                  isHovered = true;
                                  refresh(() {});
                                },

                                onExit: (_) {
                                  isHovered = false;
                                  refresh(() {});
                                },

                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),

                                  curve: Curves.easeInOut,

                                  width: isHovered ? 48 : 48,
                                  height: isHovered ? 48 : 48,

                                  decoration: BoxDecoration(
                                    color: isHovered
                                        ? Colors.white.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.15),

                                    shape: BoxShape.circle,

                                    border: Border.all(
                                      color: isHovered
                                          ? Colors.white.withOpacity(0.5)
                                          : Colors.white.withOpacity(0.2),
                                    ),

                                    boxShadow: isHovered
                                        ? [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  ),

                                  child: Material(
                                    color: Colors.transparent,

                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),

                                      splashColor: Colors.white24,

                                      onTap: () {
                                        // TODO: preview
                                        openPreview(widget.ad.url);
                                      },

                                      child: const Icon(
                                        Icons.visibility_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Created date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Created ${_fmtDate(d.createdAt)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── Date Filter Row ───────────────────────────────────────────────────────

  Widget _dateFilterRow() {
    final range = _getRange();
    final presets = [
      'Today',
      'Yesterday',
      'Last 7 Days',
      'Last 14 Days',
      'Last 30 Days',
      'This Month',
    ];

    return Row(
      children: [
        // Preset dropdown
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final offset = box.localToGlobal(Offset.zero);
              final selected = await showMenu<String>(
                context: context,
                color: appColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: appColors.border),
                ),
                position: RelativeRect.fromLTRB(
                  16,
                  offset.dy + 200,
                  MediaQuery.of(context).size.width / 2,
                  0,
                ),
                items: [
                  PopupMenuItem(
                    enabled: false,
                    height: 36,
                    child: Text(
                      'Date Presets',
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...presets.map(
                    (p) => PopupMenuItem<String>(
                      value: p,
                      height: 40,
                      child: Row(
                        children: [
                          if (_preset == p)
                            Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: appColors.accent,
                            )
                          else
                            const SizedBox(width: 14),
                          const SizedBox(width: 8),
                          Text(
                            p,
                            style: TextStyle(
                              color: _preset == p
                                  ? appColors.accent
                                  : appColors.textPrimary,
                              fontSize: 13,
                              fontWeight: _preset == p
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
              if (selected != null && selected != _preset) {
                setState(() {
                  _preset = selected;
                  _customRange = null;
                });
                _load();
              }
            },
            child: _filterChip(
              icon: Icons.date_range_rounded,
              label: _preset,
              active: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Custom date range picker
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange:
                    _customRange ??
                    DateTimeRange(start: range.start, end: range.end),
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
                setState(() {
                  _customRange = picked;
                  _preset = 'Custom';
                });
                _load();
              }
            },
            child: _filterChip(
              icon: Icons.calendar_month_rounded,
              label:
                  '${_fmtDateShort(range.start)} – ${_fmtDateShort(range.end)}',
              active: _preset == 'Custom',
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip({
    required IconData icon,
    required String label,
    required bool active,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: active ? appColors.accentLight : appColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: active ? appColors.accent.withOpacity(0.4) : appColors.border,
      ),
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
        Icon(
          icon,
          color: active ? appColors.accent : appColors.textMuted,
          size: 15,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: active ? appColors.accent : appColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: appColors.textMuted,
          size: 16,
        ),
      ],
    ),
  );

  // ─── KPI Grid ──────────────────────────────────────────────────────────────

  Widget _kpiGrid(AdKpis k) {
    final items = [
      _KpiItem(
        icon: Icons.play_circle_rounded,
        label: 'Total Plays',
        value: k.totalPlays.toString(),
        color: appColors.accent,
        bg: appColors.accentLight,
      ),
      _KpiItem(
        icon: Icons.visibility_rounded,
        label: 'Impressions',
        value: k.impressions.toString(),
        color: appColors.purple,
        bg: appColors.purpleLight,
      ),
      _KpiItem(
        icon: Icons.touch_app_rounded,
        label: 'Engagement',
        value: '${k.engagementRate.toStringAsFixed(0)}%',
        color: appColors.green,
        bg: appColors.greenLight,
      ),
      _KpiItem(
        icon: Icons.timer_rounded,
        label: 'Avg Watch',
        value: '${k.avgWatchTime}s',
        color: appColors.teal,
        bg: appColors.tealLight,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: MediaQuery.of(context).size.width < 380 ? 1.45 : 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];

        final isSmall = MediaQuery.of(context).size.width < 380;

        return Container(
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

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Container(
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: item.bg,

                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(
                  item.icon,
                  color: item.color,
                  size: isSmall ? 16 : 18,
                ),
              ),

              const SizedBox(height: 10),

              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,

                  child: Text(
                    item.value,

                    style: TextStyle(
                      color: appColors.textPrimary,

                      fontSize: isSmall ? 24 : 28,

                      fontWeight: FontWeight.w800,

                      letterSpacing: -0.5,

                      height: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                item.label,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: appColors.textSecondary,

                  fontSize: isSmall ? 11 : 12,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Performance Chart ─────────────────────────────────────────────────────

  Widget _performanceChart(List<AdPerformance> data) {
    if (data.isEmpty) return _emptyCard('No performance data available');

    final maxVal = data
        .fold<int>(0, (m, e) => e.plays > m ? e.plays : m)
        .toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              _Legend(color: appColors.accent, label: 'Plays'),
              const SizedBox(width: 16),
              _Legend(color: appColors.purple, label: 'Impressions'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final e = entry.value;
                final isLast = entry.key == data.length - 1;
                final playH = maxVal > 0 ? (e.plays / maxVal) * 120 : 4.0;
                final impH = maxVal > 0 ? (e.impressions / maxVal) * 120 : 4.0;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _Bar(
                              height: playH,
                              color: appColors.accent,
                              radius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 2),
                            _Bar(
                              height: impH,
                              color: appColors.purple,
                              radius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          e.date,
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Device Distribution ───────────────────────────────────────────────────

  Widget _deviceDistribution(List<AdDeviceDist> data) {
    if (data.isEmpty) return _emptyCard('No device data available');

    final total = data.fold<int>(0, (s, e) => s + e.plays);
    final colors = [
      appColors.accent,
      appColors.purple,
      appColors.teal,
      appColors.orange,
      appColors.green,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: data.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final pct = total > 0 ? e.plays / total : 0.0;
          final color = colors[i % colors.length];
          final isLast = i == data.length - 1;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_deviceIcon(e.name), color: color, size: 17),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.name[0].toUpperCase() + e.name.substring(1),
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${e.plays} plays · ${e.value}%',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: appColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 14),
                Divider(height: 1, thickness: 1, color: appColors.borderLight),
                const SizedBox(height: 14),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─── Hourly Chart ──────────────────────────────────────────────────────────

  Widget _hourlyChart(List<AdHourly> data) {
    if (data.isEmpty) {
      return _emptyCard('No hourly data available');
    }

    final sorted = [...data]..sort((a, b) => a.hour.compareTo(b.hour));

    final maxVal = sorted
        .fold<int>(0, (m, e) => e.plays > m ? e.plays : m)
        .toDouble();

    return Container(
      padding: const EdgeInsets.all(16),

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

      child: SizedBox(
        height: 190,

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: sorted.asMap().entries.map((entry) {
            final e = entry.value;

            final isLast = entry.key == sorted.length - 1;

            final h = maxVal > 0 ? (e.plays / maxVal) * 95 : 10.0;

            final isMax = e.plays == maxVal.toInt();

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: [
                    /// TOP VALUE BADGE
                    SizedBox(
                      height: 28,

                      child: isMax
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: appColors.teal,

                                borderRadius: BorderRadius.circular(6),
                              ),

                              child: Text(
                                '${e.plays}',

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 8),

                    /// BAR
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),

                        height: h.clamp(12, 100),

                        decoration: BoxDecoration(
                          color: isMax
                              ? appColors.teal
                              : appColors.accent.withOpacity(0.35),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// LABEL
                    SizedBox(
                      height: 34,

                      child: Text(
                        e.hour.replaceAll(' ', '\n'),

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: isMax ? appColors.teal : appColors.textMuted,

                          fontSize: 11,

                          fontWeight: isMax ? FontWeight.w700 : FontWeight.w500,

                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Logs Paginated ────────────────────────────────────────────────────────

  Widget _logsPaginated(List<AdLog> logs) {
    final totalPages = (logs.length / _kLogsPerPage).ceil();
    if (totalPages == 0) return _emptyCard('No play logs found');

    final slice = logs
        .skip(_logPage * _kLogsPerPage)
        .take(_kLogsPerPage)
        .toList();

    return Column(
      children: [
        Container(
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
          child: Column(
            children: slice.asMap().entries.map((entry) {
              final i = entry.key;
              final log = entry.value;
              final isLast = i == slice.length - 1;
              final sc = _statusColor(log.status);
              final sb = _statusBg(log.status);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: appColors.accentLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _deviceIcon(log.deviceType),
                            color: appColors.accent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.device,
                                style: TextStyle(
                                  color: appColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: appColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      '${_fmtDate(log.playDate)} · ${_fmtTime(log.playDate)}',
                                      style: TextStyle(
                                        color: appColors.textMuted,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 10,
                                    color: appColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      log.location,
                                      style: TextStyle(
                                        color: appColors.textMuted,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
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
                              child: Text(
                                log.status.toUpperCase(),
                                style: TextStyle(
                                  color: sc,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${log.engagement}% engaged',
                              style: TextStyle(
                                color: appColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${log.duration}s',
                              style: TextStyle(
                                color: appColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: appColors.borderLight,
                      indent: 66,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _pageBtn(
                  label: 'Prev',
                  icon: Icons.chevron_left_rounded,
                  leading: true,
                  enabled: _logPage > 0,
                  onTap: () => setState(() => _logPage--),
                ),
                Column(
                  children: [
                    Text(
                      'Page ${_logPage + 1} of $totalPages',
                      style: TextStyle(
                        color: appColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${logs.length} total logs',
                      style: TextStyle(
                        color: appColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                _pageBtn(
                  label: 'Next',
                  icon: Icons.chevron_right_rounded,
                  leading: false,
                  enabled: _logPage < totalPages - 1,
                  onTap: () => setState(() => _logPage++),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _pageBtn({
    required String label,
    required IconData icon,
    required bool leading,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = enabled ? appColors.accent : appColors.textMuted;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? appColors.accentLight : appColors.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? appColors.accent.withOpacity(0.3)
                : appColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: leading
              ? [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              : [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(icon, size: 16, color: color),
                ],
        ),
      ),
    );
  }

  // ─── Shared widgets ────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, {String? badge, Color? badgeColor}) => Row(
    children: [
      Text(
        text,
        style: TextStyle(
          color: appColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      if (badge != null) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (badgeColor ?? appColors.accent).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: badgeColor ?? appColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ],
  );

  Widget _emptyCard(String msg) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: appColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: appColors.border),
    ),
    child: Center(
      child: Text(
        msg,
        style: TextStyle(color: appColors.textMuted, fontSize: 13),
      ),
    ),
  );

  Widget _loader() => Center(
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
          'Loading ad details…',
          style: TextStyle(color: appColors.textMuted, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _errorView() => Center(
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
          const SizedBox(height: 20),
          Text(
            'Could not load ad details',
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'An unexpected error occurred.',
            style: TextStyle(color: appColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: appColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Helper classes ───────────────────────────────────────────────────────────

class _KpiItem {
  final IconData icon;
  final String label, value;
  final Color color, bg;
  const _KpiItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(color: appColors.textSecondary, fontSize: 11),
      ),
    ],
  );
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  final BorderRadius radius;
  const _Bar({required this.height, required this.color, required this.radius});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    width: 10,
    height: height.clamp(4, 120),
    decoration: BoxDecoration(color: color, borderRadius: radius),
  );
}
