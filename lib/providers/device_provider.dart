import 'dart:async';

import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../services/fcm_service.dart';

class DeviceProvider extends ChangeNotifier {
  List<Device> _devices = [];

  // Polls /device/all while a delete awaits confirmation from the screen.
  Timer? _deletePollTimer;
  static const _deletePollInterval = Duration(seconds: 5);

  DeviceProvider() {
    FCMService.onSyncEvent.addListener(_onPushEvent);
  }

  @override
  void dispose() {
    FCMService.onSyncEvent.removeListener(_onPushEvent);
    _deletePollTimer?.cancel();
    super.dispose();
  }

  // The backend pushes DEVICE_EXIT_CONFIRMED / DEVICE_EXIT_TIMEOUT when a delete resolves.
  void _onPushEvent() {
    final type = FCMService.lastSyncMessage?.data['type'];
    if (type == 'DEVICE_EXIT_CONFIRMED' || type == 'DEVICE_EXIT_TIMEOUT') {
      refreshQuietly();
    }
  }

  void _syncDeletePolling() {
    final anyDeleting = _devices.any((d) => d.isDeleting);
    if (anyDeleting && _deletePollTimer == null) {
      _deletePollTimer = Timer.periodic(_deletePollInterval, (_) => refreshQuietly());
    } else if (!anyDeleting && _deletePollTimer != null) {
      _deletePollTimer!.cancel();
      _deletePollTimer = null;
    }
  }

  /// Refetch without toggling [loading], so lists don't flash a spinner.
  Future<void> refreshQuietly() async {
    try {
      final data = await DeviceService.fetchDevices();
      _devices = data.map((e) => Device.fromJson(e)).toList();
      error = null;
      notifyListeners();
    } catch (_) {
      // Keep the last known list; the next poll or a manual refresh retries.
    }
    _syncDeletePolling();
  }

  /// Each returns null on success or an error message, then refreshes the list.
  Future<String?> requestDelete(String deviceId) =>
      _runDeleteAction(() => DeviceService.requestDelete(deviceId));

  Future<String?> retryDelete(String deviceId) =>
      _runDeleteAction(() => DeviceService.retryDelete(deviceId));

  Future<String?> forceDelete(String deviceId) =>
      _runDeleteAction(() => DeviceService.forceDelete(deviceId));

  Future<String?> _runDeleteAction(Future<String?> Function() action) async {
    final message = await action();
    // Refresh even on failure: the server may have recorded a failed attempt.
    await refreshQuietly();
    return message;
  }

  bool loading = false;
  String? error;

  // 🔍 Filters
  String searchText = '';
  String statusFilter = 'all'; // all | online | offline | active
  String groupFilter = 'all';  // group id or all

  List<Device> get devices => _devices;

  // ✅ FINAL FILTERED LIST
  List<Device> get filteredDevices {
    return _devices.where((d) {
      final matchesSearch = d.deviceName
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchesStatus =
          statusFilter == 'all' || d.status == statusFilter;

      final matchesGroup =
          groupFilter == 'all' || d.groupId == groupFilter;

      return matchesSearch && matchesStatus && matchesGroup;
    }).toList();
  }

  // 📡 LOAD DEVICES
  Future<void> loadDevices() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final data = await DeviceService.fetchDevices();
      _devices = data.map((e) => Device.fromJson(e)).toList();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
    _syncDeletePolling();
  }

  // 🔍 SEARCH
  void setSearch(String value) {
    searchText = value;
    notifyListeners();
  }

  // 🔽 STATUS FILTER
  void setStatusFilter(String value) {
    statusFilter = value;
    notifyListeners();
  }

  // 🗂 GROUP FILTER
  void setGroupFilter(String value) {
    groupFilter = value;
    notifyListeners();
  }

  // 🧹 CLEAR FILTERS (USED BY UI)
  void clearFilters() {
    searchText = '';
    statusFilter = 'all';
    groupFilter = 'all';
    notifyListeners();
  }

  // 🔄 OPTIONAL: SET DEVICES MANUALLY (future use)
  void setDevices(List<Device> devices) {
    _devices = devices;
    notifyListeners();
  }
}
