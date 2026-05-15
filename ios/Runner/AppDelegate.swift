import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let CHANNEL = "streaming_channel"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController
        let registrar = self.registrar(forPlugin: "camera_preview")
        registrar?.register(CameraPreviewFactory(), withId: "camera_preview")

        let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { call, result in
            
            let args = call.arguments as? [String: Any]

            switch call.method {

            // 🔴 1. New: Start Preview
            case "startPreview":
                let isFront = args?["isFront"] as? Bool ?? false
                let isLandscape = args?["isLandscape"] as? Bool ?? false
                StreamManager.shared.startPreview(isFront: isFront, isLandscape: isLandscape)
                result(nil)

            // 🔴 2. New: Switch Camera
            case "switchCamera":
                let isFront = args?["isFront"] as? Bool ?? false
                StreamManager.shared.switchCamera(isFront: isFront)
                result(nil)

            // 🔴 3. New: Set Orientation
            case "setOrientation":
                let isLandscape = args?["isLandscape"] as? Bool ?? false
                StreamManager.shared.setOrientation(isLandscape: isLandscape)
                result(nil)

            // 4. Publish Stream
            case "startStream":
                if let url = args?["url"] as? String, let key = args?["key"] as? String {
                    StreamManager.shared.startStream(url: url, streamKey: key)
                    result("started")
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing url/key", details: nil))
                }

            // 5. Stop Everything
            case "stopStream":
                StreamManager.shared.stopStream()
                result("stopped")

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}