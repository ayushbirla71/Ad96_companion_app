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
            // ── LANDSCAPE ──────────────────────────────────────────────────────
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
        } else {
            // ── PORTRAIT ───────────────────────────────────────────────────────
            val metrics = context.resources.displayMetrics
            val screenW = metrics.widthPixels
            val screenH = metrics.heightPixels

            // 1. Enforce a strict 16:9 ratio to prevent ANY stretching
            val cameraAspect = 16f / 9f

            // 2. We want the rotated preview to fill the portrait screen.
            // After 90 deg rotation: visualWidth = svH, visualHeight = svW
            var svH = screenW // Try fitting to the screen's width first
            var svW = (svH * cameraAspect).toInt()

            // 3. If fitting to width leaves black bars at the top/bottom, 
            // we scale it up to fit the height instead (Center-Crop)
            if (svW < screenH) {
                svW = screenH
                svH = (svW / cameraAspect).toInt()
            }

            val params = FrameLayout.LayoutParams(svW, svH)
            params.gravity = Gravity.CENTER

            // 4. Pivot at the exact center of the unrotated SurfaceView
            sv.pivotX   = svW / 2f
            sv.pivotY   = svH / 2f
            sv.rotation = 90f

            Log.d("CameraPreviewView",
                "Portrait mode — Perfect 16:9 Layout: ${svW}x${svH} (Rotated to fill screen)")

            container.addView(sv, params)
        }
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        // Handled by StreamManager cleanup
    }
}