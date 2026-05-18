import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  /// DATA
  List<ScheduleAd> ads = [];
  List<ScheduleAd> liveContents = [];
  List<ScheduleAd> carousels = [];
  List<ScheduleAd> layouts = [];

  bool loading = false;
  String? error;

  /// DEFAULT DATE
  final String defaultFromDate = _today();
  final String defaultToDate = _today();

  /// ACTIVE FILTER
  late String fromDate = defaultFromDate;
  late String toDate = defaultToDate;

  static String _today() {
    final d = DateTime.now();
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  /// LOAD SCHEDULES
  Future<void> loadSchedules() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ScheduleService.fetchSchedules(
        fromDate: fromDate,
        toDate: toDate,
      );

      print("response $response");

      /// ADS
      ads = (response["ads"] ?? [])
          .map<ScheduleAd>((e) => ScheduleAd.fromJson(e))
          .toList();

      /// LIVE CONTENT
      liveContents = (response["live_contents"] ?? [])
          .map<ScheduleAd>((e) => ScheduleAd.fromJson(e))
          .toList();

      /// CAROUSELS
      carousels = (response["carousels"] ?? [])
          .map<ScheduleAd>((e) => ScheduleAd.fromJson(e))
          .toList();

      layouts = (response["layouts"] ?? [])
          .map<ScheduleAd>((e) => ScheduleAd.fromJson(e))
          .toList();

      print("layouts raw => ${response["layouts"]}");
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  /// UPDATE DATE RANGE
  void updateDateRange(String from, String to) {
    fromDate = from;
    toDate = to;
    loadSchedules();
  }

  /// RESET FILTER
  void resetDateRange() {
    fromDate = defaultFromDate;
    toDate = defaultToDate;
    loadSchedules();
  }
}
