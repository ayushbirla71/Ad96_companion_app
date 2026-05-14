// import 'dart:convert';
// import '../services/api_service.dart';

// class CarouselServices {
//   static Future<List<dynamic>> fetchCarousel() async {
//     final response = await ApiService.get("/carousel/all");

//     if (response.statusCode == 200) {
//       final body = jsonDecode(response.body);
//       return body["data"] ?? [];
//     } else {
//       throw Exception("Failed to load ads");
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:cms_app/services/api_service.dart';

class CarouselService {
  /// ---------------- GET ALL CAROUSELS ----------------
  static Future<List<dynamic>> fetchCarousels() async {
    final response = await ApiService.get("/carousel/all");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return body["data"] ?? [];
    }

    throw Exception("Failed to load carousels");
  }

  /// ---------------- GET SINGLE CAROUSEL ----------------
  static Future<Map<String, dynamic>> getCarousel(String id) async {
    final response = await ApiService.get("/carousel/$id");

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"];
    }

    throw Exception("Failed to load carousel");
  }

  /// ---------------- FETCH ADS ----------------
  static Future<List<dynamic>> fetchAds() async {
    final response = await ApiService.get("/ads/all");

    print("adssssss. resp.  ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return body["ads"] ?? [];
    }

    throw Exception("Failed to load ads");
  }

  /// ---------------- CREATE CAROUSEL ----------------
  // static Future<void> createCarousel(Map<String, dynamic> data) async {
  //   final response = await ApiService.post("/carousel/create", data);

  //   if (response.statusCode != 200 && response.statusCode != 201) {
  //     throw Exception("Failed to create carousel");
  //   }
  // }

  static Future<Map<String, dynamic>> createCarousel(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.post("/carousel/create", data);

    final body = jsonDecode(response.body);

    print("CREATE CAROUSEL RESPONSE: $body");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body;
    }

    throw Exception(body["message"] ?? "Failed to create carousel");
  }

  /// ---------------- UPDATE CAROUSEL ----------------
  static Future<void> updateCarousel(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.put("/carousel/$id", data);

    if (response.statusCode != 200) {
      throw Exception("Failed to update carousel");
    }
  }

  /// ---------------- TOGGLE STATUS ----------------
  static Future<void> toggleStatus(String id, String status) async {
    final response = await ApiService.put("/carousel/$id", {"status": status});

    if (response.statusCode != 200) {
      throw Exception("Failed to update status");
    }
  }

  /// ---------------- DELETE CAROUSEL ----------------
  static Future<void> deleteCarousel(String id) async {
    final response = await ApiService.delete("/carousel/$id");

    if (response.statusCode != 200) {
      throw Exception("Failed to delete carousel");
    }
  }

  /// ---------------- UPLOAD FILE ----------------
  // static Future<String> uploadAdFile(File file) async {

  //   final response = await ApiService.postFile(
  //     "/ads/upload",
  //     file: file,
  //     fields: {},
  //   );

  //   final responseBody =
  //       await response.stream.bytesToString();

  //   final body = jsonDecode(responseBody);

  //   if (response.statusCode == 200) {

  //     return body["data"]["url"];

  //   }

  //   throw Exception("File upload failed");
  // }

  /// ---------------- UPLOAD FILE ----------------
  static Future<String> uploadAdFile(
    File file, {
    Function(double progress, String status, String? speed, String? timeLeft)?
    onProgress,
  }) async {
    final fileSizeInMB = await file.length() / (1024 * 1024);

    if (fileSizeInMB > 50) {
      return await uploadLargeFile(file, onProgress: onProgress);
    } else {
      return await uploadSingleFile(file, onProgress: onProgress);
    }
  }

  static Future<String> uploadSingleFile(
    File file, {
    Function(double progress, String status, String? speed, String? timeLeft)?
    onProgress,
  }) async {
    final extension = file.path.split(".").last;

    final generatedFileName =
        "ad-${DateTime.now().millisecondsSinceEpoch}.$extension";

    onProgress?.call(10, "Getting upload URL...", null, null);

    final response = await ApiService.post("/s3/single-part-upload", {
      "fileName": generatedFileName,
      "fileType": getMimeType(extension),
    });

    final body = jsonDecode(response.body);

    final uploadUrl = body["uploadUrl"];

    onProgress?.call(30, "Uploading file...", null, null);

    final bytes = await file.readAsBytes();

    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      body: bytes,
      headers: {"Content-Type": getMimeType(extension)},
    );

    if (uploadResponse.statusCode != 200) {
      throw Exception("Upload failed");
    }

    onProgress?.call(100, "Upload complete!", null, null);

    return generatedFileName;
  }

  static Future<String> uploadLargeFile(
    File file, {
    Function(double progress, String status, String? speed, String? timeLeft)?
    onProgress,
  }) async {
    final extension = file.path.split(".").last;

    final generatedFileName =
        "ad-${DateTime.now().millisecondsSinceEpoch}.$extension";

    /// CREATE MULTIPART
    final createResponse = await ApiService.post(
      "/s3/create-multipart-upload",
      {"fileName": generatedFileName, "fileType": getMimeType(extension)},
    );

    final createBody = jsonDecode(createResponse.body);

    final uploadId = createBody["uploadId"];

    const partSize = 5 * 1024 * 1024;

    final totalBytes = await file.length();

    final partsCount = (totalBytes / partSize).ceil();

    /// GENERATE URLS
    final urlsResponse = await ApiService.post("/s3/generate-upload-urls", {
      "fileName": generatedFileName,
      "uploadId": uploadId,
      "partsCount": partsCount,
    });

    final urlsBody = jsonDecode(urlsResponse.body);

    final List urls = urlsBody["urls"];

    List<Map<String, dynamic>> uploadedParts = [];

    int uploadedBytes = 0;

    final startTime = DateTime.now();

    for (int i = 0; i < urls.length; i++) {
      final start = i * partSize;

      final end = min(start + partSize, totalBytes);

      final stream = file.openRead(start, end);

      final bytes = await stream.fold<List<int>>([], (a, b) => a..addAll(b));

      final uploadResponse = await http.put(Uri.parse(urls[i]), body: bytes);

      if (uploadResponse.statusCode != 200) {
        throw Exception("Part upload failed");
      }

      final etag = uploadResponse.headers["etag"];

      uploadedParts.add({"ETag": etag, "PartNumber": i + 1});

      uploadedBytes += bytes.length;

      final progress = (uploadedBytes / totalBytes) * 100;

      final elapsed = DateTime.now().difference(startTime).inSeconds;

      final speed = elapsed == 0 ? 0 : uploadedBytes / elapsed;

      final remainingBytes = totalBytes - uploadedBytes;

      final remainingSeconds = speed == 0 ? 0 : remainingBytes / speed;

      onProgress?.call(
        progress,
        "Uploading part ${i + 1}/$partsCount",
        "${formatBytes(speed.toInt())}/s",
        "${remainingSeconds.round()}s",
      );
    }

    /// COMPLETE MULTIPART
    await ApiService.post("/s3/complete-multipart-upload", {
      "fileName": generatedFileName,
      "uploadId": uploadId,
      "parts": uploadedParts,
    });

    onProgress?.call(100, "Upload complete!", null, null);

    return generatedFileName;
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";

    const suffixes = ["B", "KB", "MB", "GB"];

    final i = (log(bytes) / log(1024)).floor();

    return "${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}";
  }

  static String getMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case "mp4":
        return "video/mp4";

      case "png":
        return "image/png";

      case "jpg":
      case "jpeg":
        return "image/jpeg";

      case "webp":
        return "image/webp";

      default:
        return "application/octet-stream";
    }
  }
}
