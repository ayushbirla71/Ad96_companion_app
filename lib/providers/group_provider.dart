import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  List<Group> groups = [];
  bool loading = false;

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
}
