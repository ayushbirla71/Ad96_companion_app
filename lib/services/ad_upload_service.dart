import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class AdUploadService {
  static const int singleUploadLimit = 50 * 1024 * 1024; // 50MB
  static const int partSize = 5 * 1024 * 1024; // 5MB

  /// ENTRY POINT
  static Future<String> uploadFile({
    required File file,
    required Function(int progress, String status) onProgress,
  }) async {
    final fileSize = await file.length();
    print("upload .... lenght ${fileSize}");

    if (fileSize <= singleUploadLimit) {
      print("inside single ... ${file}");
      return _singlePartUpload(file, onProgress);
    } else {
      return _multiPartUpload(file, onProgress);
    }
  }

  /// 🔹 SINGLE PART UPLOAD
  static Future<String> _singlePartUpload(
    File file,
    Function(int, String) onProgress,
  ) async {
    final ext = file.path.split('.').last;
    final fileName = "ad-${DateTime.now().millisecondsSinceEpoch}.$ext";

    onProgress(10, "Getting upload URL...");

    final signedRes = await ApiService.post(
      "/s3/single-part-upload",
      {
        "fileName": fileName,
        "fileType": _mimeType(ext),
      },
    );

    final signedBody = jsonDecode(signedRes.body);
    final uploadUrl = signedBody['uploadUrl'];

    onProgress(30, "Uploading file...");

    final bytes = await file.readAsBytes();
    await http.put(
      Uri.parse(uploadUrl),
      body: bytes,
      headers: {"Content-Type": _mimeType(ext)},
    );

    onProgress(100, "Upload completed");

    print("...... ...>>>>>>>>>>>>>>> ${fileName}");
    return fileName;
  }

  /// 🔹 MULTI PART UPLOAD
  static Future<String> _multiPartUpload(
    File file,
    Function(int, String) onProgress,
  ) async {
    final ext = file.path.split('.').last;
    final fileName = "ad-${DateTime.now().millisecondsSinceEpoch}.$ext";
    final fileSize = await file.length();
    final partsCount = (fileSize / partSize).ceil();

    // 1️⃣ Init
    final initRes = await ApiService.post(
      "/s3/create-multipart-upload",
      {
        "fileName": fileName,
        "fileType": _mimeType(ext),
      },
    );

    final uploadId = jsonDecode(initRes.body)['uploadId'];

    // 2️⃣ Get URLs
    final urlRes = await ApiService.post(
      "/s3/generate-upload-urls",
      {
        "fileName": fileName,
        "uploadId": uploadId,
        "partsCount": partsCount,
      },
    );

    final urls = jsonDecode(urlRes.body)['urls'];

    int uploadedBytes = 0;
    final parts = <Map<String, dynamic>>[];

    final raf = file.openSync();

    for (int i = 0; i < urls.length; i++) {
      final start = i * partSize;
      final length = min(partSize, fileSize - start);
      raf.setPositionSync(start);
      final chunk = raf.readSync(length);

      final res = await http.put(
        Uri.parse(urls[i]['signedUrl']),
        body: chunk,
      );

      final etag = res.headers['etag']?.replaceAll('"', '');
      parts.add({"ETag": etag, "PartNumber": urls[i]['partNumber']});

      uploadedBytes += length;
      final progress = ((uploadedBytes / fileSize) * 100).round();
      onProgress(progress, "Uploading part ${i + 1}/$partsCount");
    }

    raf.closeSync();

    // 3️⃣ Complete upload
    await ApiService.post(
      "/s3/complete-multipart-upload",
      {
        "fileName": fileName,
        "uploadId": uploadId,
        "parts": parts,
      },
    );

    onProgress(100, "Upload completed");
    return fileName;
  }

  static String _mimeType(String ext) {
    switch (ext) {
      case "mp4":
        return "video/mp4";
      case "jpg":
      case "jpeg":
        return "image/jpeg";
      case "png":
        return "image/png";
      default:
        return "application/octet-stream";
    }
  }
}
