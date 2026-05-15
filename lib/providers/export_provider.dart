import 'package:flutter/material.dart';

import '../models/export_job.dart';
import '../services/export_service.dart';

class ExportProvider extends ChangeNotifier {
  List<ExportJob> exports = [];

  bool loading = false;

  Future<void> loadExports() async {
    try {
      loading = true;

      notifyListeners();

      final data = await ExportService.fetchExports();

      data.sort(
        (a, b) =>
            DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)),
      );

      exports = data;
    } catch (e) {
      debugPrint("Export load error: $e");
    } finally {
      loading = false;

      notifyListeners();
    }
  }
}
