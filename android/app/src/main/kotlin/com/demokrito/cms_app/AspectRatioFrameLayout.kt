package com.demokrito.cms_app

import android.content.Context
import android.util.Log
import android.widget.FrameLayout

class AspectRatioFrameLayout(context: Context) : FrameLayout(context) {

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val parentWidth  = MeasureSpec.getSize(widthMeasureSpec).toFloat()
        val parentHeight = MeasureSpec.getSize(heightMeasureSpec).toFloat()

        if (parentWidth == 0f || parentHeight == 0f) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
            return
        }

        val isLandscape = StreamManager.shared.isLandscape

        // Landscape works perfectly at 16:9 (1280/720)
        // Portrait  = same ratio but swapped → 9:16 (720/1280)
        val cameraAspect = if (isLandscape) 16f / 9f else 9f / 16f

        val parentAspect = parentWidth / parentHeight

        val finalWidth: Int
        val finalHeight: Int

        if (parentAspect > cameraAspect) {
            // Parent wider → fit to height, black bars on sides
            finalHeight = parentHeight.toInt()
            finalWidth  = (parentHeight * cameraAspect).toInt()
        } else {
            // Parent taller → fit to width, black bars top/bottom
            finalWidth  = parentWidth.toInt()
            finalHeight = (parentWidth / cameraAspect).toInt()
        }

        Log.d("AspectRatio", "isLandscape=$isLandscape parent=${parentWidth}x${parentHeight} final=${finalWidth}x${finalHeight}")

        super.onMeasure(
            MeasureSpec.makeMeasureSpec(finalWidth,  MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(finalHeight, MeasureSpec.EXACTLY)
        )
    }
}