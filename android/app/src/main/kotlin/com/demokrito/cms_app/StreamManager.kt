package com.demokrito.cms_app

import android.content.Context
import android.util.Log

import com.pedro.common.ConnectChecker
import com.pedro.encoder.input.video.CameraHelper
import com.pedro.library.rtmp.RtmpCamera2
import com.pedro.library.view.OpenGlView

class StreamManager(
    context: Context
) : ConnectChecker {

    /////////////////////////////////////////////////////////
    // SINGLE PERSISTENT VIEW
    /////////////////////////////////////////////////////////

    val surfaceView = OpenGlView(context)

    /////////////////////////////////////////////////////////
    // SINGLE CAMERA INSTANCE
    /////////////////////////////////////////////////////////

    private val rtmpCamera2 =
        RtmpCamera2(surfaceView, this)

    /////////////////////////////////////////////////////////
    // START PREVIEW
    /////////////////////////////////////////////////////////

    fun startPreview(isFront: Boolean) {

    try {

        //////////////////////////////////////////////////////
        // STOP OLD PREVIEW
        //////////////////////////////////////////////////////

        if (rtmpCamera2.isOnPreview) {

            rtmpCamera2.stopPreview()

            Thread.sleep(500)
        }

        //////////////////////////////////////////////////////
        // IMPORTANT
        // PREPARE VIDEO BEFORE PREVIEW
        //////////////////////////////////////////////////////

        val prepared =
            rtmpCamera2.prepareVideo()

        if (!prepared) {

            Log.e(
                "STREAM",
                "prepareVideo failed"
            )

            return
        }

        //////////////////////////////////////////////////////
        // START PREVIEW
        //////////////////////////////////////////////////////

        if (isFront) {

            rtmpCamera2.startPreview(
                CameraHelper.Facing.FRONT
            )

        } else {

            rtmpCamera2.startPreview(
                CameraHelper.Facing.BACK
            )
        }

        Log.d(
            "STREAM",
            "Preview Started"
        )

    } catch (e: Exception) {

        e.printStackTrace()
    }
}

    /////////////////////////////////////////////////////////
    // SWITCH CAMERA
    /////////////////////////////////////////////////////////

    fun switchCamera() {

        try {

            rtmpCamera2.switchCamera()

        } catch (e: Exception) {

            e.printStackTrace()
        }
    }

    /////////////////////////////////////////////////////////
    // START STREAM
    /////////////////////////////////////////////////////////

    fun startStream(url: String) {

        try {

            if (!rtmpCamera2.isStreaming) {

                val preparedVideo =
                    rtmpCamera2.prepareVideo()

                val preparedAudio =
                    rtmpCamera2.prepareAudio()

                if (preparedVideo && preparedAudio) {

                    rtmpCamera2.startStream(url)

                } else {

                    Log.e(
                        "STREAM",
                        "Prepare failed"
                    )
                }
            }

        } catch (e: Exception) {

            e.printStackTrace()
        }
    }

    /////////////////////////////////////////////////////////
    // STOP STREAM
    /////////////////////////////////////////////////////////

    fun stopStream() {

        try {

            if (rtmpCamera2.isStreaming) {

                rtmpCamera2.stopStream()
            }

        } catch (e: Exception) {

            e.printStackTrace()
        }
    }

    /////////////////////////////////////////////////////////
    // RELEASE EVERYTHING
    /////////////////////////////////////////////////////////

    fun release() {

        try {

            if (rtmpCamera2.isStreaming) {

                rtmpCamera2.stopStream()
            }

            if (rtmpCamera2.isOnPreview) {

                rtmpCamera2.stopPreview()
            }

        } catch (e: Exception) {

            e.printStackTrace()
        }
    }

    /////////////////////////////////////////////////////////
    // CALLBACKS
    /////////////////////////////////////////////////////////

    override fun onConnectionStarted(url: String) {

        Log.d("STREAM", "Started")
    }

    override fun onConnectionSuccess() {

        Log.d("STREAM", "Success")
    }

    override fun onConnectionFailed(reason: String) {

        Log.e("STREAM", reason)
    }

    override fun onDisconnect() {

        Log.d("STREAM", "Disconnected")
    }

    override fun onAuthError() {

        Log.e("STREAM", "Auth error")
    }

    override fun onAuthSuccess() {

        Log.d("STREAM", "Auth success")
    }

    override fun onNewBitrate(bitrate: Long) {

        Log.d("STREAM", "Bitrate: $bitrate")
    }
}