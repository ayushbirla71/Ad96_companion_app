import Flutter
import UIKit

/// Forwards `streaming_events` to Flutter.
final class StreamingEventHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        StreamManager.shared.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        StreamManager.shared.eventSink = nil
        return nil
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let CHANNEL = "streaming_channel"
    private let EVENT_CHANNEL = "streaming_events"
    private let eventHandler = StreamingEventHandler()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let registrar = self.registrar(forPlugin: "camera_preview")
        registrar?.register(CameraPreviewFactory(), withId: "camera_preview")

        let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(eventHandler)

        let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { call, result in

            let args = call.arguments as? [String: Any]

            // Always answer on the main thread.
            func reply(_ value: Any?) {
                DispatchQueue.main.async { result(value) }
            }
            func fail(_ error: Error) {
                let flutterError = (error as? StreamError)?.flutterError
                    ?? FlutterError(code: "NATIVE_ERROR", message: "\(error)", details: nil)
                reply(flutterError)
            }

            switch call.method {

            // Completes after permission is resolved and the preview is running.
            case "startPreview":
                let isFront = args?["isFront"] as? Bool ?? false
                let isLandscape = args?["isLandscape"] as? Bool ?? false
                Task {
                    do {
                        try await StreamManager.shared.startPreview(isFront: isFront, isLandscape: isLandscape)
                        reply(nil)
                    } catch {
                        fail(error)
                    }
                }

            case "switchCamera":
                let isFront = args?["isFront"] as? Bool ?? false
                Task {
                    do {
                        try await StreamManager.shared.switchCamera(isFront: isFront)
                        reply(nil)
                    } catch {
                        fail(error)
                    }
                }

            case "setOrientation":
                let isLandscape = args?["isLandscape"] as? Bool ?? false
                Task {
                    do {
                        try await StreamManager.shared.setOrientation(isLandscape: isLandscape)
                        reply(nil)
                    } catch {
                        fail(error)
                    }
                }

            // Completes after RTMP connect + publish; errors if either fails.
            case "startStream":
                guard let url = args?["url"] as? String, let key = args?["key"] as? String else {
                    reply(FlutterError(code: "INVALID_ARGS", message: "Missing url/key", details: nil))
                    return
                }
                Task {
                    do {
                        try await StreamManager.shared.startStream(url: url, streamKey: key)
                        reply("started")
                    } catch {
                        fail(error)
                    }
                }

            // Stops publishing and releases camera + microphone.
            case "stopStream":
                Task {
                    await StreamManager.shared.stopStream()
                    reply("stopped")
                }

            default:
                reply(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        StreamManager.shared.stopStreamSync()
        super.applicationWillTerminate(application)
    }
}
