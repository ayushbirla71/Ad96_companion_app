import 'dart:convert';
import '../utils/api_constants.dart';
import '../utils/token_storage.dart';
import 'api_service.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    final response = await ApiService.post(
      ApiConstants.login,
      {
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];
      await TokenStorage.saveToken(token);
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
