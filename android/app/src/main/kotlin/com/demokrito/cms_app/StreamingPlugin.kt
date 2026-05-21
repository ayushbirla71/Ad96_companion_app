// StreamingPlugin.kt
package com.demokrito.cms_app

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class StreamingPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Init singleton with context — mirrors AppDelegate setup
        StreamManager.shared.init(binding.applicationContext)

        // Register camera preview view — mirrors registrar?.register(CameraPreviewFactory())
        binding.platformViewRegistry.registerViewFactory(
            "camera_preview",
            CameraPreviewFactory()
        )

        channel = MethodChannel(binding.binaryMessenger, "streaming_channel")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *>

        when (call.method) {

            // mirrors case "startPreview"
            "startPreview" -> {
                val isFront = args?.get("isFront") as? Boolean ?: false
                val isLandscape = args?.get("isLandscape") as? Boolean ?: false
                StreamManager.shared.startPreview(isFront, isLandscape)
                result.success(null)
            }

            // mirrors case "switchCamera"
            "switchCamera" -> {
                val isFront = args?.get("isFront") as? Boolean ?: false
                StreamManager.shared.switchCamera(isFront)
                result.success(null)
            }

            // mirrors case "setOrientation"
            "setOrientation" -> {
                val isLandscape = args?.get("isLandscape") as? Boolean ?: false
                StreamManager.shared.setOrientation(isLandscape)
                result.success(null)
            }

            // mirrors case "startStream"
            "startStream" -> {
                val url = args?.get("url") as? String
                val key = args?.get("key") as? String
                if (url != null && key != null) {
                    StreamManager.shared.startStream(url, key)
                    result.success("started")
                } else {
                    result.error("INVALID_ARGS", "Missing url/key", null)
                }
            }

            // mirrors case "stopStream"
            "stopStream" -> {
                StreamManager.shared.stopStream()
                result.success("stopped")
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}