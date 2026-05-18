// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cms_app/services/api_service.dart';
// import '../../models/device.dart';
// import '../../providers/device_provider.dart';

// class DeviceDetailsPage extends StatefulWidget {
//   final Device device;

//   const DeviceDetailsPage({
//     super.key,
//     required this.device,
//   });

//   @override
//   State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
// }

// class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
//   bool _deleting = false;

//   @override
//   Widget build(BuildContext context) {
//     final isOnline =
//         widget.device.status == "online" || widget.device.status == "active";

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.device.deviceName),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete),
//             tooltip: "Delete Device",
//             onPressed: _deleting ? null : () => _confirmDelete(context),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _row("Device Name", widget.device.deviceName),
//                 _row("Device Type", widget.device.deviceType),
//                 _row("Group", widget.device.groupName),
//                 _row(
//                   "Status",
//                   widget.device.status,
//                   valueColor: isOnline ? Colors.green : Colors.red,
//                 ),
//                 _row("Device ID", widget.device.deviceId),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _row(String label, String value, {Color? valueColor}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(color: valueColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===========================
//   // CONFIRM DELETE
//   // ===========================
//   void _confirmDelete(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete Device"),
//         content: const Text(
//           "Are you sure you want to delete this device? This action cannot be undone.",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteDevice(context);
//             },
//             child: const Text(
//               "Delete",
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===========================
//   // DELETE DEVICE API CALL
//   // ===========================
//   Future<void> _deleteDevice(BuildContext context) async {
//     final provider = context.read<DeviceProvider>();
//     final messenger = ScaffoldMessenger.of(context);

//     setState(() => _deleting = true);

//     try {
//       final response = await ApiService.post(
//         "/device/delete/${widget.device.deviceId}",{}
//       );

//       if (response.statusCode == 200 ||
//           response.statusCode == 204 ||
//           response.statusCode == 201) {
//         // ✅ Remove locally AFTER API success
//         provider.devices.removeWhere(
//           (d) => d.deviceId == widget.device.deviceId,
//         );
//         provider.notifyListeners();

//         messenger.showSnackBar(
//           const SnackBar(content: Text("Device deleted successfully")),
//         );

