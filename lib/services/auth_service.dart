import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../utils/token_storage.dart';
import 'api_service.dart';
import 'fcm_service.dart';

class AuthService {
  /// Returns null on success, or an error message to show the user
  /// (e.g. "This account is suspended. Please contact support.").
  static Future<String?> login(String email, String password) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      print("Retrieved Mobile FCM Token for login: $fcmToken");
    } catch (e) {
      print("Could not fetch mobile FCM token during login: $e");
    }

    final deviceId = await TokenStorage.getOrCreateDeviceId();

    final http.Response response;
    try {
      response = await ApiService.post(ApiConstants.login, {
        "email": email,
        "password": password,
        "deviceToken": fcmToken ?? "",
        "platform": Platform.isAndroid ? "android" : (Platform.isIOS ? "ios" : "web"),
        "deviceId": deviceId,
      });
    } catch (e) {
      print("Login request failed: $e");
      return "Could not reach the server. Check your connection and try again.";
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];
      await TokenStorage.saveToken(token);

      // Explicitly register FCM token with user_id and unique deviceId
      if (fcmToken != null && fcmToken.isNotEmpty) {
        String? userId = data["user"]?["id"]?.toString() ?? data["user"]?["user_id"]?.toString();
        await FCMService.registerTokenWithBackend(fcmToken, userId: userId, deviceId: deviceId);
      }

      return null;
    }

    // Suspended / deleted accounts come back as 403 with a readable message.
    if (response.statusCode == 403) {
      try {
        final message = jsonDecode(response.body)["message"];
        if (message is String && message.isNotEmpty) return message;
      } catch (_) {}
      return "This account is suspended. Please contact support.";
    }

    return "Invalid credentials";
  }

  /// Asks the backend to email a password reset link.
  /// Returns null on success, or an error message to show the user.
  /// The link opens the web reset page, so the app has no reset screen.
  static Future<String?> forgotPassword(String email) async {
    try {
      final response = await ApiService.post(ApiConstants.forgotPassword, {
        "email": email,
      });

      if (response.statusCode == 200) return null;

      try {
        final message = jsonDecode(response.body)["message"];
        if (message is String && message.isNotEmpty) return message;
      } catch (_) {}
      return "Could not send reset link. Please try again.";
    } catch (e) {
      print("Forgot password request failed: $e");
      return "Could not reach the server. Check your connection and try again.";
    }
  }


  static Future<void> logout() async {
    try {
      await FCMService.unregisterTokenWithBackend();
    } catch (_) {}
    await TokenStorage.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }
}
