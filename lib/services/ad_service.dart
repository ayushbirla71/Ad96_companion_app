import 'dart:convert';
import '../services/api_service.dart';

class AdService {
  static Future<List<dynamic>> fetchAds() async {
    final response = await ApiService.get("/ads/all");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["ads"] ?? [];
    } else {
      throw Exception("Failed to load ads");
    }
  }
}
