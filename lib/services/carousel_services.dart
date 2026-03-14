// import 'dart:convert';
// import '../services/api_service.dart';

// class CarouselServices {
//   static Future<List<dynamic>> fetchCarousel() async {
//     final response = await ApiService.get("/carousel/all");

//     if (response.statusCode == 200) {
//       final body = jsonDecode(response.body);
//       return body["data"] ?? [];
//     } else {
//       throw Exception("Failed to load ads");
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:cms_app/services/api_service.dart';

class CarouselService {

  /// ---------------- GET ALL CAROUSELS ----------------
  static Future<List<dynamic>> fetchCarousels() async {

    final response = await ApiService.get("/carousel/all");

    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);

      return body["data"] ?? [];

    }

    throw Exception("Failed to load carousels");
  }

  /// ---------------- GET SINGLE CAROUSEL ----------------
  static Future<Map<String, dynamic>> getCarousel(String id) async {

    final response = await ApiService.get("/carousel/$id");

    if (response.statusCode == 200) {

      return jsonDecode(response.body)["data"];

    }

    throw Exception("Failed to load carousel");
  }

  /// ---------------- FETCH ADS ----------------
  static Future<List<dynamic>> fetchAds() async {

    final response = await ApiService.get("/ads/all");

    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);

      return body["data"] ?? [];

    }

    throw Exception("Failed to load ads");
  }

  /// ---------------- CREATE CAROUSEL ----------------
  static Future<void> createCarousel(
    Map<String, dynamic> data,
  ) async {

    final response = await ApiService.post(
      "/carousel/create",
      data,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {

      throw Exception("Failed to create carousel");

    }
  }

  /// ---------------- UPDATE CAROUSEL ----------------
  static Future<void> updateCarousel(
    String id,
    Map<String, dynamic> data,
  ) async {

    final response = await ApiService.put(
      "/carousel/$id",
      data,
    );

    if (response.statusCode != 200) {

      throw Exception("Failed to update carousel");

    }
  }

  /// ---------------- TOGGLE STATUS ----------------
  static Future<void> toggleStatus(
    String id,
    String status,
  ) async {

    final response = await ApiService.put(
      "/carousel/$id",
      {
        "status": status,
      },
    );

    if (response.statusCode != 200) {

      throw Exception("Failed to update status");

    }
  }

  /// ---------------- DELETE CAROUSEL ----------------
  static Future<void> deleteCarousel(String id) async {

    final response = await ApiService.delete(
      "/carousel/$id",
    );

    if (response.statusCode != 200) {

      throw Exception("Failed to delete carousel");

    }
  }

  /// ---------------- UPLOAD FILE ----------------
  static Future<String> uploadAdFile(File file) async {

    final response = await ApiService.postFile(
      "/ads/upload",
      file: file,
      fields: {},
    );

    final responseBody =
        await response.stream.bytesToString();

    final body = jsonDecode(responseBody);

    if (response.statusCode == 200) {

      return body["data"]["url"];

    }

    throw Exception("File upload failed");
  }
}