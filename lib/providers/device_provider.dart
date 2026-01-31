import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/device_service.dart';

class DeviceProvider extends ChangeNotifier {
  List<Device> _devices = [];

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
