import 'dart:convert';

import 'package:cms_app/services/api_service.dart';

class StorageService {
  /// INCREMENT USED STORAGE
  static Future<void> incrementStorage(int fileSizeBytes) async {
    final response = await ApiService.post("/storage/increment", {
      "fileSizeBytes": fileSizeBytes,
    });

    final body = jsonDecode(response.body);

    print("STORAGE RESPONSE: $body");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(body["message"] ?? "Failed to update storage");
    }
  }
}
