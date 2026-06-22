import 'package:flutter/material.dart';
import '../models/liveContent.dart';
import '../services/live_content_service.dart';

class LiveContentProvider extends ChangeNotifier {
  final LiveContentService _service = LiveContentService();

  List<LiveContent> _contents = [];
  List<LiveContent> get contents => _contents;

  /// alias
  List<LiveContent> get liveContents => _contents;

  bool _loading = false;
  bool get loading => _loading;

  String _search = "";
  String _statusFilter = "All";
  String _typeFilter = "All";

  String get search => _search;
  String get statusFilter => _statusFilter;
  String get typeFilter => _typeFilter;

  /// FILTERED LIST
  List<LiveContent> get filteredContents {
    List<LiveContent> list = List.from(_contents);

    if (_search.trim().isNotEmpty) {
      list = list
          .where((e) => e.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }

    if (_statusFilter != "All") {
      list = list
          .where((e) => e.status.toLowerCase() == _statusFilter.toLowerCase())
          .toList();
    }

    if (_typeFilter != "All") {
      list = list
          .where((e) => e.type.toLowerCase() == _typeFilter.toLowerCase())
          .toList();
    }

    return list;
  }

  /// FETCH CONTENTS
  Future<void> fetchContents() async {
    try {
      _loading = true;
      notifyListeners();

      final data = await _service.fetchLiveContents();

      _contents = data;
    } catch (e) {
      debugPrint("Live content fetch error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ALIAS
  Future<void> loadLiveContents() async {
    await fetchContents();
  }

  /// CREATE CONTENT (NEW)
  Future<void> createContent({
    required String name,
    required String url,
    required int duration,
    required String type,
    required String status,
    String? channelId,
    DateTime? startTime,
    DateTime? endTime,
    bool autoplay = false,
    bool mute = false,
    bool loop = false,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      final content = await _service.createLiveContent(
        name: name,
        url: url,
        duration: duration,
        type: type,
        status: status,
        startTime: startTime,
        endTime: endTime,
        autoplay: autoplay,
        channelId: channelId,
        mute: mute,
        loop: loop,
      );

      /// Add new content to list
      _contents.insert(0, content);
    } catch (e) {
      debugPrint("Create live content error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// SEARCH
  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  /// STATUS FILTER
  void setStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  /// TYPE FILTER
  void setTypeFilter(String value) {
    _typeFilter = value;
    notifyListeners();
  }

  /// RESET FILTERS
  void resetFilters() {
    _search = "";
    _statusFilter = "All";
    _typeFilter = "All";

    notifyListeners();
  }

  /// DELETE CONTENT
  Future<void> deleteContent(String id) async {
    try {
      await _service.deleteLiveContent(id);

      _contents.removeWhere((e) => e.id == id);

      notifyListeners();
    } catch (e) {
      debugPrint("Delete content error: $e");
    }
  }

  /// DELETE CONTENT
  Future<void> deleteSchedules(String contentId, String contentType) async {
    try {
      await _service.deleteSchedules(
        contentId: contentId,
        contentType: contentType,
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Delete content error: $e");
    }
  }
}
