package com.demokrito.cms_app

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.ImageFormat
import android.hardware.camera2.*
import android.media.*
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.view.Surface
import android.view.SurfaceHolder
import android.view.SurfaceView
import java.nio.ByteBuffer
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
    private var imageReader: ImageReader? = null // The Middleman for Portrait mode

    val rtmpClient = RtmpClient() 
    private var isStreaming = false
    private var audioThread: Thread? = null
    private var videoThread: Thread? = null

    @Volatile private var surfaceReady = false
    @Volatile private var isCameraClosing = false

    // ─────────────────────────────────────────────────────────────────────────
    // INIT & PUBLIC API
    // ─────────────────────────────────────────────────────────────────────────

    fun init(ctx: Context) {
        context = ctx.applicationContext
        cameraManager = ctx.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        surfaceView = SurfaceView(ctx)

        surfaceView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                surfaceReady = true
                isCameraClosing = false
                openCameraIfReady()
            }
            override fun surfaceChanged(holder: SurfaceHolder, format: Int, w: Int, h: Int) {
                if (surfaceReady && cameraDevice != null) restartCaptureSession()
            }
            override fun surfaceDestroyed(holder: SurfaceHolder) {
                surfaceReady = false
                isCameraClosing = true
                safeCloseCamera()
            }
        })
    }

    fun startPreview(isFront: Boolean, landscape: Boolean) {
        isFrontCamera = isFront
        isLandscape   = landscape
        surfaceView.holder.setFixedSize(1280, 720)
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
        surfaceView.holder.setFixedSize(1280, 720)
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
        try {
            videoThread?.join(500)
            audioThread?.join(500)
        } catch (e: Exception) {}

        videoThread = null
        audioThread = null
        rtmpClient.disconnect()
        releaseEncoders()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CAMERA LIFECYCLE
    // ─────────────────────────────────────────────────────────────────────────

    private fun openCameraIfReady() {
        if (!surfaceReady) return
        openCamera()
    }

    @SuppressLint("MissingPermission")
    private fun openCamera() {
        val manager = cameraManager ?: return
        if (!cameraOpenLock.tryAcquire(2500, TimeUnit.MILLISECONDS)) return
        isCameraClosing = false
        val cameraId = getCameraId(isFrontCamera)
        try {
            manager.openCamera(cameraId, object : CameraDevice.StateCallback() {
                override fun onOpened(camera: CameraDevice) {
                    cameraOpenLock.release()
                    synchronized(cameraStateLock) {
                        if (isCameraClosing) { camera.close(); return }
                        cameraDevice = camera
                    }
                    startCaptureSession()
                }
                override fun onDisconnected(camera: CameraDevice) {
                    cameraOpenLock.release()
                    synchronized(cameraStateLock) { camera.close(); cameraDevice = null }
                }
                override fun onError(camera: CameraDevice, error: Int) {
                    cameraOpenLock.release()
                    synchronized(cameraStateLock) { camera.close(); cameraDevice = null }
                }
            }, cameraHandler)
        } catch (e: Exception) { cameraOpenLock.release() }
    }

    private fun startCaptureSession() {
        synchronized(cameraStateLock) {
            if (isCameraClosing || !surfaceReady) return
            val device = cameraDevice ?: return
            val holderSurface = surfaceView.holder.surface
            if (!holderSurface.isValid) return

            val targets = mutableListOf(holderSurface)
            
            // FIX: Target the middleman ImageReader in Portrait, or the hardware encoder directly in Landscape
            if (isLandscape) {
                encoderSurface?.let { targets.add(it) }
            } else {
                imageReader?.surface?.let { targets.add(it) }
            }

            try {
                device.createCaptureSession(targets, object : CameraCaptureSession.StateCallback() {
                    override fun onConfigured(session: CameraCaptureSession) {
                        synchronized(cameraStateLock) {
                            if (isCameraClosing || !surfaceReady || cameraDevice == null) {
                                session.close(); return
                            }
                            captureSession = session
                        }
                        try {
                            val req = cameraDevice!!.createCaptureRequest(CameraDevice.TEMPLATE_RECORD).apply {
                                addTarget(holderSurface)
                                if (isLandscape) {
                                    encoderSurface?.let { addTarget(it) }
                                } else {
                                    imageReader?.surface?.let { addTarget(it) }
                                }
                                set(CaptureRequest.CONTROL_MODE, CaptureRequest.CONTROL_MODE_AUTO)
                                set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
                                set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO)
                            }
                            session.setRepeatingRequest(req.build(), null, cameraHandler)
                        } catch (e: Exception) {}
                    }
                    override fun onConfigureFailed(session: CameraCaptureSession) {}
                    override fun onClosed(session: CameraCaptureSession) {}
                }, cameraHandler)
            } catch (e: Exception) {}
        }
    }

    private fun restartCaptureSession() {
        synchronized(cameraStateLock) { captureSession?.close(); captureSession = null }
        startCaptureSession()
    }

    private fun safeCloseCamera() {
        synchronized(cameraStateLock) {
            try {
                captureSession?.close(); captureSession = null
                cameraDevice?.close(); cameraDevice = null
            } catch (e: Exception) {}
        }
    }

    private fun getCameraId(front: Boolean): String {
        val manager = cameraManager!!
        return manager.cameraIdList.first { id ->
            val facing = manager.getCameraCharacteristics(id).get(CameraCharacteristics.LENS_FACING)
            facing == if (front) CameraCharacteristics.LENS_FACING_FRONT else CameraCharacteristics.LENS_FACING_BACK
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ENCODERS
    // ─────────────────────────────────────────────────────────────────────────

    private fun setupEncoders() {
        val w = 1280
        val h = 720 
        
        // FIX: Tell the encoder to output a True Portrait resolution if we are in portrait mode
        val encW = if (isLandscape) 1280 else 720
        val encH = if (isLandscape) 720 else 1280
        
        val videoFmt = MediaFormat.createVideoFormat(VIDEO_MIME, encW, encH).apply {
            setInteger(MediaFormat.KEY_BIT_RATE, VIDEO_BITRATE)
            setInteger(MediaFormat.KEY_FRAME_RATE, FPS)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 2)
            
            // In portrait, we feed raw bytes via CPU. In landscape, we use Surface hardware zero-copy.
            if (isLandscape) {
                setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface)
            } else {
                setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible)
            }
        }
        
        videoEncoder = MediaCodec.createEncoderByType(VIDEO_MIME).apply {
            configure(videoFmt, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            if (isLandscape) encoderSurface = createInputSurface()
            start()
        }

        // Setup the Portrait Middleman (ImageReader)
        if (!isLandscape) {
            imageReader = ImageReader.newInstance(w, h, ImageFormat.YUV_420_888, 2)
            imageReader?.setOnImageAvailableListener({ reader ->
                val image = reader.acquireLatestImage() ?: return@setOnImageAvailableListener
                processPortraitFrame(image)
            }, cameraHandler)
        }

        val minBuf = AudioRecord.getMinBufferSize(SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
        @SuppressLint("MissingPermission")
        audioRecord = AudioRecord(MediaRecorder.AudioSource.MIC, SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, minBuf * 4)
        
        val audioFmt = MediaFormat.createAudioFormat(AUDIO_MIME, SAMPLE_RATE, AUDIO_CHANNELS).apply {
            setInteger(MediaFormat.KEY_BIT_RATE, AUDIO_BITRATE)
            setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, minBuf * 4)
        }
        audioEncoder = MediaCodec.createEncoderByType(AUDIO_MIME).apply {
            configure(audioFmt, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            start()
        }

        restartCaptureSession()
    }

    private fun releaseEncoders() {
        videoEncoder?.stop(); videoEncoder?.release(); videoEncoder = null
        audioEncoder?.stop(); audioEncoder?.release(); audioEncoder = null
        audioRecord?.stop();  audioRecord?.release();  audioRecord  = null
        encoderSurface?.release(); encoderSurface = null
        imageReader?.close(); imageReader = null
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CPU FRAME ROTATION (PORTRAIT ONLY)
    // ─────────────────────────────────────────────────────────────────────────

    private fun processPortraitFrame(image: Image) {
        if (!isStreaming) { image.close(); return }
        try {
            val enc = videoEncoder ?: return
            val inIdx = enc.dequeueInputBuffer(10_000)
            if (inIdx >= 0) {
                // 1. Extract raw data from Camera
                val nv21 = getNV21(image)
                // 2. Physically rotate the pixels
                val rotated = rotateNV21(nv21, image.width, image.height, isFrontCamera)
                
                // 3. Feed the rotated pixels to the Encoder
                val buf = enc.getInputBuffer(inIdx)
                buf?.clear()
                buf?.put(rotated)
                enc.queueInputBuffer(inIdx, 0, rotated.size, image.timestamp / 1000, 0)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Frame rotation error: ${e.message}")
        } finally {
            image.close() // ALWAYS close the image to free memory
        }
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
            try {
                while (isStreaming && rtmpClient.isConnected) {
                    val enc = videoEncoder ?: break
                    val idx = enc.dequeueOutputBuffer(info, 10_000)
                    when {
                        idx == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                            val fmt = enc.outputFormat
                            sps = fmt.getByteBuffer("csd-0")?.let { extractNalu(it) }
                            pps = fmt.getByteBuffer("csd-1")?.let { extractNalu(it) }
                            if (sps != null && pps != null)
                                rtmpClient.sendAvcSequenceHeader(sps!!, pps!!)
                        }
                        idx >= 0 -> {
                            val buf = enc.getOutputBuffer(idx)
                            val isConfig = info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0
                            
                            if (!isConfig && buf != null) {
                                if (sps == null || pps == null) {
                                    enc.releaseOutputBuffer(idx, false)
                                    continue
                                }
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
            } catch (e: Exception) {}
        }.also { it.start() }
    }

    private fun startAudioLoop() {
        rtmpClient.sendAacSequenceHeader(SAMPLE_RATE, AUDIO_CHANNELS)
        audioRecord?.startRecording()
        val info = MediaCodec.BufferInfo()
        val pcm = ByteArray(4096)
        var startPts = -1L

        audioThread = Thread {
            try {
                while (isStreaming && rtmpClient.isConnected) {
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
            } catch (e: Exception) {} 
            finally { try { audioRecord?.stop() } catch (e: Exception) {} }
        }.also { it.start() }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // IMAGE MATH HELPERS
    // ─────────────────────────────────────────────────────────────────────────

    private fun extractNalu(buffer: ByteBuffer): ByteArray {
        val bytes = ByteArray(buffer.remaining())
        buffer.get(bytes)
        var start = 0
        if (bytes.size > 4 && bytes[0].toInt() == 0 && bytes[1].toInt() == 0 && bytes[2].toInt() == 0 && bytes[3].toInt() == 1) start = 4
        else if (bytes.size > 3 && bytes[0].toInt() == 0 && bytes[1].toInt() == 0 && bytes[2].toInt() == 1) start = 3
        return bytes.copyOfRange(start, bytes.size)
    }

    private fun getNV21(image: Image): ByteArray {
        val yPlane = image.planes[0]
        val uPlane = image.planes[1]
        val vPlane = image.planes[2]

        val yBuffer = yPlane.buffer
        val uBuffer = uPlane.buffer
        val vBuffer = vPlane.buffer

        val ySize = yBuffer.remaining()
        val uSize = uBuffer.remaining()
        val vSize = vBuffer.remaining()

        val nv21 = ByteArray(ySize + image.width * image.height / 2)
        yBuffer.get(nv21, 0, ySize)

        if (vPlane.pixelStride == 2 && uPlane.pixelStride == 2 && vPlane.rowStride == uPlane.rowStride) {
            vBuffer.get(nv21, ySize, vSize)
        } else {
            var offset = ySize
            for (row in 0 until image.height / 2) {
                for (col in 0 until image.width / 2) {
                    nv21[offset++] = vBuffer.get(row * vPlane.rowStride + col * vPlane.pixelStride)
                    nv21[offset++] = uBuffer.get(row * uPlane.rowStride + col * uPlane.pixelStride)
                }
            }
        }
        return nv21
    }

private fun rotateNV21(data: ByteArray, width: Int, height: Int, isFront: Boolean): ByteArray {
        val rotated = ByteArray(data.size)
        val ySize = width * height
        var i = 0

        if (!isFront) {
            // Back Camera: 90 degrees Clockwise
            for (x in 0 until width) {
                for (y in height - 1 downTo 0) {
                    rotated[i++] = data[y * width + x]
                }
            }
            var iUv = ySize
            for (x in 0 until width step 2) {
                for (y in height / 2 - 1 downTo 0) {
                    val uvIdx = ySize + (y * width) + x
                    // FIX: Swap U and V bytes to convert NV21 to NV12. 
                    // This fixes the "Blue/Smurf" color distortion.
                    rotated[iUv++] = data[uvIdx + 1] // U
                    rotated[iUv++] = data[uvIdx]     // V
                }
            }
        } else {
            // Front Camera: 270 degrees Clockwise
            for (x in width - 1 downTo 0) {
                for (y in 0 until height) {
                    rotated[i++] = data[y * width + x]
                }
            }
            var iUv = ySize
            for (x in width - 2 downTo 0 step 2) {
                for (y in 0 until height / 2) {
                    val uvIdx = ySize + (y * width) + x
                    // FIX: Swap U and V bytes to convert NV21 to NV12.
                    // This fixes the "Blue/Smurf" color distortion.
                    rotated[iUv++] = data[uvIdx + 1] // U
                    rotated[iUv++] = data[uvIdx]     // V
                }
            }
        }
        return rotated
    }
}