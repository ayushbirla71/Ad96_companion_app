import 'dart:convert';
import '../services/api_service.dart';

class ScheduleService {
  static Future<List<dynamic>> fetchSchedules({
    required String fromDate,
    required String toDate,
  }) async {
    final response = await ApiService.get(
      "/schedule/all_v2?from=$fromDate&to=$toDate",
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["ads"] ?? [];
    } else {
      throw Exception("Failed to load schedules");
    }
  }
}
