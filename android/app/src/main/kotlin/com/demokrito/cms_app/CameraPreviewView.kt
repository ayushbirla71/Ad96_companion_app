package com.demokrito.cms_app

import android.content.Context
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.util.Log
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
        val sv          = StreamManager.shared.surfaceView
        val isLandscape = StreamManager.shared.isLandscape

        // Remove from any previous parent safely
        (sv.parent as? android.view.ViewGroup)?.removeView(sv)

        if (isLandscape) {
            // ── LANDSCAPE: original working approach ──────────────────────────
            // Camera outputs 1280x720 landscape → display as-is with 16:9 ratio
            sv.rotation = 0f

            val wrapper = AspectRatioFrameLayout(context, isLandscape = true)
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
            Log.d("CameraPreviewView", "Landscape mode — AspectRatio 16:9")

        } else {
            // ── PORTRAIT: rotate sensor output 90° to fill portrait screen ───
            // Camera outputs 1280x720 landscape frames.
            // We render SurfaceView at swapped dims then rotate 90°
            // so the result looks like a proper portrait camera preview.
            val metrics     = context.resources.displayMetrics
            val screenW     = metrics.widthPixels
            val screenH     = metrics.heightPixels

            // After 90° rotation we want 9:16 portrait fill
            // Before rotation (landscape dims): height=screenW, width=screenH*(9/16)
            // But we want to fill width=screenW so:
            // svW (before rot) = screenH  → becomes height after rot
            // svH (before rot) = screenW  → becomes width after rot
            val svW = (screenH * (9f / 16f)).toInt() // landscape width before rotation
            val svH = screenW                          // landscape height before rotation

            val params = FrameLayout.LayoutParams(svW, svH)
            params.gravity = Gravity.CENTER

            // Pivot at center of the SurfaceView before rotation
            sv.pivotX   = svW / 2f
            sv.pivotY   = svH / 2f
            sv.rotation = 90f

            Log.d("CameraPreviewView",
                "Portrait mode — sv before rotation: ${svW}x${svH} → after 90°: ${svH}x${svW}")

            container.addView(sv, params)
        }
    }

    override fun getView(): View = container
    override fun dispose() {}
}