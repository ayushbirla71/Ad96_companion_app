// CameraPreviewView.kt
package com.demokrito.cms_app

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView

class CameraPreviewView(
    context: Context,
    viewId: Int,
    args: Any?
) : PlatformView {

    // Exactly mirrors: previewView = StreamManager.shared.hkView
    private val previewView = StreamManager.shared.textureView

    override fun getView(): View = previewView

    override fun dispose() {}
}