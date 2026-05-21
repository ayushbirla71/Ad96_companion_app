// StreamManager.kt
package com.demokrito.cms_app

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.camera2.*
import android.media.*
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.view.Surface
import android.view.TextureView
import java.io.*
import java.util.concurrent.Semaphore
import java.util.concurrent.TimeUnit

class StreamManager private constructor() {

    companion object {
        val shared = StreamManager()
        private const val TAG = "StreamManager"
        private const val VIDEO_MIME = "video/avc"
        private const val AUDIO_MIME = "audio/mp4a-latm"
        private const val SAMPLE_RATE = 44100
        private const val AUDIO_CHANNELS = 1
        private const val AUDIO_BITRATE = 128_000
        private const val VIDEO_BITRATE = 2_500_000
        private const val FPS = 30
    }

    // ── Preview View (mirrors hkView in iOS) ──────────────────────────────────
    lateinit var textureView: TextureView
        private set

    private var context: Context? = null

    // ── Camera ────────────────────────────────────────────────────────────────
    private var cameraManager: CameraManager? = null
    private var cameraDevice: CameraDevice? = null
    private var captureSession: CameraCaptureSession? = null
    private val cameraLock = Semaphore(1)
    private var cameraThread = HandlerThread("CameraThread").also { it.start() }
    private var cameraHandler = Handler(cameraThread.looper)
    private var isFrontCamera = false
    private var isLandscape = false

    // ── Encoder ───────────────────────────────────────────────────────────────
    private var videoEncoder: MediaCodec? = null
    private var audioEncoder: MediaCodec? = null
    private var audioRecord: AudioRecord? = null
    private var encoderSurface: Surface? = null
    private var previewSurface: Surface? = null

    // ── RTMP ──────────────────────────────────────────────────────────────────
    private val rtmpClient = RtmpClient()
    private var isStreaming = false
    private var audioThread: Thread? = null
    private var videoThread: Thread? = null

    // ─────────────────────────────────────────────────────────────────────────
    // INIT — call once from plugin on attach
    // ─────────────────────────────────────────────────────────────────────────

    fun init(ctx: Context) {
        context = ctx.applicationContext
        cameraManager = ctx.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        textureView = TextureView(ctx)
    }

    // ─────────────────────────────────────────────────────────────────────────
    // START PREVIEW — mirrors startPreview(isFront:isLandscape:)
    // ─────────────────────────────────────────────────────────────────────────

