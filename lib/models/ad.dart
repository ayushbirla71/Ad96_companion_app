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
    this.clientName = "",
    required this.duration,
    this.status = "",
  });

  String get id => adId;

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      adId: json['ad_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? json['file_url']?.toString(),
      clientName: json['client_name']?.toString() ?? json['Client']?['name']?.toString() ?? '',
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
    );
  }
}

