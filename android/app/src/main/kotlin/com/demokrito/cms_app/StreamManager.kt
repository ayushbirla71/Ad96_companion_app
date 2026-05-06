package com.demokrito.cms_app

import android.content.Context
import com.pedro.library.rtmp.RtmpCamera2
import com.pedro.common.ConnectChecker

object StreamManager {

    private var camera: RtmpCamera2? = null

    fun init(context: Context) {
        if (camera == null) {
            camera = RtmpCamera2(
                context,
                object : ConnectChecker {
                    override fun onConnectionStarted(url: String) {}
                    override fun onConnectionSuccess() {}
                    override fun onConnectionFailed(reason: String) {}
                    override fun onDisconnect() {}
                    override fun onAuthError() {}
                    override fun onAuthSuccess() {}
                    override fun onNewBitrate(bitrate: Long) {}
                }
            )
        }
    }

    fun startStream(url: String) {
        camera?.prepareAudio()
        camera?.prepareVideo()
        camera?.startStream(url)
    }

    fun stopStream() {
        camera?.stopStream()
    }

    fun switchCamera() {
        camera?.switchCamera()
    }
}