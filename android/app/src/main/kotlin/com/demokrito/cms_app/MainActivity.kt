package com.demokrito.cms_app

import android.content.Context
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import android.widget.FrameLayout

class MainActivity : FlutterActivity() {

    private val CHANNEL = "rtmp_stream"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        StreamManager.init(this)

        // register preview
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "rtmp_camera_view",
                CameraFactory(this)
            )

        // method channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "startStream" -> {
                    val url = call.argument<String>("url") ?: ""
                    StreamManager.startStream(url)
                    result.success(true)
                }

                "stopStream" -> {
                    StreamManager.stopStream()
                    result.success(true)
                }

                "switchCamera" -> {
                    StreamManager.switchCamera()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}

class CameraFactory(private val context: Context) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        viewId: Int,
        args: Any?
    ): PlatformView {
        return CameraPlatformView(this.context)
    }
}

class CameraPlatformView(
    private val context: Context
) : PlatformView {

    private val view = FrameLayout(context)

    override fun getView(): View {
        return view
    }

    override fun dispose() {}
}