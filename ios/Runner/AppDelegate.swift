import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let CHANNEL = "streaming_channel"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Keep Flutter plugins
        GeneratedPluginRegistrant.register(with: self)
        
        // Setup Method Channel
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { (call, result) in
            
            switch call.method {
                
            case "startStream":
                if let args = call.arguments as? [String: Any],
                   let url = args["url"] as? String,
                   let key = args["key"] as? String {
                    
                    StreamManager.shared.startStream(url: url, streamKey: key)
                    result("started")
                    
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing url/key", details: nil))
                }
                
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