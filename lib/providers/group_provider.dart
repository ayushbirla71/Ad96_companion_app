import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  List<Group> groups = [];
  bool loading = false;
  List<Group> scheduledGroups = [];
bool groupsLoading = false;

  Future<void> loadGroups() async {
    loading = true;
    notifyListeners();

    try {
      final data = await GroupService.fetchGroups();
      print("group api response..... ${data}");
      groups = data.map((e) => Group.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Group error: $e");
    }

    loading = false;
    notifyListeners();
  }

 Future<void> fetchScheduledGroups({
  required String contentId,
  required String contentType,
  required String startDate,
  required String endDate,
}) async {
  try {
    groupsLoading = true;
    notifyListeners();

    final data = await GroupService.fetchScheduledGroups(
      contentId: contentId,
      contentType: contentType,
      startDate: startDate,
      endDate: endDate,
    );

    print("ksdjfjf, ${data}");

    scheduledGroups = data.map((e) => Group.fromJson(e)).toList();
  } catch (e) {
    debugPrint("Scheduled Group error: $e");
    scheduledGroups = [];
  } finally {
    groupsLoading = false;
    notifyListeners();
  }
}

}
