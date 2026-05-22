package com.demokrito.cms_app

import android.content.Context
import android.view.View

import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class CameraPreviewFactory(
    private val streamManager: StreamManager
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        id: Int,
        args: Any?
    ): PlatformView {

        return CameraPreview(streamManager)
    }
}

class CameraPreview(
    private val streamManager: StreamManager
) : PlatformView {

    override fun getView(): View {

        return streamManager.surfaceView
    }

    override fun dispose() {}
}