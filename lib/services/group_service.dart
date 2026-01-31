import 'dart:convert';
import '../services/api_service.dart';

class GroupService {
  static Future<List<dynamic>> fetchGroups() async {
    final response = await ApiService.get("/device/fetch-groups");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("bodya groupq >>>>>>>>>>>> $body");
      return body["groups"] ?? [];
    } else {
      throw Exception("Failed to load groups");
    }
  }

   static Future<dynamic> deleteGroup(String groupId) async {
    final response =
        await ApiService.post("/device/group/delete/$groupId", {});

    return response;
  }
}
