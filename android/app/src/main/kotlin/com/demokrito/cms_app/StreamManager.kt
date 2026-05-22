package com.demokrito.cms_app

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.camera2.*
import android.media.*
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.view.Surface
import android.view.SurfaceHolder
import android.view.SurfaceView
import java.util.concurrent.Semaphore
import java.util.concurrent.TimeUnit

class StreamManager private constructor() {

    companion object {
        val shared = StreamManager()
        private const val TAG = "StreamManager"
        private const val VIDEO_MIME  = "video/avc"
        private const val AUDIO_MIME  = "audio/mp4a-latm"
        private const val SAMPLE_RATE = 44100
        private const val AUDIO_CHANNELS = 1
        private const val AUDIO_BITRATE  = 128_000
        private const val VIDEO_BITRATE  = 2_500_000
        private const val FPS = 30
    }

    lateinit var surfaceView: SurfaceView
        private set

    private var context: Context? = null
    private var cameraManager: CameraManager? = null
    private var cameraDevice: CameraDevice? = null
    private var captureSession: CameraCaptureSession? = null

    // Use a single lock object for all camera state changes
    private val cameraStateLock = Any()
    private val cameraOpenLock = Semaphore(1)

    private var cameraThread = HandlerThread("CameraThread").also { it.start() }
    private var cameraHandler = Handler(cameraThread.looper)

    var isFrontCamera = false
        private set
    var isLandscape = false
        private set

    private var videoEncoder: MediaCodec? = null
    private var audioEncoder: MediaCodec? = null
    private var audioRecord: AudioRecord? = null
    private var encoderSurface: Surface? = null

    private val rtmpClient = RtmpClient()
    private var isStreaming = false
    private var audioThread: Thread? = null
    private var videoThread: Thread? = null

    // Guards against surfaceDestroyed racing with onConfigured
    @Volatile private var surfaceReady = false
    @Volatile private var isCameraClosing = false

    // ─────────────────────────────────────────────────────────────────────────
    // INIT
    // ─────────────────────────────────────────────────────────────────────────

    fun init(ctx: Context) {
        context = ctx.applicationContext
        cameraManager = ctx.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        surfaceView = SurfaceView(ctx)

        surfaceView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                Log.d(TAG, "surfaceCreated")
                surfaceReady = true
                isCameraClosing = false
                openCameraIfReady()
            }

            override fun surfaceChanged(holder: SurfaceHolder, format: Int, w: Int, h: Int) {
                Log.d(TAG, "surfaceChanged: ${w}x${h}")
                // Surface dimensions changed — restart session only if camera is open
                if (surfaceReady && cameraDevice != null) {
                    restartCaptureSession()
                }
            }

