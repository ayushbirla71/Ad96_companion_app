import 'dart:convert';
import '../services/api_service.dart';

class ChannelService {
  /// FETCH CHANNELS
  static Future<List<dynamic>> fetchChannels() async {
    // final response = await ApiService.get("/streaming/channel");
    final response = await ApiService.get("/streaming/client-channel");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      print("channels >>>>>>>>>>>> $body");

      return body["data"] ?? [];
    } else {
      throw Exception("Failed to load channels: ${response.statusCode}");
    }
  }

  /// FETCH SINGLE CHANNEL DETAILS
  static Future<Map<String, dynamic>> fetchChannelDetails(String id) async {
    final response = await ApiService.get("/streaming/channel/$id");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      print("channel details >>>>>>>>>>>> $body");

      return body["data"] ?? {};
    } else {
      throw Exception("Failed to load channel details: ${response.statusCode}");
    }
  }

  /// CREATE CHANNEL
  static Future<void> createChannel(String name) async {
    final response = await ApiService.post("/streaming/channel", {
      "name": name,
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final body = jsonDecode(response.body);

        final message =
            body["error"]?["details"] ??
            body["message"] ??
            "Channel creation failed";

        throw Exception(message);
      } catch (e) {
        throw Exception("Channel creation failed");
      }
    }
  }

  /// DELETE CHANNEL
  static Future<void> deleteChannel(String id) async {
    final response = await ApiService.delete("/streaming/channel/$id");

    if (response.statusCode != 200) {
      throw Exception("Channel deletion failed: ${response.body}");
    }
  }

  static Future<void> startChannel(String id) async {
    final response = await ApiService.put(
      "/streaming/channel/$id/start", // endpoint for starting the channel
      {}, // any body if needed
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to start channel: ${response.body}");
    }
  }

  /// STOP CHANNEL
  static Future<void> stopChannel(String id) async {
    final response = await ApiService.put(
      "/streaming/channel/$id/stop", // endpoint for stopping the channel
      {}, // any body if needed
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to stop channel: ${response.body}");
    }
  }
}
