import 'package:cms_app/services/api_service.dart';

class LiveContent {
  final String id;
  final String name;
  final String channel_id;
  final String type;
  final String url;
  final int duration;
  final String status;
  final DateTime createdAt;

  LiveContent({
    required this.id,
    required this.name,
    required this.channel_id,
    required this.type,
    required this.url,
    required this.duration,
    required this.status,
    required this.createdAt,
  });

  factory LiveContent.fromJson(Map<String, dynamic> json) {
    return LiveContent(
      id: json["live_content_id"],
      name: json["name"] ?? "",
      channel_id: json["channel_id"] ?? "",
      type: json["content_type"] ?? "",
      url: json["url"] ?? "",
      duration: json["duration"] ?? 0,
      status: json["status"] ?? "",
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}

Future<void> createLiveContent({
  required String name,

  required String url,
  required int duration,
  required String type,
  required String status,
}) async {
  final response = await ApiService.post("/live-content/create", {
    "name": name,

    "url": url,
    "duration": duration,
    "type": type,
    "status": status,
  });

  if (response.statusCode != 200) {
    throw Exception("Failed to create live content");
  }
}
