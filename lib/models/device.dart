class Device {
  final String deviceId;
  final String deviceType;
  final String deviceName;
  final String groupName;
  final String status;
  final String? groupId; // nullable

  Device({
    required this.deviceId,
    required this.deviceType,
    required this.deviceName,
    required this.groupName,
    required this.status,
    this.groupId,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'] ?? '',
      deviceType: json['device_type'] ?? '',
      deviceName: json['device_name'] ?? '',
      groupName: json['group_name'] ?? '',
      status: json['status'] ?? '',
      groupId: json['group_id'], // optional
    );
  }
}
