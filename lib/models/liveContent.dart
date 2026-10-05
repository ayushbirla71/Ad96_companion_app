class LiveContent {
  final String id;
  final String name;
  final String channelId;
  final String type;
  final String url;
  final int duration;
  final String status;
  final String channelStatus;
  final DateTime createdAt;

  String get channel_id => channelId;

  LiveContent({
    required this.id,
    required this.name,
    required this.channelId,
    required this.type,
    required this.url,
    required this.duration,
    required this.status,
    required this.channelStatus,
    required this.createdAt,
  });

  factory LiveContent.fromJson(Map<String, dynamic> json) {
    return LiveContent(
      id: json["live_content_id"] ?? "",
      name: json["name"] ?? "",
      channelId: json["channel_id"] ?? "",
      type: json["content_type"] ?? "",
      url: json["url"] ?? "",
      duration: json["duration"] ?? 0,
      status: json["status"] ?? "",
      channelStatus: json["channel"] != null
          ? (json["channel"]["status"] ?? "")
          : "",
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
    );
  }
}
