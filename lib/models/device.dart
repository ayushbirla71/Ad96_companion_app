class Device {
  final String deviceId;
  final String deviceType;
  final String deviceName;
  final String groupName;
  final String status;
  final String? groupId; // nullable
  final String? androidId;

  /// Delete handshake state from the backend:
  /// active | deleting (waiting for the screen to confirm) | delete_failed | deleted
  final String deletionStatus;
  final String? deleteFailureReason;
  final int deleteAttempts;

  Device({
    required this.deviceId,
    required this.deviceType,
    required this.deviceName,
    required this.groupName,
    required this.status,
    this.groupId,
    this.androidId,
    this.deletionStatus = 'active',
    this.deleteFailureReason,
    this.deleteAttempts = 1,
  });

  bool get isDeleting => deletionStatus == 'deleting';
  bool get deleteFailed => deletionStatus == 'delete_failed';

  factory Device.fromJson(Map<String, dynamic> json) {
    final command = json['delete_command'];
    return Device(
      deviceId: json['device_id'] ?? '',
      deviceType: json['device_type'] ?? '',
      deviceName: json['device_name'] ?? '',
      groupName: json['group_name'] ?? '',
      status: json['status'] ?? '',
      groupId: json['group_id'], // optional
      androidId: json['android_id'],
      deletionStatus: json['deletion_status'] ?? 'active',
      deleteFailureReason: command is Map ? command['failure_reason'] : null,
      deleteAttempts: command is Map ? (command['attempts'] ?? 1) : 1,
    );
  }
}
