import 'dart:convert';
import '../services/api_service.dart';

class DeviceService {
  static Future<List<dynamic>> fetchDevices() async {
    final response = await ApiService.get("/device/all");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("bodya >>>>>>>>>>>> $body");
    return body["devices"] ?? [];
    } else {
      throw Exception("Failed to load devices");
    }
  }
}
