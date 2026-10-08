import 'package:permission_handler/permission_handler.dart';

enum StreamingPermissionStatus { granted, denied, permanentlyDenied }

/// Camera + microphone permissions for going live. Runs before the streaming
/// engine is created so the native layers never have to prompt on their own.
class StreamingPermissionService {
  static Future<StreamingPermissionStatus> check() async {
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    return _combine(camera, mic);
  }

  static Future<StreamingPermissionStatus> request() async {
    final results = await [Permission.camera, Permission.microphone].request();
    return _combine(
      results[Permission.camera] ?? PermissionStatus.denied,
      results[Permission.microphone] ?? PermissionStatus.denied,
    );
  }

  static Future<bool> openSettings() => openAppSettings();

  static StreamingPermissionStatus _combine(
    PermissionStatus camera,
    PermissionStatus mic,
  ) {
    bool ok(PermissionStatus s) => s.isGranted || s.isLimited;
    bool blocked(PermissionStatus s) => s.isPermanentlyDenied || s.isRestricted;

    if (ok(camera) && ok(mic)) return StreamingPermissionStatus.granted;
    if (blocked(camera) || blocked(mic)) {
      return StreamingPermissionStatus.permanentlyDenied;
    }
    return StreamingPermissionStatus.denied;
  }
}
