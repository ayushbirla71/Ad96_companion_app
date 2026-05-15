import 'dart:convert';

import '../models/export_job.dart';
import 'api_service.dart';

class ExportService {
  static Future<List<ExportJob>> fetchExports() async {

    final response = await ApiService.get("/exports");

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      print("EXPORTS API: $data");

      return data
          .map((e) => ExportJob.fromJson(e))
          .toList();
    }

    throw Exception("Failed to load exports");
  }
}
