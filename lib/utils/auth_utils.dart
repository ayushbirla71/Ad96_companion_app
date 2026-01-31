import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'token_storage.dart';

class AuthUtils {
  static Future<String?> getRole() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );

      final data = jsonDecode(payload);
      return data['role'] as String?;
    } catch (e) {
      debugPrint("JWT decode error: $e");
      return null;
    }
  }

  static Future<bool> isAdmin() async {
    return (await getRole()) == 'admin';
  }

  static Future<bool> isClient() async {
    return (await getRole()) == 'client';
  }
}
