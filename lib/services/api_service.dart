// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import '../utils/api_constants.dart';
// import '../utils/token_storage.dart';
// import 'package:path/path.dart'; // for basename

// class ApiService {
//   static Future<Map<String, String>> _headers({bool json = false}) async {
//     final token = await TokenStorage.getToken();

//     return {
//       if (json) "Content-Type": "application/json",
//       if (token != null) "Authorization": "Bearer $token",
//     };
//   }

//   static Future<http.Response> _handleResponse(http.Response response) async {
//     if (response.statusCode == 401) {
//       await TokenStorage.clearToken();

//       throw Exception("Session expired");
//     }

//     return response;
//   }

//   static Future<http.Response> post(
//     String endpoint,
//     Map<String, dynamic> body,
//   ) async {
//     final token = await TokenStorage.getToken();

//     return http.post(
//       Uri.parse(ApiConstants.baseUrl + endpoint),
//       headers: {
//         "Content-Type": "application/json",
//         if (token != null) "Authorization": "Bearer $token",
//       },
//       body: jsonEncode(body),
//     );
//   }

//   static Future<http.Response> get(String endpoint) async {
//     final token = await TokenStorage.getToken();

//     return http.get(
//       Uri.parse(ApiConstants.baseUrl + endpoint),
//       headers: {if (token != null) "Authorization": "Bearer $token"},
//     );
//   }

//   static Future<http.StreamedResponse> postFile(
//     String endpoint, {
//     required File file,
//     required Map<String, String> fields,
//   }) async {
//     final token = await TokenStorage.getToken();
//     final uri = Uri.parse(ApiConstants.baseUrl + endpoint);

//     final request = http.MultipartRequest("POST", uri);

//     // Add fields
//     request.fields.addAll(fields);

//     // Add file
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'file',
//         file.path,
//         filename: basename(file.path),
//       ),
//     );

//     // Add Authorization header
//     if (token != null) {
//       request.headers['Authorization'] = "Bearer $token";
//     }

//     return request.send();
//   }

//   static Future<http.Response> put(
//     String endpoint,
//     Map<String, dynamic> body,
//   ) async {
//     final token = await TokenStorage.getToken();

//     return http.put(
//       Uri.parse(ApiConstants.baseUrl + endpoint), // ✅ fixed
//       headers: {
//         "Content-Type": "application/json",
//         if (token != null) "Authorization": "Bearer $token",
//       },
//       body: jsonEncode(body),
//     );
//   }

//   static Future<http.Response> delete(String endpoint) async {
//     return http.delete(
//       Uri.parse(ApiConstants.baseUrl + endpoint),
//       headers: await _headers(),
//     );
//   }
// }













import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../utils/api_constants.dart';
import '../utils/token_storage.dart';
import '../utils/app_navigator.dart';
import '../providers/auth_provider.dart';

class ApiService {

  // -----------------------------
  // Headers
  // -----------------------------
  static Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await TokenStorage.getToken();

    return {
      if (json) "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // -----------------------------
  // Handle API Response
  // -----------------------------
  static Future<http.Response> _handleResponse(http.Response response) async {

    if (response.statusCode == 401) {

      await TokenStorage.clearToken();

      final context = AppNavigator.navigatorKey.currentContext;

      if (context != null) {
        context.read<AuthProvider>().logout();
      }

      throw Exception("Session expired");
    }

    return response;
  }

  // -----------------------------
  // GET
  // -----------------------------
  static Future<http.Response> get(String endpoint) async {

    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // -----------------------------
  // POST
  // -----------------------------
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {

    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(json: true),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // -----------------------------
  // PUT
  // -----------------------------
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {

    final response = await http.put(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(json: true),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // -----------------------------
  // DELETE
  // -----------------------------
  static Future<http.Response> delete(String endpoint) async {

    final response = await http.delete(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // -----------------------------
  // FILE UPLOAD
  // -----------------------------
  static Future<http.StreamedResponse> postFile(
    String endpoint, {
    required File file,
    required Map<String, String> fields,
  }) async {

    final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll(await _headers());

    request.fields.addAll(fields);

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        file.path,
        filename: basename(file.path),
      ),
    );

    final response = await request.send();

    if (response.statusCode == 401) {

      await TokenStorage.clearToken();

      final context = AppNavigator.navigatorKey.currentContext;

      if (context != null) {
        context.read<AuthProvider>().logout();
      }

      throw Exception("Session expired");
    }

    return response;
  }
}