//         Navigator.pop(context); // back to device list
//       } else {
//         messenger.showSnackBar(
//           SnackBar(
//             content: Text(
//               "Failed to delete device (${response.statusCode})",
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       messenger.showSnackBar(
//         SnackBar(content: Text("Error deleting device: $e")),
//       );
//     } finally {
//       setState(() => _deleting = false);
//     }
//   }
// }

// <<<<<<<<<<<<<<<<<<<< NEW UPDATED UI>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms_app/services/api_service.dart';
import 'package:cms_app/theme/app_colors.dart';
import '../../models/device.dart';
import '../../providers/device_provider.dart';

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

// ─── Models ───────────────────────────────────────────────────────────────────

class DeviceDetailData {
  final DeviceKpis kpis;
  final List<DevicePerformance> performance;
  final List<NetworkDist> networkDistribution;
  final List<DeviceLog> logs;
  final List<DeviceTelemetry> telemetry;
  final List<DeviceEvent> events;
  final List<Map<String, dynamic>> chartdata;

  const DeviceDetailData({
    required this.kpis,
    required this.performance,
    required this.networkDistribution,
    required this.logs,
    required this.telemetry,
    required this.events,
    required this.chartdata,
  });

  factory DeviceDetailData.fromJson(Map<String, dynamic> j) => DeviceDetailData(
    kpis: DeviceKpis.fromJson((j['kpis'] as Map<String, dynamic>?) ?? {}),
    performance: ((j['performance'] as List?) ?? [])
        .map((e) => DevicePerformance.fromJson(e as Map<String, dynamic>))
        .toList(),
    networkDistribution: ((j['networkDistribution'] as List?) ?? [])
        .map((e) => NetworkDist.fromJson(e as Map<String, dynamic>))
        .toList(),
    logs: ((j['logs'] as List?) ?? [])
        .map((e) => DeviceLog.fromJson(e as Map<String, dynamic>))
        .toList(),
    telemetry: ((j['telemetry'] as List?) ?? [])
        .map((e) => DeviceTelemetry.fromJson(e as Map<String, dynamic>))
        .toList(),
    events: ((j['events'] as List?) ?? [])
        .map((e) => DeviceEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
    chartdata: ((j['chartdata'] as List?) ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList(),
  );
}

class DeviceKpis {
  final int totalPlays;
  final int avgCompletion;
  final int avgCpu;
  final double storageUsed;

  const DeviceKpis({
    required this.totalPlays,
    required this.avgCompletion,
    required this.avgCpu,
    required this.storageUsed,
  });

  factory DeviceKpis.fromJson(Map<String, dynamic> j) => DeviceKpis(
    totalPlays: _parseInt(j['totalPlays']),
    avgCompletion: _parseInt(j['avgCompletion']),
    avgCpu: _parseInt(j['avgCpu']),
    storageUsed: _parseDouble(j['storageUsed']),
  );
}

class DevicePerformance {
  final String date;
  final int plays, impressions, errors;

  const DevicePerformance({
    required this.date,
    required this.plays,
    required this.impressions,
    required this.errors,
  });

  factory DevicePerformance.fromJson(Map<String, dynamic> j) =>
      DevicePerformance(
        date: _str(j['date']),
        plays: _parseInt(j['plays']),
        impressions: _parseInt(j['impressions']),
        errors: _parseInt(j['errors']),
      );
}

class NetworkDist {
  final String name;
  final int value;

  const NetworkDist({required this.name, required this.value});

  factory NetworkDist.fromJson(Map<String, dynamic> j) =>
      NetworkDist(name: _str(j['name']), value: _parseInt(j['value']));
}

class DeviceLog {
  final String id, adName, adId, schedule;
  final double duration, completion;

  const DeviceLog({
    required this.id,
    required this.adName,
    required this.adId,
    required this.schedule,
    required this.duration,
    required this.completion,
  });

  factory DeviceLog.fromJson(Map<String, dynamic> j) => DeviceLog(
    id: _str(j['id']),
    adName: _str(j['ad_name'], 'Unknown Ad'),
    adId: _str(j['ad_id']),
    schedule: _str(j['schedule'], 'N/A'),
    duration: _parseDouble(j['duration']),
    completion: _parseDouble(j['completion']),
  );
}

class DeviceTelemetry {
  final String time, networkType;
  final double cpuUsage;
  final int ramFreeMb, storageFreeMb;

  const DeviceTelemetry({
    required this.time,
    required this.networkType,
    required this.cpuUsage,
    required this.ramFreeMb,
    required this.storageFreeMb,
  });

  factory DeviceTelemetry.fromJson(Map<String, dynamic> j) => DeviceTelemetry(
    time: _str(j['time']),
    networkType: _str(j['network_type'], 'UNKNOWN'),
    cpuUsage: _parseDouble(j['cpu_usage']),
    ramFreeMb: _parseInt(j['ram_free_mb']),
    storageFreeMb: _parseInt(j['storage_free_mb']),
  );
}

class DeviceEvent {
  final String id, timestamp, eventType;
  final Map<String, dynamic> payload;

  const DeviceEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.payload,
  });

  factory DeviceEvent.fromJson(Map<String, dynamic> j) => DeviceEvent(
    id: _str(j['id']),
    timestamp: _str(j['timestamp']),
    eventType: _str(j['event_type'], 'UNKNOWN'),
    payload: (j['payload'] as Map<String, dynamic>?) ?? {},
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

const _kLogsPerPage = 8;
const _kTelemetryPerPage = 10;
const _kEventsPerPage = 8;

class DeviceDetailsPage extends StatefulWidget {
  final Device device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  bool _loading = true;
  DeviceDetailData? _data;
  String? _error;
  bool _deleting = false;

  int _logPage = 0;
  int _telemetryPage = 0;
  int _eventPage = 0;

  String _preset = 'Last 30 Days';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _load();
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
      _telemetryPage = 0;
      _eventPage = 0;
    });
    try {
      final range = _getRange();
      final res = await ApiService.get(
        '/device/${widget.device.deviceId}/details'
        '?start_date=${_iso(range.start)}&end_date=${_iso(range.end)}',
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        if (mounted) setState(() => _data = DeviceDetailData.fromJson(json));
      } else {
        throw Exception('Server error ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: appColors.redLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: appColors.red,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Device',
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this device? This action cannot be undone.',
                style: TextStyle(color: appColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: appColors.textSecondary,
                        side: BorderSide(color: appColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteDevice(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: appColors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDevice(BuildContext context) async {
    final provider = context.read<DeviceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _deleting = true);
    try {
      final response = await ApiService.post(
        '/device/delete/${widget.device.deviceId}',
        {},
      );
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        provider.devices.removeWhere(
          (d) => d.deviceId == widget.device.deviceId,
        );
        provider.notifyListeners();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Device deleted successfully'),
            backgroundColor: appColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete device (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error deleting device: $e')),
      );
    } finally {
      setState(() => _deleting = false);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

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

  String _fmtTimestamp(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return iso;
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
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final p = d.hour < 12 ? 'AM' : 'PM';
    return '${m[d.month]} ${d.day}, ${d.year} · $h:$min $p';
  }

  Color _cpuColor(double cpu) {
    if (cpu >= 70) return appColors.red;
    if (cpu >= 50) return appColors.orange;
    return appColors.green;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isOnline =
        widget.device.status == 'online' || widget.device.status == 'active';

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
          'Device Details',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
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
            onPressed: _loading ? null : _load,
          ),
          IconButton(
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: appColors.redLight,
                shape: BoxShape.circle,
                border: Border.all(color: appColors.red.withOpacity(0.3)),
              ),
              child: _deleting
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: appColors.red,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.delete_rounded, color: appColors.red, size: 17),
            ),
            onPressed: _deleting ? null : () => _confirmDelete(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      body: _loading
          ? _loader()
          : _error != null
          ? _errorView()
          : RefreshIndicator(
              color: appColors.accent,
              backgroundColor: appColors.surface,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Device info hero ──
                    _deviceHeroCard(isOnline),
                    const SizedBox(height: 16),

                    // ── Date filter ──
                    _dateFilterRow(),
                    const SizedBox(height: 20),

                    // ── KPI grid ──
                    _kpiGrid(),
                    const SizedBox(height: 20),

                    // ── Performance ──
                    _sectionLabel('Performance Over Time'),
                    const SizedBox(height: 10),
                    _performanceChart(),
                    const SizedBox(height: 20),

                    // ── Network Distribution ──
                    _sectionLabel('Network Distribution'),
                    const SizedBox(height: 10),
                    _networkDistribution(),
                    const SizedBox(height: 20),

                    // ── Play Logs ──
                    _sectionLabel(
                      'Play Logs',
                      badge: _data!.logs.length.toString(),
                      badgeColor: appColors.accent,
                    ),
                    const SizedBox(height: 10),
                    _logsPaginated(),
                    const SizedBox(height: 20),

                    // ── Telemetry ──
                    _sectionLabel(
                      'Telemetry',
                      badge: _data!.telemetry.length.toString(),
                      badgeColor: appColors.teal,
                    ),
                    const SizedBox(height: 10),
                    _telemetrySection(),
                    const SizedBox(height: 20),

                    // ── Events ──
                    _sectionLabel(
                      'Events',
                      badge: _data!.events.length.toString(),
                      badgeColor: appColors.orange,
                    ),
                    const SizedBox(height: 10),
                    _eventsSection(),
                    const SizedBox(height: 20),

                    // ── Chart Data Summary ──
                    _sectionLabel('Event Chart Summary'),
                    const SizedBox(height: 10),
                    _chartDataSummary(),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Device Hero Card ──────────────────────────────────────────────────────

  Widget _deviceHeroCard(bool isOnline) => Container(
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
              Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isOnline ? appColors.greenLight : appColors.redLight)
                              .withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isOnline ? appColors.green : appColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.device.status.toUpperCase(),
                          style: TextStyle(
                            color: isOnline ? appColors.green : appColors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Type badge
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
                      widget.device.deviceType,
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
              Text(
                widget.device.deviceName,
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
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.group_rounded,
                    size: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.device.groupName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.tag_rounded,
                    size: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.device.deviceId,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
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

  Widget _kpiGrid() {
    final k = _data!.kpis;
    final items = [
      _KpiItem(
        icon: Icons.play_circle_rounded,
        label: 'Total Plays',
        value: k.totalPlays.toString(),
        color: appColors.accent,
        bg: appColors.accentLight,
      ),
      _KpiItem(
        icon: Icons.check_circle_rounded,
        label: 'Avg Completion',
        value: '${k.avgCompletion}%',
        color: appColors.green,
        bg: appColors.greenLight,
      ),
      _KpiItem(
        icon: Icons.memory_rounded,
        label: 'Avg CPU',
        value: '${k.avgCpu}%',
        color: appColors.orange,
        bg: appColors.orangeLight,
      ),
      _KpiItem(
        icon: Icons.storage_rounded,
        label: 'Storage Used',
        value: '${k.storageUsed.toStringAsFixed(1)} GB',
        color: appColors.purple,
        bg: appColors.purpleLight,
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

  Widget _performanceChart() {
    final data = _data!.performance;
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
              const SizedBox(width: 16),
              _Legend(color: appColors.red, label: 'Errors'),
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
                final errH = e.errors > 0 ? 8.0 : 4.0;
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
                            const SizedBox(width: 2),
                            _Bar(
                              height: errH,
                              color: appColors.red,
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

  // ─── Network Distribution ──────────────────────────────────────────────────

  Widget _networkDistribution() {
    final data = _data!.networkDistribution;
    if (data.isEmpty) return _emptyCard('No network data available');

    final colors = [
      appColors.accent,
      appColors.teal,
      appColors.purple,
      appColors.orange,
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
                    child: Icon(
                      e.name == 'WIFI'
                          ? Icons.wifi_rounded
                          : Icons.signal_wifi_off_rounded,
                      color: color,
                      size: 17,
                    ),
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
                              e.name,
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${e.value}%',
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
                            value: e.value / 100,
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

  // ─── Play Logs Paginated ───────────────────────────────────────────────────

  Widget _logsPaginated() {
    final logs = _data!.logs;
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
              final isComplete = log.completion >= 100;
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
                            Icons.play_circle_rounded,
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
                                log.adName,
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
                                    Icons.timer_rounded,
                                    size: 10,
                                    color: appColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${log.duration.toStringAsFixed(2)}s',
                                    style: TextStyle(
                                      color: appColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 10,
                                    color: appColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    log.schedule,
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
                                color: isComplete
                                    ? appColors.greenLight
                                    : appColors.orangeLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      (isComplete
                                              ? appColors.green
                                              : appColors.orange)
                                          .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${log.completion.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: isComplete
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

  // ─── Telemetry Section ─────────────────────────────────────────────────────

  Widget _telemetrySection() {
    final data = _data!.telemetry;
    if (data.isEmpty) return _emptyCard('No telemetry data available');

    final totalPages = (data.length / _kTelemetryPerPage).ceil();
    final slice = data
        .skip(_telemetryPage * _kTelemetryPerPage)
        .take(_kTelemetryPerPage)
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
              final t = entry.value;
              final isLast = i == slice.length - 1;
              final cpuColor = _cpuColor(t.cpuUsage);

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
                            color: appColors.tealLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.monitor_heart_rounded,
                            color: appColors.teal,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.time,
                                style: TextStyle(
                                  color: appColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _TelemetryChip(
                                    label:
                                        'CPU ${t.cpuUsage.toStringAsFixed(1)}%',
                                    color: cpuColor,
                                  ),
                                  _TelemetryChip(
                                    label: 'RAM ${t.ramFreeMb}MB',
                                    color: appColors.purple,
                                  ),
                                  _TelemetryChip(
                                    label: t.networkType,
                                    color: t.networkType == 'WIFI'
                                        ? appColors.green
                                        : appColors.textMuted,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${t.storageFreeMb}MB',
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: appColors.textMuted,
                              fontSize: 10,
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
                  enabled: _telemetryPage > 0,
                  onTap: () => setState(() => _telemetryPage--),
                ),
                Text(
                  'Page ${_telemetryPage + 1} of $totalPages',
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _pageBtn(
                  label: 'Next',
                  icon: Icons.chevron_right_rounded,
                  leading: false,
                  enabled: _telemetryPage < totalPages - 1,
                  onTap: () => setState(() => _telemetryPage++),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── Events Section ────────────────────────────────────────────────────────

  Widget _eventsSection() {
    final events = _data!.events;
    if (events.isEmpty) return _emptyCard('No events found');

    final totalPages = (events.length / _kEventsPerPage).ceil();
    final slice = events
        .skip(_eventPage * _kEventsPerPage)
        .take(_kEventsPerPage)
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
              final ev = entry.value;
              final isLast = i == slice.length - 1;
              final isDiagWarn = ev.eventType == 'DIAGNOSTIC_WARNING';
              final latencyMs = ev.payload['latencyMs'] as num?;
              final thresholdMs = ev.payload['thresholdMs'] as num?;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: appColors.orangeLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDiagWarn
                                ? Icons.warning_rounded
                                : Icons.error_rounded,
                            color: appColors.orange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatEventType(ev.eventType),
                                style: TextStyle(
                                  color: appColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _fmtTimestamp(ev.timestamp),
                                style: TextStyle(
                                  color: appColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              if (latencyMs != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _TelemetryChip(
                                      label: 'Latency: ${latencyMs}ms',
                                      color: appColors.orange,
                                    ),
                                    const SizedBox(width: 6),
                                    if (thresholdMs != null)
                                      _TelemetryChip(
                                        label: 'Threshold: ${thresholdMs}ms',
                                        color: appColors.textMuted,
                                      ),
                                  ],
                                ),
                              ],
                            ],
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
                  enabled: _eventPage > 0,
                  onTap: () => setState(() => _eventPage--),
                ),
                Text(
                  'Page ${_eventPage + 1} of $totalPages',
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _pageBtn(
                  label: 'Next',
                  icon: Icons.chevron_right_rounded,
                  leading: false,
                  enabled: _eventPage < totalPages - 1,
                  onTap: () => setState(() => _eventPage++),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatEventType(String t) => t
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (w) =>
            w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase(),
      )
      .join(' ');

  // ─── Chart Data Summary ────────────────────────────────────────────────────

  Widget _chartDataSummary() {
    final chartdata = _data!.chartdata;
    if (chartdata.isEmpty) return _emptyCard('No chart data available');

    // Sum up all event types across all time slots
    final keys = [
      'APP_CRASH',
      'CONTENT_DOWNLOAD_FAILED',
      'PLAYBACK_ERROR',
      'PLAYBACK_SKIPPED',
      'NETWORK_ERROR',
      'NETWORK_SLOW',
      'DIAGNOSTIC_WARNING',
      'DIAGNOSTIC_ERROR',
      'SETTINGS_CHANGED',
      'MEMORY_WARNING',
      'STORAGE_WARNING',
      'PERFORMANCE_ISSUE',
    ];

    final totals = <String, int>{};
    for (final key in keys) {
      int sum = 0;
      for (final row in chartdata) {
        sum += _parseInt(row[key]);
      }
      totals[key] = sum;
    }

    final colors = [
      appColors.red,
      appColors.orange,
      appColors.red,
      appColors.yellow,
      appColors.orange,
      appColors.teal,
      appColors.yellow,
      appColors.red,
      appColors.accent,
      appColors.purple,
      appColors.orange,
      appColors.teal,
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
        children: keys.asMap().entries.map((entry) {
          final i = entry.key;
          final key = entry.value;
          final count = totals[key] ?? 0;
          final color = colors[i % colors.length];
          final isLast = i == keys.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.event_note_rounded,
                        color: color,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatEventType(key),
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: count > 0
                            ? color.withOpacity(0.1)
                            : appColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: count > 0 ? color : appColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, thickness: 1, color: appColors.borderLight),
            ],
          );
        }).toList(),
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
          'Loading device details…',
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
            'Could not load device details',
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

class _TelemetryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TelemetryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
    ),
  );
}
