package com.demokrito.cms_app

import android.content.Context
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.platform.PlatformView

class CameraPreviewView(
    context: Context,
    viewId: Int,
    args: Any?
) : PlatformView {

    private val container: FrameLayout = FrameLayout(context).apply {
        setBackgroundColor(android.graphics.Color.BLACK)
    }

    init {
        val sv = StreamManager.shared.surfaceView

        // Remove from any previous parent
        (sv.parent as? android.view.ViewGroup)?.removeView(sv)

        // We use a custom FrameLayout that sizes the SurfaceView
        // to its exact aspect ratio instead of stretching it
        val wrapper = AspectRatioFrameLayout(context)
        wrapper.addView(
            sv,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        container.addView(
            wrapper,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
                Gravity.CENTER
            )
        )
    }

    override fun getView(): View = container
    override fun dispose() {}
}