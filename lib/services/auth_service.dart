import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/api_constants.dart';
import '../utils/token_storage.dart';
import 'api_service.dart';
import 'fcm_service.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      print("Retrieved Mobile FCM Token for login: $fcmToken");
    } catch (e) {
      print("Could not fetch mobile FCM token during login: $e");
    }

    final deviceId = await TokenStorage.getOrCreateDeviceId();

    final response = await ApiService.post(ApiConstants.login, {
      "email": email,
      "password": password,
      "deviceToken": fcmToken ?? "",
      "platform": Platform.isAndroid ? "android" : (Platform.isIOS ? "ios" : "web"),
      "deviceId": deviceId,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];
      await TokenStorage.saveToken(token);

      // Explicitly register FCM token with user_id and unique deviceId
      if (fcmToken != null && fcmToken.isNotEmpty) {
        String? userId = data["user"]?["id"]?.toString() ?? data["user"]?["user_id"]?.toString();
        await FCMService.registerTokenWithBackend(fcmToken, userId: userId, deviceId: deviceId);
      }

      return true;
    }


    return false;
  }


  static Future<void> logout() async {
    await TokenStorage.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }
}
