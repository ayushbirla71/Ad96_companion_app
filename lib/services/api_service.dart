import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../utils/token_storage.dart';
import 'package:path/path.dart'; // for basename

class ApiService {
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await TokenStorage.getToken();

    return http.post(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint) async {
    final token = await TokenStorage.getToken();

    return http.get(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
      },
    );
  }

 static Future<http.StreamedResponse> postFile(
    String endpoint, {
    required File file,
    required Map<String, String> fields,
  }) async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse(ApiConstants.baseUrl + endpoint);

    final request = http.MultipartRequest("POST", uri);

    // Add fields
    request.fields.addAll(fields);

    // Add file
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: basename(file.path),
    ));

    // Add Authorization header
    if (token != null) {
      request.headers['Authorization'] = "Bearer $token";
    }

    return request.send();
  }

  
 static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await TokenStorage.getToken();

    return http.put(
      Uri.parse(ApiConstants.baseUrl + endpoint), // ✅ fixed
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
  }

}
