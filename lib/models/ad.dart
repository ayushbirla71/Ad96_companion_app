class Ad {
  final String adId;
  final String name;
  final String? url;
  final String clientName;
  final int duration;
  final String status;

  Ad({
    required this.adId,
    required this.name,
    this.url,
    required this.clientName,
    required this.duration,
    required this.status,
  });
  String get id => adId;
  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      adId: json['ad_id'],
      name: json['name'],
      url: json['url'],
      clientName: json['client_name'],
      duration: json['duration'],
      status: json['status'],
    );
  }
}