    fun startPreview(isFront: Boolean, isLandscape: Boolean) {
        this.isFrontCamera = isFront
        this.isLandscape = isLandscape

        // Wait for TextureView surface to be ready
        if (textureView.isAvailable) {
            openCamera()
        } else {
            textureView.surfaceTextureListener = object : TextureView.SurfaceTextureListener {
                override fun onSurfaceTextureAvailable(st: SurfaceTexture, w: Int, h: Int) {
                    openCamera()
                }
                override fun onSurfaceTextureSizeChanged(st: SurfaceTexture, w: Int, h: Int) {}
                override fun onSurfaceTextureDestroyed(st: SurfaceTexture) = true
                override fun onSurfaceTextureUpdated(st: SurfaceTexture) {}
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SWITCH CAMERA — mirrors switchCamera(isFront:)
    // ─────────────────────────────────────────────────────────────────────────

    fun switchCamera(isFront: Boolean) {
        this.isFrontCamera = isFront
        closeCamera()
        openCamera()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SET ORIENTATION — mirrors setOrientation(isLandscape:)
    // ─────────────────────────────────────────────────────────────────────────

    fun setOrientation(isLandscape: Boolean) {
        this.isLandscape = isLandscape
        // Reopen session so encoder picks up new aspect ratio
        closeCamera()
        openCamera()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // START STREAM — mirrors startStream(url:streamKey:)
    // ─────────────────────────────────────────────────────────────────────────

    fun startStream(url: String, streamKey: String) {
        if (isStreaming) return
        val fullUrl = if (url.endsWith("/")) "$url$streamKey" else "$url/$streamKey"

        setupEncoders()

        Thread {
            val connected = rtmpClient.connect(fullUrl)
            if (!connected) {
                Log.e(TAG, "RTMP connect failed")
                return@Thread
            }
            isStreaming = true
            startVideoLoop()
            startAudioLoop()
            Log.d(TAG, "Stream started → $fullUrl")
        }.start()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STOP STREAM — mirrors stopStream()
    // ─────────────────────────────────────────────────────────────────────────

    fun stopStream() {
        if (!isStreaming) return
        isStreaming = false
        audioThread?.interrupt()
        videoThread?.interrupt()
        rtmpClient.disconnect()
        releaseEncoders()
        Log.d(TAG, "Stream stopped")
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CAMERA INTERNALS
    // ─────────────────────────────────────────────────────────────────────────

    @SuppressLint("MissingPermission")
    private fun openCamera() {
        val manager = cameraManager ?: return
        if (!cameraLock.tryAcquire(2500, TimeUnit.MILLISECONDS)) {
            Log.e(TAG, "Camera lock timeout")
            return
        }

        val cameraId = getCameraId(isFrontCamera)

        try {
            manager.openCamera(cameraId, object : CameraDevice.StateCallback() {
                override fun onOpened(camera: CameraDevice) {
                    cameraLock.release()
                    cameraDevice = camera
                    startCaptureSession()
                }
                override fun onDisconnected(camera: CameraDevice) {
                    cameraLock.release()
                    camera.close()
                    cameraDevice = null
                }
                override fun onError(camera: CameraDevice, error: Int) {
                    cameraLock.release()
                    camera.close()
                    cameraDevice = null
                    Log.e(TAG, "Camera error: $error")
                }
            }, cameraHandler)
        } catch (e: Exception) {
            cameraLock.release()
            Log.e(TAG, "openCamera: ${e.message}")
        }
    }

    private fun startCaptureSession() {
        val device = cameraDevice ?: return
        val st = textureView.surfaceTexture ?: return

        val (w, h) = if (isLandscape) Pair(1280, 720) else Pair(720, 1280)
        st.setDefaultBufferSize(w, h)
        previewSurface = Surface(st)

        val targets = mutableListOf(previewSurface!!)

        // Only add encoder surface if streaming
        encoderSurface?.let { targets.add(it) }

        try {
            device.createCaptureSession(
                targets,
                object : CameraCaptureSession.StateCallback() {
                    override fun onConfigured(session: CameraCaptureSession) {
                        captureSession = session
                        val req = device.createCaptureRequest(CameraDevice.TEMPLATE_RECORD).apply {
                            addTarget(previewSurface!!)
                            encoderSurface?.let { addTarget(it) }
                            set(CaptureRequest.CONTROL_MODE, CaptureRequest.CONTROL_MODE_AUTO)
                            set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
                            set(CaptureRequest.CONTROL_AF_MODE,
                                CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO)
                        }
                        session.setRepeatingRequest(req.build(), null, cameraHandler)
                    }
                    override fun onConfigureFailed(session: CameraCaptureSession) {
                        Log.e(TAG, "Capture session config failed")
                    }
                },
                cameraHandler
            )
        } catch (e: Exception) {
            Log.e(TAG, "createCaptureSession: ${e.message}")
        }
    }

    private fun closeCamera() {
        try {
            cameraLock.acquire()
            captureSession?.close(); captureSession = null
            cameraDevice?.close(); cameraDevice = null
            previewSurface?.release(); previewSurface = null
        } finally {
            cameraLock.release()
        }
    }

    private fun getCameraId(front: Boolean): String {
        val manager = cameraManager!!
        return manager.cameraIdList.first { id ->
            val facing = manager.getCameraCharacteristics(id)
                .get(CameraCharacteristics.LENS_FACING)
            facing == if (front) CameraCharacteristics.LENS_FACING_FRONT
                      else CameraCharacteristics.LENS_FACING_BACK
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ENCODER SETUP
    // ─────────────────────────────────────────────────────────────────────────

    private fun setupEncoders() {
        val (w, h) = if (isLandscape) Pair(1280, 720) else Pair(720, 1280)

        // Video encoder
        val videoFmt = MediaFormat.createVideoFormat(VIDEO_MIME, w, h).apply {
            setInteger(MediaFormat.KEY_BIT_RATE, VIDEO_BITRATE)
            setInteger(MediaFormat.KEY_FRAME_RATE, FPS)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 2)
            setInteger(MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface)
        }
        videoEncoder = MediaCodec.createEncoderByType(VIDEO_MIME).apply {
            configure(videoFmt, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            encoderSurface = createInputSurface()
            start()
        }

        // Audio encoder
        val minBuf = AudioRecord.getMinBufferSize(
            SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
        @SuppressLint("MissingPermission")
        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC, SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, minBuf * 4
        )
        val audioFmt = MediaFormat.createAudioFormat(AUDIO_MIME, SAMPLE_RATE, AUDIO_CHANNELS).apply {
            setInteger(MediaFormat.KEY_BIT_RATE, AUDIO_BITRATE)
            setInteger(MediaFormat.KEY_AAC_PROFILE,
                MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, minBuf * 4)
        }
        audioEncoder = MediaCodec.createEncoderByType(AUDIO_MIME).apply {
            configure(audioFmt, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            start()
        }

        // Restart capture session so encoder surface gets camera frames
        closeCamera()
        openCamera()
    }

    private fun releaseEncoders() {
        videoEncoder?.stop(); videoEncoder?.release(); videoEncoder = null
        audioEncoder?.stop(); audioEncoder?.release(); audioEncoder = null
        audioRecord?.stop(); audioRecord?.release(); audioRecord = null
        encoderSurface?.release(); encoderSurface = null
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ENCODE LOOPS
    // ─────────────────────────────────────────────────────────────────────────

    private fun startVideoLoop() {
        var sps: ByteArray? = null
        var pps: ByteArray? = null
        val info = MediaCodec.BufferInfo()
        var startPts = -1L

        videoThread = Thread {
            while (isStreaming) {
                val enc = videoEncoder ?: break
                val idx = enc.dequeueOutputBuffer(info, 10_000)

                when {
                    idx == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        val fmt = enc.outputFormat
                        sps = fmt.getByteBuffer("csd-0")
                            ?.let { ByteArray(it.remaining()).also { b -> it.get(b) } }
                        pps = fmt.getByteBuffer("csd-1")
                            ?.let { ByteArray(it.remaining()).also { b -> it.get(b) } }
                        if (sps != null && pps != null)
                            rtmpClient.sendAvcSequenceHeader(sps!!, pps!!)
                    }
                    idx >= 0 -> {
                        val buf = enc.getOutputBuffer(idx) ?: run {
                            enc.releaseOutputBuffer(idx, false); return@Thread
                        }
                        val isConfig = info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0
                        if (!isConfig) {
                            if (startPts < 0) startPts = info.presentationTimeUs
                            val pts = (info.presentationTimeUs - startPts) / 1000
                            val data = ByteArray(info.size)
                            buf.position(info.offset); buf.get(data)
                            val isKey = info.flags and MediaCodec.BUFFER_FLAG_KEY_FRAME != 0
                            rtmpClient.sendVideoData(data, pts, isKey)
                        }
                        enc.releaseOutputBuffer(idx, false)
                    }
                }
            }
        }.also { it.start() }
    }

    private fun startAudioLoop() {
        rtmpClient.sendAacSequenceHeader(SAMPLE_RATE, AUDIO_CHANNELS)
        audioRecord?.startRecording()

        val info = MediaCodec.BufferInfo()
        val pcm = ByteArray(4096)
        var startPts = -1L

        audioThread = Thread {
            while (isStreaming) {
                val enc = audioEncoder ?: break
                val rec = audioRecord ?: break

                val inIdx = enc.dequeueInputBuffer(10_000)
                if (inIdx >= 0) {
                    val inBuf = enc.getInputBuffer(inIdx) ?: continue
                    val read = rec.read(pcm, 0, pcm.size)
                    if (read > 0) {
                        inBuf.clear(); inBuf.put(pcm, 0, read)
                        enc.queueInputBuffer(inIdx, 0, read, System.nanoTime() / 1000, 0)
                    }
                }

                val outIdx = enc.dequeueOutputBuffer(info, 0)
                if (outIdx >= 0) {
                    val outBuf = enc.getOutputBuffer(outIdx)
                    val isConfig = info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0
                    if (!isConfig && outBuf != null) {
                        if (startPts < 0) startPts = info.presentationTimeUs
                        val pts = (info.presentationTimeUs - startPts) / 1000
                        val data = ByteArray(info.size)
                        outBuf.position(info.offset); outBuf.get(data)
                        rtmpClient.sendAudioData(data, pts)
                    }
                    enc.releaseOutputBuffer(outIdx, false)
                }
            }
            audioRecord?.stop()
        }.also { it.start() }
    }
}