import 'dart:convert';
import '../services/api_service.dart';

class ChannelService {

  /// FETCH CHANNELS
  static Future<List<dynamic>> fetchChannels() async {

    final response = await ApiService.get("/streaming/channel");

    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);

      print("channels >>>>>>>>>>>> $body");

      return body["data"] ?? [];

    } else {

      throw Exception(
        "Failed to load channels: ${response.statusCode}"
      );
    }
  }

  /// CREATE CHANNEL
  static Future<void> createChannel(String name) async {

    final response = await ApiService.post(
      "/streaming/channel",
      {
        "name": name,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {

      throw Exception(
        "Channel creation failed: ${response.body}"
      );
    }
  }

  /// DELETE CHANNEL
  static Future<void> deleteChannel(String id) async {

    final response = await ApiService.delete(
      "/streaming/channel/$id",
    );

    if (response.statusCode != 200) {

      throw Exception(
        "Channel deletion failed: ${response.body}"
      );
    }
  }
}