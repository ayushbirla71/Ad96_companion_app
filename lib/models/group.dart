class Group {
  final String id;
  final String name;

  final bool rcsEnabled;
  final bool placeholderEnabled;
  final bool logoEnabled;

  final String regCode;
  final int deviceCount;
  final String message;

  final String clientId;
  final String clientName;

  Group({
    required this.id,
    required this.name,
    required this.rcsEnabled,
    required this.placeholderEnabled,
    required this.logoEnabled,
    required this.regCode,
    required this.deviceCount,
    required this.message,
    required this.clientId,
    required this.clientName,
  });

  factory Group.fromJson(Map<String, dynamic> json) {

    print("grop.... data ...is ${json}");
    return Group(
      id: json["group_id"],
      name: json["name"] ?? "",

      rcsEnabled: json["rcs_enabled"] ?? false,
      placeholderEnabled: json["placeholder_enabled"] ?? false,
      logoEnabled: json["logo_enabled"] ?? false,

      regCode: json["reg_code"] ?? "",
      deviceCount: json["device_count"] ?? 0,
      message: json["message"] ?? "",

      clientId: json["Client"]?["client_id"] ?? "",
      clientName: json["Client"]?["name"] ?? "",
    );
  }
}
