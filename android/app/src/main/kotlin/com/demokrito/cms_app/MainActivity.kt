package com.demokrito.cms_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "streaming_channel"

    private lateinit var streamManager: StreamManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        streamManager = StreamManager(this)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "camera_preview",
                CameraPreviewFactory(streamManager)
            )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            val args = call.arguments as? Map<String, Any>

            when(call.method) {

                "startPreview" -> {

                    val isFront =
                        args?.get("isFront") as? Boolean ?: false

                    streamManager.startPreview(isFront)

                    result.success(null)
                }

                "switchCamera" -> {

                    streamManager.switchCamera()

                    result.success(null)
                }

                "startStream" -> {

                    val url =
                        args?.get("url") as? String ?: ""

                    val key =
                        args?.get("key") as? String ?: ""

                    streamManager.startStream("$url/$key")

                    result.success("started")
                }

                "stopStream" -> {

                    streamManager.stopStream()

                    result.success("stopped")
                }

                "releaseCamera" -> {

                    streamManager.release()

                    result.success("released")
                }

                else -> result.notImplemented()
            }
        }
    }
}