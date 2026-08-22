import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../utils/token_storage.dart';

class NotificationApiService {
  static Future<Map<String, dynamic>> fetchNotifications({int limit = 30}) async {
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse("${ApiConstants.baseUrl}/notifications/list?limit=$limit");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          "success": true,
          "data": body["data"] ?? [],
          "unreadCount": body["unreadCount"] ?? 0,
        };
      }
    } catch (e) {
      print("Error fetching notifications API: $e");
    }
    return {"success": false, "data": [], "unreadCount": 0};
  }

  static Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse("${ApiConstants.baseUrl}/notifications/$notificationId/read");

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error marking notification as read: $e");
    }
    return false;
  }

  static Future<bool> markAllAsRead() async {
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse("${ApiConstants.baseUrl}/notifications/mark-all-read");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
    return false;
  }

  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse("${ApiConstants.baseUrl}/notifications/$notificationId");

      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting notification from DB: $e");
    }
    return false;
  }

  static Future<bool> clearAllNotifications() async {
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse("${ApiConstants.baseUrl}/notifications/clear-all");

      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error clearing all notifications from DB: $e");
    }
    return false;
  }
}