            override fun surfaceDestroyed(holder: SurfaceHolder) {
                Log.d(TAG, "surfaceDestroyed")
                surfaceReady = false
                isCameraClosing = true
                safeCloseCamera()
            }
        })
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PUBLIC API
    // ─────────────────────────────────────────────────────────────────────────

    fun startPreview(isFront: Boolean, landscape: Boolean) {
        isFrontCamera = isFront
        isLandscape   = landscape
        // Do NOT call setFixedSize here — let the view fill naturally
        // and use TEMPLATE_RECORD which auto-selects best output size
        openCameraIfReady()
    }

    fun switchCamera(isFront: Boolean) {
        isFrontCamera = isFront
        isCameraClosing = true
        safeCloseCamera()
        isCameraClosing = false
        openCameraIfReady()
    }

    fun setOrientation(landscape: Boolean) {
        isLandscape = landscape
        isCameraClosing = true
        safeCloseCamera()
        isCameraClosing = false
        openCameraIfReady()
    }

    fun startStream(url: String, streamKey: String) {
        if (isStreaming) return
        val fullUrl = if (url.endsWith("/")) "$url$streamKey" else "$url/$streamKey"
        setupEncoders()
        Thread {
            val connected = rtmpClient.connect(fullUrl)
            if (!connected) { Log.e(TAG, "RTMP connect failed"); return@Thread }
            isStreaming = true
            startVideoLoop()
            startAudioLoop()
        }.start()
    }

    fun stopStream() {
        if (!isStreaming) return
        isStreaming = false
        audioThread?.interrupt()
        videoThread?.interrupt()
        rtmpClient.disconnect()
        releaseEncoders()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CAMERA OPEN
    // ─────────────────────────────────────────────────────────────────────────

    private fun openCameraIfReady() {
        if (!surfaceReady) {
            Log.d(TAG, "Surface not ready — waiting for surfaceCreated")
            return
        }
        openCamera()
    }

    @SuppressLint("MissingPermission")
    private fun openCamera() {
        val manager = cameraManager ?: return
        if (!cameraOpenLock.tryAcquire(2500, TimeUnit.MILLISECONDS)) {
            Log.e(TAG, "Camera lock timeout"); return
        }
        isCameraClosing = false
        val cameraId = getCameraId(isFrontCamera)
        try {
            manager.openCamera(cameraId, object : CameraDevice.StateCallback() {
                override fun onOpened(camera: CameraDevice) {
                    cameraOpenLock.release()
                    synchronized(cameraStateLock) {
                        if (isCameraClosing) {
                            // Surface was destroyed while we were opening — abort
                            camera.close()
                            return
                        }
                        cameraDevice = camera
                    }
                    startCaptureSession()
                }
                override fun onDisconnected(camera: CameraDevice) {
                    cameraOpenLock.release()
                    synchronized(cameraStateLock) {
                        camera.close()
                        cameraDevice = null
                    }
                }
                override fun onError(camera: CameraDevice, error: Int) {
                    cameraOpenLock.release()
                    synchronized(cameraStateLock) {
                        camera.close()
                        cameraDevice = null
                    }
                    Log.e(TAG, "Camera error: $error")
                }
            }, cameraHandler)
        } catch (e: Exception) {
            cameraOpenLock.release()
            Log.e(TAG, "openCamera: ${e.message}")
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CAPTURE SESSION
    // ─────────────────────────────────────────────────────────────────────────

    private fun startCaptureSession() {
        synchronized(cameraStateLock) {
            if (isCameraClosing || !surfaceReady) {
                Log.d(TAG, "Skipping session start — closing or surface gone")
                return
            }

            val device = cameraDevice ?: return
            val holderSurface = surfaceView.holder.surface

            if (!holderSurface.isValid) {
                Log.e(TAG, "Surface invalid — cannot start session")
                return
            }

            val targets = mutableListOf(holderSurface)
            encoderSurface?.let { targets.add(it) }

            try {
                device.createCaptureSession(
                    targets,
                    object : CameraCaptureSession.StateCallback() {
                        override fun onConfigured(session: CameraCaptureSession) {
    synchronized(cameraStateLock) {
        if (isCameraClosing || !surfaceReady || cameraDevice == null) {
            Log.d(TAG, "Session configured but camera already closing — aborting")
            session.close()
            return
        }
        captureSession = session
    }

    try {
        // ↓ REPLACE your existing val req = ... block with this
        val req = cameraDevice!!.createCaptureRequest(
            CameraDevice.TEMPLATE_RECORD
        ).apply {
            addTarget(holderSurface)
            encoderSurface?.let { addTarget(it) }
            set(CaptureRequest.CONTROL_MODE, CaptureRequest.CONTROL_MODE_AUTO)
            set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
            set(CaptureRequest.CONTROL_AF_MODE,
                CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO)
            // Rotation hint to camera HAL
            val rotation = if (isLandscape) 0 else 90
            set(CaptureRequest.JPEG_ORIENTATION, rotation)
        }
        session.setRepeatingRequest(req.build(), null, cameraHandler)
        Log.d(TAG, "Capture session started ✓")
    } catch (e: Exception) {
        Log.e(TAG, "setRepeatingRequest failed: ${e.message}")
    }
}

                        override fun onConfigureFailed(session: CameraCaptureSession) {
                            Log.e(TAG, "Session configure failed")
                        }

                        override fun onClosed(session: CameraCaptureSession) {
                            Log.d(TAG, "Session closed")
                        }
                    },
                    cameraHandler
                )
            } catch (e: Exception) {
                Log.e(TAG, "createCaptureSession: ${e.message}")
            }
        }
    }

    private fun restartCaptureSession() {
        synchronized(cameraStateLock) {
            captureSession?.close()
            captureSession = null
        }
        startCaptureSession()
    }

    private fun safeCloseCamera() {
        synchronized(cameraStateLock) {
            try {
                captureSession?.close()
                captureSession = null
                cameraDevice?.close()
                cameraDevice = null
            } catch (e: Exception) {
                Log.e(TAG, "safeCloseCamera: ${e.message}")
            }
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
    // ENCODERS
    // ─────────────────────────────────────────────────────────────────────────

    private fun setupEncoders() {
        val (w, h) = if (isLandscape) Pair(1280, 720) else Pair(720, 1280)
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

        // Reopen session to include encoder surface
        restartCaptureSession()
    }

    private fun releaseEncoders() {
        videoEncoder?.stop(); videoEncoder?.release(); videoEncoder = null
        audioEncoder?.stop(); audioEncoder?.release(); audioEncoder = null
        audioRecord?.stop();  audioRecord?.release();  audioRecord  = null
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
                        val buf = enc.getOutputBuffer(idx)
                        val isConfig = info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0
                        if (!isConfig && buf != null) {
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
                        enc.queueInputBuffer(inIdx, 0, read,
                            System.nanoTime() / 1000, 0)
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