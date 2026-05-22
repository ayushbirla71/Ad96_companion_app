package com.demokrito.cms_app

import android.content.Context
import android.util.Log
import android.widget.FrameLayout

/**
 * @param isLandscape true = 16:9, false = not used (portrait uses rotation instead)
 */
class AspectRatioFrameLayout(
    context: Context,
    private val isLandscape: Boolean = true
) : FrameLayout(context) {

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val parentWidth  = MeasureSpec.getSize(widthMeasureSpec).toFloat()
        val parentHeight = MeasureSpec.getSize(heightMeasureSpec).toFloat()

        if (parentWidth == 0f || parentHeight == 0f) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
            return
        }

        // Only used for landscape — 16:9
        val cameraAspect = 16f / 9f
        val parentAspect = parentWidth / parentHeight

        val finalWidth: Int
        val finalHeight: Int

        if (parentAspect > cameraAspect) {
            // Parent wider than 16:9 → fit height, pillarbox sides
            finalHeight = parentHeight.toInt()
            finalWidth  = (parentHeight * cameraAspect).toInt()
        } else {
            // Parent taller than 16:9 → fit width, letterbox top/bottom
            finalWidth  = parentWidth.toInt()
            finalHeight = (parentWidth / cameraAspect).toInt()
        }

        Log.d("AspectRatio", "parent=${parentWidth}x${parentHeight} final=${finalWidth}x${finalHeight}")

        super.onMeasure(
            MeasureSpec.makeMeasureSpec(finalWidth,  MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(finalHeight, MeasureSpec.EXACTLY)
        )
    }
}