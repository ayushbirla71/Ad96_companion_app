class Channel {
  final String channelId;
  final String name;
  final String status;
  final String playbackUrl;
  final String streamKey;
  final String rtmpUrl;
  final DateTime createdAt;

  Channel({
    required this.channelId,
    required this.name,
    required this.status,
    required this.playbackUrl,
    required this.streamKey,
    required this.rtmpUrl,
    required this.createdAt,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      channelId: json["channel_id"] ?? "",
      name: json["name"] ?? "",
      status: json["status"] ?? "inactive",
      playbackUrl: json["playback_url"] ?? "",
      streamKey: json["stream_key"] ?? "",
      rtmpUrl: json["ingest_url"] ?? "",
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "channel_id": channelId,
      "name": name,
      "status": status,
      "playback_url": playbackUrl,
      "stream_key": streamKey,
      "ingest_url": rtmpUrl,
      "created_at": createdAt.toIso8601String(),
    };
  }
}