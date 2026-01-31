import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<ScheduleAd> schedules = [];
  bool loading = false;
  String? error;

  // 🔹 Default dates (used for reset)
  final String defaultFromDate = _today();
  final String defaultToDate = _today();

  // 🔹 Active filters
  late String fromDate = defaultFromDate;
  late String toDate = defaultToDate;

  static String _today() {
    final d = DateTime.now();
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  // 📥 Load schedules
  Future<void> loadSchedules() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final data = await ScheduleService.fetchSchedules(
        fromDate: fromDate,
        toDate: toDate,
      );

      schedules = data.map((e) => ScheduleAd.fromJson(e)).toList();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  // 📅 Update date filter
  void updateDateRange(String from, String to) {
    fromDate = from;
    toDate = to;
    loadSchedules();
  }

  // 🧹 Clear date filters (Devices-style)
  void resetDateRange() {
    fromDate = defaultFromDate;
    toDate = defaultToDate;
    loadSchedules();
  }
}
