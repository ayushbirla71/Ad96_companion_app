import 'dart:convert';
import 'package:cms_app/theme/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:cms_app/theme/app_colors.dart';

// ─── Safe parsers ─────────────────────────────────────────────────────────────

int _parseInt(dynamic v, [int fb = 0]) {
  if (v == null) return fb;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fb;
  return fb;
}

bool _parseBool(dynamic v, [bool fb = false]) {
  if (v == null) return fb;
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  return fb;
}

String _str(dynamic v, [String fb = '']) {
  if (v == null) return fb;
  if (v is String) return v.trim().isEmpty ? fb : v;
  return v.toString();
}

DateTime _date(dynamic v) => DateTime.tryParse(_str(v)) ?? DateTime.now();

// ─── Models ───────────────────────────────────────────────────────────────────

class DeviceGroupDetail {
  final String groupId, name, orientation, regCode;
  final int maxDaysSchedules, deviceCount;
  final bool rcsEnabled, placeholderEnabled, logoEnabled;
  final DateTime lastPushed, createdAt;
  final ScrollTextInfo? scrollText;
  final List<GroupDevice> devices;

  const DeviceGroupDetail({
    required this.groupId,
    required this.name,
    required this.orientation,
    required this.regCode,
    required this.maxDaysSchedules,
    required this.deviceCount,
    required this.rcsEnabled,
    required this.placeholderEnabled,
    required this.logoEnabled,
    required this.lastPushed,
    required this.createdAt,
    this.scrollText,
    required this.devices,
  });

