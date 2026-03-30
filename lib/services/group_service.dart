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


  static Future<List<dynamic>> fetchScheduledGroups({
  required String contentId,
  required String contentType,
  required String startDate,
  required String endDate,
}) async {
  final url =
      "/schedule/live/content-groups?contentId=$contentId&contentType=$contentType&startDate=$startDate&endDate=$endDate";

  final response = await ApiService.get(url);

  print("ressss..>>>>>>>>>>>>>>>>>>>>>>>>>>>, ${response.body}");

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return body["groups"] ?? [];
  } else {
    throw Exception("Failed to load scheduled groups");
  }
}
}
