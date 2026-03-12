import 'dart:convert';
import 'package:cms_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import '../models/liveContent.dart';

class LiveContentService {

  Future<List<LiveContent>> fetchLiveContents() async {

    final response = await ApiService.get(
      "/live-content/all");

      print("api callllll");

       if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("bodya groupq >>>>>>>>>>>> $body");
      // return body["data"] ?? [];
            List data = body["data"] ?? [];

      /// Convert JSON → Model
      return data.map((e) => LiveContent.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load groups");
    }
}

Future<void> createLiveContent({
  required String name,
  required String url,
  required int duration,
  required String type,
  required String status,
}) async {

  final response = await ApiService.post(
    "/live-content/create",
    {
      "name": name,
      "url": url,
      "duration": duration,
      "type": type,
      "status": status,
    },
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to create live content");
  }
}
}

