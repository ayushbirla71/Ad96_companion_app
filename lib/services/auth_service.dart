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
    try {
      await FCMService.unregisterTokenWithBackend();
    } catch (_) {}
    await TokenStorage.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }

  /// Sends a 6-digit OTP verification email for self-service password recovery.
  static Future<Map<String, dynamic>> sendForgotPasswordOtp(String email) async {
    try {
      final response = await ApiService.post(ApiConstants.forgotPassword, {
        "email": email.trim(),
      });

      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"] ?? "Verification code sent to your email.",
          "resendAfterSeconds": body["resendAfterSeconds"] ?? 60,
        };
      } else {
        return {
          "success": false,
          "message": body["message"] ?? "Failed to send verification code.",
          "retryAfter": body["retryAfter"],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Unable to connect to server. Please check your internet connection.",
      };
    }
  }

  /// Verifies the submitted 6-digit OTP code and receives a single-use resetToken.
  static Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.post(ApiConstants.verifyOtp, {
        "email": email.trim(),
        "otp": otp.trim(),
      });

      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"] ?? "Code verified successfully.",
          "resetToken": body["resetToken"],
        };
      } else {
        return {
          "success": false,
          "message": body["message"] ?? "Invalid verification code.",
          "remainingAttempts": body["remainingAttempts"],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Unable to verify code. Please check your internet connection.",
      };
    }
  }

  /// Sets a new password using the validated resetToken.
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService.post(ApiConstants.resetPassword, {
        "email": email.trim(),
        "resetToken": resetToken,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      });

      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"] ?? "Password successfully reset.",
        };
      } else {
        return {
          "success": false,
          "message": body["message"] ?? "Failed to reset password.",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Unable to reset password. Please check your internet connection.",
      };
    }
  }
}
