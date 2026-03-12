import 'package:flutter/material.dart';
import '../models/liveContent.dart';
import '../services/live_content_service.dart';

class LiveContentProvider extends ChangeNotifier {

  final LiveContentService _service = LiveContentService();

  List<LiveContent> _contents = [];
  List<LiveContent> get contents => _contents;

  bool _loading = false;
  bool get loading => _loading;

  String _search = "";
  String _statusFilter = "All";
  String _typeFilter = "All";

  List<LiveContent> get filteredContents {

    List<LiveContent> list = List.from(_contents);

    /// SEARCH
    if (_search.isNotEmpty) {
      list = list.where((e) =>
          e.name.toLowerCase().contains(_search.toLowerCase())
      ).toList();
    }

    /// STATUS FILTER
    if (_statusFilter != "All") {
      list = list.where((e) =>
          e.status.toLowerCase() == _statusFilter.toLowerCase()
      ).toList();
    }

    /// TYPE FILTER
    if (_typeFilter != "All") {
      list = list.where((e) =>
          e.type.toLowerCase() == _typeFilter.toLowerCase()
      ).toList();
    }

    return list;
  }

  Future<void> fetchContents() async {

    _loading = true;
    notifyListeners();

    try {

      _contents = await _service.fetchLiveContents();

    } catch (e) {
      debugPrint("Live content error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setTypeFilter(String value) {
    _typeFilter = value;
    notifyListeners();
  }
}