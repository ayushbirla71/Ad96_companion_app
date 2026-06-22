import 'dart:convert';
import 'package:cms_app/services/api_service.dart';
import '../models/liveContent.dart';

class LiveContentService {
  /// FETCH ALL CONTENTS
  Future<List<LiveContent>> fetchLiveContents() async {
    final response = await ApiService.get("/live-content/all");

    print("api callllll");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      print("body >>>>>>>>>>>> $body");

      List data = body["data"] ?? [];

      return data.map((e) => LiveContent.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load live contents");
    }
  }

  /// CREATE CONTENT
  Future<LiveContent> createLiveContent({
    required String name,
    required String url,
    required int duration,
    required String type,
    required String status,
    String? channelId,
    DateTime? startTime,
    DateTime? endTime,
    bool autoplay = false,
    bool mute = false,
    bool loop = false,
  }) async {
    final response = await ApiService.post("/live-content/create", {
      "name": name,
      "url": url,
      "duration": duration,
      "content_type": type,
      "status": status,
      "channel_id": channelId,
      "start_time": startTime?.toIso8601String(),
      "end_time": endTime?.toIso8601String(),
      "config": {"autoplay": autoplay, "mute": mute, "loop": loop},
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);

      final data = body["data"];

      return LiveContent.fromJson(data);
    } else {
      print("errrrrrrrrrrrrrrrror  ${response.body}");
      throw Exception("Failed to create live content");
    }
  }

  /// DELETE CONTENT
  Future<void> deleteLiveContent(String id) async {
    final response = await ApiService.delete("/live-content/$id");

    if (response.statusCode != 200) {
      throw Exception("Failed to delete content");
    }
  }

  Future<void> deleteSchedules({
    required String contentId,
    required String contentType,
  }) async {
    try {
      final now = DateTime.now();

      final startDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final endDate = startDate;

      final response = await ApiService.post("/schedule/live/multiple-delete", {
        "contentId": contentId,

        // "contentType": "live_content",
        "contentType": contentType,
        "startDate": startDate,
        "endDate": endDate,
      });

      if (response.statusCode != 200) {
        throw Exception("Failed to delete content");
      }
    } catch (e) {
      print("❌ Delete schedules error: $e");
      rethrow;
    }
  }
}