  factory DeviceGroupDetail.fromJson(Map<String, dynamic> j) {
    final d = (j['data'] as Map<String, dynamic>?) ?? j;
    return DeviceGroupDetail(
      groupId: _str(d['group_id']),
      name: _str(d['name'], 'Unknown Group'),
      orientation: _str(d['orientation'], 'landscape'),
      regCode: _str(d['reg_code']),
      maxDaysSchedules: _parseInt(d['max_days_schedules']),
      deviceCount: _parseInt(d['device_count']),
      rcsEnabled: _parseBool(d['rcs_enabled']),
      placeholderEnabled: _parseBool(d['placeholder_enabled']),
      logoEnabled: _parseBool(d['logo_enabled']),
      lastPushed: _date(d['last_pushed']),
      createdAt: _date(d['created_at']),
      scrollText: d['ScrollText'] != null
          ? ScrollTextInfo.fromJson(d['ScrollText'] as Map<String, dynamic>)
          : null,
      devices: ((d['Devices'] as List?) ?? [])
          .map((e) => GroupDevice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ScrollTextInfo {
  final String id, message;
  const ScrollTextInfo({required this.id, required this.message});
  factory ScrollTextInfo.fromJson(Map<String, dynamic> j) =>
      ScrollTextInfo(id: _str(j['scrolltext_id']), message: _str(j['message']));
}

class GroupDevice {
  final String deviceId, deviceName, deviceType, deviceModel, deviceOs;
  final String deviceOsVersion, deviceOrientation, deviceResolution;
  final String androidId, location, status, registrationStatus;
  final int maxVideoStreams;
  final List<String> tags;
  final DateTime lastSynced, createdAt;
  final String deviceOnTime, deviceOffTime;

  const GroupDevice({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.deviceModel,
    required this.deviceOs,
    required this.deviceOsVersion,
    required this.deviceOrientation,
    required this.deviceResolution,
    required this.androidId,
    required this.location,
    required this.status,
    required this.registrationStatus,
    required this.maxVideoStreams,
    required this.tags,
    required this.lastSynced,
    required this.createdAt,
    required this.deviceOnTime,
    required this.deviceOffTime,
  });

  factory GroupDevice.fromJson(Map<String, dynamic> j) => GroupDevice(
    deviceId: _str(j['device_id']),
    deviceName: _str(j['device_name'], 'Unknown Device'),
    deviceType: _str(j['device_type'], 'unknown'),
    deviceModel: _str(j['device_model'], '—'),
    deviceOs: _str(j['device_os'], 'android'),
    deviceOsVersion: _str(j['device_os_version'], '—'),
    deviceOrientation: _str(j['device_orientation'], 'landscape'),
    deviceResolution: _str(j['device_resolution'], '—'),
    androidId: _str(j['android_id'], '—'),
    location: _str(j['location']),
    status: _str(j['status'], 'unknown'),
    registrationStatus: _str(j['registration_status'], 'unknown'),
    maxVideoStreams: _parseInt(j['max_supported_video_streams']),
    tags: ((j['tags'] as List?) ?? []).map((e) => e.toString()).toList(),
    lastSynced: _date(j['last_synced']),
    createdAt: _date(j['created_at']),
    deviceOnTime: _str(j['device_on_time'], '—'),
    deviceOffTime: _str(j['device_off_time'], '—'),
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class DeviceGroupDetailsPage extends StatefulWidget {
  final dynamic group;
  const DeviceGroupDetailsPage({super.key, required this.group});

  @override
  State<DeviceGroupDetailsPage> createState() => _DeviceGroupDetailsPageState();
}

class _DeviceGroupDetailsPageState extends State<DeviceGroupDetailsPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  DeviceGroupDetail? _detail;
  String? _error;

  // ─── Edit state ────────────────────────────────────────────────────────────
  bool _editFeatures = false;
  bool _editScrollText = false;
  bool _savingFeatures = false;
  bool _savingScrollText = false;

  // Editable copies of toggles
  late bool _rcsEnabled;
  late bool _placeholderEnabled;
  late bool _logoEnabled;

  // Scroll text controller
  final _messageCtrl = TextEditingController();

  // ─── Filter state ──────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _filterStatus = 'All';
  String _filterRegistration = 'All';
  String _filterType = 'All';
  String _filterOrientation = 'All';
  String _filterStreams = 'All';

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
    _searchCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  // ─── API ───────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.get(
        '/device/fetch-group-details/${widget.group.id}',
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        if (mounted) {
          final detail = DeviceGroupDetail.fromJson(json);
          setState(() {
            _detail = detail;
            // Sync editable state from fresh data
            _rcsEnabled = detail.rcsEnabled;
            _placeholderEnabled = detail.placeholderEnabled;
            _logoEnabled = detail.logoEnabled;
            _messageCtrl.text = detail.scrollText?.message ?? '';
            // Reset edit modes on reload
            _editFeatures = false;
            _editScrollText = false;
          });
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

  Future<void> _refreshGroup() async {
    try {
      setState(() => _loading = true);
      await ApiService.post('/device/update-schedule/${widget.group.id}', {});
      _snack('Group refresh triggered. Devices will sync shortly.');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateFeatures() async {
    setState(() => _savingFeatures = true);
    try {
      final res =
          await ApiService.put('/device/update-group/${widget.group.id}', {
            'name': _detail!.name,
            'rcs_enabled': _rcsEnabled,
            'placeholder_enabled': _placeholderEnabled,
            'logo_enabled': _logoEnabled,
          });
      if (res.statusCode == 200 || res.statusCode == 201) {
        await _load();
        _snack('Group features updated successfully');
      } else {
        _snack('Failed to update features (${res.statusCode})');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _savingFeatures = false);
    }
  }

  Future<void> _updateScrollText() async {
    setState(() => _savingScrollText = true);
    try {
      await ApiService.post('/scroll-text', {
        'group_id': widget.group.id,
        'message': _messageCtrl.text.trim(),
      });
      setState(() => _editScrollText = false);
      _snack('Scroll text updated successfully');
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _savingScrollText = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: appColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Filtered devices ──────────────────────────────────────────────────────

  List<GroupDevice> get _filtered {
    final devices = _detail?.devices ?? [];
    return devices.where((d) {
      final q = _search.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          d.deviceName.toLowerCase().contains(q) ||
          d.deviceId.toLowerCase().contains(q) ||
          d.androidId.toLowerCase().contains(q);
      final matchStatus =
          _filterStatus == 'All' ||
          d.status.toLowerCase() == _filterStatus.toLowerCase();
      final matchReg =
          _filterRegistration == 'All' ||
          d.registrationStatus.toLowerCase() ==
              _filterRegistration.toLowerCase();
      final matchType =
          _filterType == 'All' ||
          d.deviceType.toLowerCase() == _filterType.toLowerCase();
      final matchOrientation =
          _filterOrientation == 'All' ||
          d.deviceOrientation.toLowerCase() == _filterOrientation.toLowerCase();
      final matchStreams =
          _filterStreams == 'All' ||
          d.maxVideoStreams.toString() == _filterStreams;
      return matchSearch &&
          matchStatus &&
          matchReg &&
          matchType &&
          matchOrientation &&
          matchStreams;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _filterStatus != 'All' ||
      _filterRegistration != 'All' ||
      _filterType != 'All' ||
      _filterOrientation != 'All' ||
      _filterStreams != 'All';

  void _clearFilters() => setState(() {
    _filterStatus = 'All';
    _filterRegistration = 'All';
    _filterType = 'All';
    _filterOrientation = 'All';
    _filterStreams = 'All';
  });

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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'active':
        return appColors.green;
      case 'inactive':
        return appColors.red;
      case 'maintenance':
        return appColors.orange;
      default:
        return appColors.textMuted;
    }
  }

  Color _statusBg(String s) {
    switch (s.toLowerCase()) {
      case 'active':
        return appColors.greenLight;
      case 'inactive':
        return appColors.redLight;
      case 'maintenance':
        return appColors.orangeLight;
      default:
        return appColors.surfaceHigh;
    }
  }

  Color _regColor(String s) {
    switch (s.toLowerCase()) {
      case 'registered':
        return appColors.green;
      case 'pairing':
        return appColors.yellow;
      case 'pending':
        return appColors.orange;
      default:
        return appColors.textMuted;
    }
  }

  Color _regBg(String s) {
    switch (s.toLowerCase()) {
      case 'registered':
        return appColors.greenLight;
      case 'pairing':
        return appColors.yellowLight;
      case 'pending':
        return appColors.orangeLight;
      default:
        return appColors.surfaceHigh;
    }
  }

  IconData _deviceIcon(String type) {
    switch (type.toLowerCase()) {
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

  IconData _orientationIcon(String o) => o.toLowerCase() == 'portrait'
      ? Icons.stay_current_portrait_rounded
      : Icons.stay_current_landscape_rounded;

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.bg,
      appBar: AppBar(
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: Container(
        //     width: 34,
        //     height: 34,
        //     decoration: BoxDecoration(
        //       color: appColors.surfaceHigh,
        //       shape: BoxShape.circle,
        //       border: Border.all(color: appColors.border),
        //     ),
        //     child: Icon(
        //       Icons.arrow_back_ios_new_rounded,
        //       color: appColors.textSecondary,
        //       size: 15,
        //     ),
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          'Group Details',
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
            onPressed: _loading ? null : _refreshGroup,
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
            _heroCard(d),
            const SizedBox(height: 16),

            // ── Features (editable) ──
            _featureSection(d),
            const SizedBox(height: 20),

            // ── Scroll Text (editable) ──
            _scrollTextSection(d),
            const SizedBox(height: 20),

            // ── Devices ──
            _sectionLabel(
              'Devices',
              badge: d.devices.length.toString(),
              badgeColor: appColors.accent,
            ),
            const SizedBox(height: 10),
            _searchBar(),
            const SizedBox(height: 10),
            _filterChipsRow(d),
            const SizedBox(height: 10),
            _devicesList(),
          ],
        ),
      ),
    );
  }

  // ─── Features Section ──────────────────────────────────────────────────────

  Widget _featureSection(DeviceGroupDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with Edit/Cancel
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Group Features'),
            _editToggleBtn(
              editing: _editFeatures,
              onTap: () {
                setState(() {
                  if (_editFeatures) {
                    // Cancel — revert to loaded values
                    _rcsEnabled = d.rcsEnabled;
                    _placeholderEnabled = d.placeholderEnabled;
                    _logoEnabled = d.logoEnabled;
                  }
                  _editFeatures = !_editFeatures;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Toggles card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _editFeatures
                  ? appColors.accent.withOpacity(0.35)
                  : appColors.border,
              width: _editFeatures ? 1.5 : 1,
            ),
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
              _ToggleRow(
                icon: Icons.smart_display_rounded,
                iconColor: appColors.accent,
                iconBg: appColors.accentLight,
                label: 'RCS Enabled',
                subtitle: 'Rich Communication Services',
                value: _rcsEnabled,
                enabled: _editFeatures,
                onChanged: (v) => setState(() => _rcsEnabled = v),
              ),
              _featureDivider(),
              _ToggleRow(
                icon: Icons.image_rounded,
                iconColor: appColors.purple,
                iconBg: appColors.purpleLight,
                label: 'Placeholder Enabled',
                subtitle: 'Show placeholder content',
                value: _placeholderEnabled,
                enabled: _editFeatures,
                onChanged: (v) => setState(() => _placeholderEnabled = v),
              ),
              _featureDivider(),
              _ToggleRow(
                icon: Icons.verified_rounded,
                iconColor: appColors.teal,
                iconBg: appColors.tealLight,
                label: 'Logo Enabled',
                subtitle: 'Display group logo',
                value: _logoEnabled,
                enabled: _editFeatures,
                onChanged: (v) => setState(() => _logoEnabled = v),
              ),
            ],
          ),
        ),

        // Save button — only when editing
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _editFeatures
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _savingFeatures ? null : _updateFeatures,
                      icon: _savingFeatures
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save_rounded, size: 16),
                      label: Text(
                        _savingFeatures ? 'Saving…' : 'Update Features',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: appColors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: appColors.accent.withOpacity(
                          0.6,
                        ),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _featureDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Divider(height: 16, thickness: 1, color: appColors.borderLight),
  );

  // ─── Scroll Text Section ───────────────────────────────────────────────────

  Widget _scrollTextSection(DeviceGroupDetail d) {
    // Always show the section (even if scrollText is null — user may want to add one)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Scroll Text'),
            Row(
              children: [
                /// DELETE BUTTON
                if (d.scrollText != null)
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => Dialog(
                          backgroundColor: Colors.transparent,

                          child: Container(
                            padding: const EdgeInsets.all(22),

                            decoration: BoxDecoration(
                              color: appColors.surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: appColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),

                            child: Column(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                /// ICON
                                Container(
                                  width: 58,
                                  height: 58,

                                  decoration: BoxDecoration(
                                    color: appColors.redLight,
                                    shape: BoxShape.circle,
                                  ),

                                  child: Icon(
                                    Icons.delete_rounded,
                                    color: appColors.red,
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                /// TITLE
                                Text(
                                  'Delete Scroll Text',
                                  style: TextStyle(
                                    color: appColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// MESSAGE
                                Text(
                                  'Are you sure you want to delete this scroll text?\nThis action cannot be undone.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: appColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                /// BUTTONS
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, false),

                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              appColors.textSecondary,

                                          side: BorderSide(
                                            color: appColors.border,
                                          ),

                                          padding: const EdgeInsets.symmetric(
                                            vertical: 13,
                                          ),

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),

                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, true),

                                        style: FilledButton.styleFrom(
                                          backgroundColor: appColors.red,
                                          foregroundColor: Colors.white,

                                          padding: const EdgeInsets.symmetric(
                                            vertical: 13,
                                          ),

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),

                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
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

                      if (confirm == true) {
                        try {
                          await ApiService.post(
                            '/scroll-text/delete/${widget.group.id}',
                            {},
                          );

                          _snack('Scroll text deleted successfully');

                          await _load();
                        } catch (e) {
                          _snack('Failed to delete scroll text');
                        }
                      }
                    },

                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 34,
                      height: 34,

                      decoration: BoxDecoration(
                        color: appColors.redLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.red.withOpacity(0.3),
                        ),
                      ),

                      child: Icon(
                        Icons.delete_rounded,
                        color: appColors.red,
                        size: 17,
                      ),
                    ),
                  ),
                _editToggleBtn(
                  editing: _editScrollText,
                  onTap: () {
                    setState(() {
                      if (_editScrollText) {
                        // Cancel — revert
                        _messageCtrl.text = d.scrollText?.message ?? '';
                      }
                      _editScrollText = !_editScrollText;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _editScrollText
                  ? appColors.accent.withOpacity(0.35)
                  : appColors.border,
              width: _editScrollText ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: appColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _editScrollText
              ? TextField(
                  controller: _messageCtrl,
                  maxLines: 3,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter scroll text message…',
                    hintStyle: TextStyle(
                      color: appColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                        right: 10,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appColors.tealLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.text_fields_rounded,
                          color: appColors.teal,
                          size: 18,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    filled: true,
                    fillColor: appColors.surfaceHigh,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: appColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: appColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: appColors.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: appColors.tealLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.text_fields_rounded,
                        color: appColors.teal,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          d.scrollText != null &&
                              d.scrollText!.message.isNotEmpty
                          ? Text(
                              d.scrollText!.message,
                              style: TextStyle(
                                color: appColors.textSecondary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            )
                          : Text(
                              'No scroll text set. Tap Edit to add one.',
                              style: TextStyle(
                                color: appColors.textMuted,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ],
                ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _editScrollText
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _savingScrollText ? null : _updateScrollText,
                      icon: _savingScrollText
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.message_rounded, size: 16),
                      label: Text(
                        _savingScrollText ? 'Saving…' : 'Update Message',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: appColors.teal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: appColors.teal.withOpacity(
                          0.6,
                        ),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ─── Edit Toggle Button ────────────────────────────────────────────────────

  Widget _editToggleBtn({required bool editing, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: editing ? appColors.redLight : appColors.accentLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: editing
                  ? appColors.red.withOpacity(0.3)
                  : appColors.accent.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                editing ? Icons.close_rounded : Icons.edit_rounded,
                size: 13,
                color: editing ? appColors.red : appColors.accent,
              ),
              const SizedBox(width: 5),
              Text(
                editing ? 'Cancel' : 'Edit',
                style: TextStyle(
                  color: editing ? appColors.red : appColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );

  // ─── Hero Card ─────────────────────────────────────────────────────────────

  Widget _heroCard(DeviceGroupDetail d) => Container(
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
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          left: -15,
          bottom: -35,
          child: Container(
            width: 90,
            height: 90,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _orientationIcon(d.orientation),
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          d.orientation[0].toUpperCase() +
                              d.orientation.substring(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.vpn_key_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 11,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          d.regCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                d.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _HeroBadge(
                    icon: Icons.devices_rounded,
                    label:
                        '${d.deviceCount} device${d.deviceCount != 1 ? 's' : ''}',
                  ),
                  const SizedBox(width: 8),
                  _HeroBadge(
                    icon: Icons.calendar_today_rounded,
                    label: '${d.maxDaysSchedules}d schedule',
                  ),
                  const SizedBox(width: 8),
                  _HeroBadge(
                    icon: Icons.update_rounded,
                    label: _timeAgo(d.lastPushed),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Created ${_fmtDate(d.createdAt)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── Search Bar ────────────────────────────────────────────────────────────

  Widget _searchBar() => Container(
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
        hintText: 'Search by device name, ID, or Android ID...',
        hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
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
                },
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
      ),
      onChanged: (v) => setState(() => _search = v),
    ),
  );

  // ─── Filter Chips Row ──────────────────────────────────────────────────────

  Widget _filterChipsRow(DeviceGroupDetail d) {
    final statuses = [
      'All',
      ...{...d.devices.map((e) => _capitalize(e.status))},
    ];
    final regs = [
      'All',
      ...{...d.devices.map((e) => _capitalize(e.registrationStatus))},
    ];
    final types = [
      'All',
      ...{...d.devices.map((e) => _capitalize(e.deviceType))},
    ];
    final orientations = [
      'All',
      ...{...d.devices.map((e) => _capitalize(e.deviceOrientation))},
    ];
    final streams = [
      'All',
      ...{...d.devices.map((e) => e.maxVideoStreams.toString())},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterDropChip(
                label: 'Status',
                selected: _filterStatus,
                options: statuses,
                onSelected: (v) => setState(() => _filterStatus = v),
              ),
              const SizedBox(width: 8),
              _FilterDropChip(
                label: 'Registration',
                selected: _filterRegistration,
                options: regs,
                onSelected: (v) => setState(() => _filterRegistration = v),
              ),
              const SizedBox(width: 8),
              _FilterDropChip(
                label: 'Type',
                selected: _filterType,
                options: types,
                onSelected: (v) => setState(() => _filterType = v),
              ),
              const SizedBox(width: 8),
              _FilterDropChip(
                label: 'Orientation',
                selected: _filterOrientation,
                options: orientations,
                onSelected: (v) => setState(() => _filterOrientation = v),
              ),
              const SizedBox(width: 8),
              _FilterDropChip(
                label: 'Streams',
                selected: _filterStreams,
                options: streams,
                onSelected: (v) => setState(() => _filterStreams = v),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _clearFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.redLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: appColors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: appColors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Clear',
                          style: TextStyle(
                            color: appColors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_search.isNotEmpty || _hasActiveFilters) ...[
          const SizedBox(height: 8),
          Text(
            '${_filtered.length} of ${_detail!.devices.length} devices',
            style: TextStyle(
              color: appColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ─── Devices List ──────────────────────────────────────────────────────────

  Widget _devicesList() {
    final devices = _filtered;
    if (devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: appColors.border),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.devices_other_rounded,
                color: appColors.textMuted,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                'No devices match your filters',
                style: TextStyle(color: appColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
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
        children: devices.asMap().entries.map((entry) {
          final i = entry.key;
          final dev = entry.value;
          final isLast = i == devices.length - 1;
          return Column(
            children: [
              _DeviceTile(
                device: dev,
                statusColor: _statusColor(dev.status),
                statusBg: _statusBg(dev.status),
                regColor: _regColor(dev.registrationStatus),
                regBg: _regBg(dev.registrationStatus),
                deviceIcon: _deviceIcon(dev.deviceType),
                orientationIcon: _orientationIcon(dev.deviceOrientation),
                timeAgo: _timeAgo(dev.lastSynced),
                fmtDate: _fmtDate,
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
    );
  }

  // ─── Section Label ─────────────────────────────────────────────────────────

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

  // ─── Loader / Error ────────────────────────────────────────────────────────

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
          'Loading group details…',
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
            'Could not load group',
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

// ─── Toggle Row ───────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, subtitle;
  final bool value, enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: appColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: iconColor,
            activeTrackColor: iconColor.withOpacity(0.2),
            inactiveThumbColor: appColors.textMuted,
            inactiveTrackColor: appColors.borderLight,
          ),
        ],
      ),
    );
  }
}

// ─── Hero Badge ───────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 11),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─── Filter Drop Chip ─────────────────────────────────────────────────────────

class _FilterDropChip extends StatelessWidget {
  final String label, selected;
  final List<String> options;
  final ValueChanged<String> onSelected;
  const _FilterDropChip({
    required this.label,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected != 'All';
    return GestureDetector(
      onTap: () async {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);
        final result = await showMenu<String>(
          context: context,
          color: appColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: appColors.border),
          ),
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + box.size.height + 4,
            offset.dx + box.size.width,
            0,
          ),
          items: options
              .map(
                (o) => PopupMenuItem<String>(
                  value: o,
                  height: 40,
                  child: Row(
                    children: [
                      if (selected == o)
                        Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: appColors.accent,
                        )
                      else
                        const SizedBox(width: 14),
                      const SizedBox(width: 8),
                      Text(
                        o,
                        style: TextStyle(
                          color: selected == o
                              ? appColors.accent
                              : appColors.textPrimary,
                          fontSize: 13,
                          fontWeight: selected == o
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
        if (result != null) onSelected(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? appColors.accentLight : appColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? appColors.accent.withOpacity(0.4)
                : appColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 13,
              color: isActive ? appColors.accent : appColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              isActive ? selected : label,
              style: TextStyle(
                color: isActive ? appColors.accent : appColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isActive ? appColors.accent : appColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Device Tile ──────────────────────────────────────────────────────────────

class _DeviceTile extends StatefulWidget {
  final GroupDevice device;
  final Color statusColor, statusBg, regColor, regBg;
  final IconData deviceIcon, orientationIcon;
  final String timeAgo;
  final String Function(DateTime) fmtDate;

  const _DeviceTile({
    required this.device,
    required this.statusColor,
    required this.statusBg,
    required this.regColor,
    required this.regBg,
    required this.deviceIcon,
    required this.orientationIcon,
    required this.timeAgo,
    required this.fmtDate,
  });

  @override
  State<_DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<_DeviceTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.device;
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: appColors.accentLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    widget.deviceIcon,
                    color: appColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.deviceName,
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        d.deviceModel,
                        style: TextStyle(
                          color: appColors.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusPill(
                            label: d.status,
                            color: widget.statusColor,
                            bg: widget.statusBg,
                          ),
                          const SizedBox(width: 6),
                          _StatusPill(
                            label: d.registrationStatus,
                            color: widget.regColor,
                            bg: widget.regBg,
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
                    Text(
                      widget.timeAgo,
                      style: TextStyle(
                        color: appColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: appColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: _expanded
              ? Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: appColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: appColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.tag_rounded,
                        label: 'Device ID',
                        value: d.deviceId,
                      ),
                      _DetailRow(
                        icon: Icons.android_rounded,
                        label: 'Android ID',
                        value: d.androidId,
                      ),
                      _DetailRow(
                        icon: Icons.system_update_rounded,
                        label: 'OS',
                        value:
                            '${d.deviceOs.toUpperCase()} ${d.deviceOsVersion}',
                      ),
                      _DetailRow(
                        icon: Icons.aspect_ratio_rounded,
                        label: 'Resolution',
                        value: d.deviceResolution,
                      ),
                      _DetailRow(
                        icon: widget.orientationIcon,
                        label: 'Orientation',
                        value:
                            d.deviceOrientation[0].toUpperCase() +
                            d.deviceOrientation.substring(1),
                      ),
                      _DetailRow(
                        icon: Icons.play_circle_outline_rounded,
                        label: 'Max Streams',
                        value: d.maxVideoStreams.toString(),
                      ),
                      _DetailRow(
                        icon: Icons.location_on_rounded,
                        label: 'Location',
                        value: d.location,
                      ),
                      _DetailRow(
                        icon: Icons.wb_sunny_rounded,
                        label: 'On Time',
                        value: d.deviceOnTime,
                      ),
                      _DetailRow(
                        icon: Icons.nightlight_round,
                        label: 'Off Time',
                        value: d.deviceOffTime,
                      ),
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Registered',
                        value: widget.fmtDate(d.createdAt),
                        isLast: d.tags.isEmpty,
                      ),
                      if (d.tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.label_rounded,
                              size: 14,
                              color: appColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: d.tags
                                    .map(
                                      (t) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: appColors.accentLight,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: appColors.accent.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          t,
                                          style: TextStyle(
                                            color: appColors.accent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Status Pill ──────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _StatusPill({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}

// ─── Detail Row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isLast;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Icon(icon, size: 13, color: appColors.textMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: appColors.textMuted, fontSize: 11),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      if (!isLast) ...[
        const SizedBox(height: 8),
        Divider(height: 1, thickness: 1, color: appColors.borderLight),
        const SizedBox(height: 8),
      ],
    ],
  );
}
