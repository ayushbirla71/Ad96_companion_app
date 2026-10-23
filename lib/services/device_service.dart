import 'dart:convert';
import '../services/api_service.dart';

class DeviceService {
  static Future<List<dynamic>> fetchDevices() async {
    final response = await ApiService.get("/device/all");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
    return body["devices"] ?? [];
    } else {
      throw Exception("Failed to load devices");
    }
  }

  /// Starts the delete handshake: the backend tells the screen to exit and the
  /// record is removed once the screen confirms. Returns null on success, or an
  /// error message.
  static Future<String?> requestDelete(String deviceId) =>
      _deleteAction('/device/delete/$deviceId', 'Failed to delete device');

  /// Re-sends the exit command (device was offline / did not confirm).
  static Future<String?> retryDelete(String deviceId) =>
      _deleteAction('/device/delete/$deviceId/retry', 'Retry failed');

  /// Removes the record without waiting for the screen to confirm.
  static Future<String?> forceDelete(String deviceId) =>
      _deleteAction('/device/delete/$deviceId/force', 'Force delete failed');

  static Future<String?> _deleteAction(String path, String fallback) async {
    try {
      final response = await ApiService.post(path, {});
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      try {
        final error = jsonDecode(response.body)['error'];
        if (error is String && error.isNotEmpty) return error;
      } catch (_) {}
      return '$fallback (${response.statusCode})';
    } catch (e) {
      return '$fallback: $e';
    }
  }
}
