package com.demokrito.cms_app

import android.util.Log
import java.io.*
import java.net.Socket

class RtmpClient {
    private var socket: Socket? = null
    private var output: DataOutputStream? = null
    private var input: DataInputStream? = null
    private var isConnected = false

    private val chunkSize = 128
    private val streamId = 1
    private val chunkStreamId = 4

    companion object {
        private const val TAG = "RtmpClient"
        private const val RTMP_VERSION: Byte = 3
        private const val DEFAULT_PORT = 1935
    }

    fun connect(rtmpUrl: String): Boolean {
        return try {
            val uri = parseRtmpUrl(rtmpUrl)
            val host = uri["host"] ?: return false
            val port = uri["port"]?.toIntOrNull() ?: DEFAULT_PORT
            val app = uri["app"] ?: return false
            val streamKey = uri["streamKey"] ?: return false

            socket = Socket(host, port)
            socket!!.tcpNoDelay = true
            output = DataOutputStream(BufferedOutputStream(socket!!.getOutputStream()))
            input = DataInputStream(BufferedInputStream(socket!!.getInputStream()))

            performHandshake()
            sendConnectCommand(app, rtmpUrl)
            sendCreateStream()
            sendPublish(streamKey)

            isConnected = true
            Log.d(TAG, "RTMP connected to $host:$port/$app/$streamKey")
            true
        } catch (e: Exception) {
            Log.e(TAG, "RTMP connect failed: ${e.message}", e)
            false
        }
    }

    fun sendVideoData(data: ByteArray, pts: Long, isKeyFrame: Boolean) {
        if (!isConnected) return
        try {
            val frameType = if (isKeyFrame) 0x10 else 0x20
            val payload = ByteArray(data.size + 5)
            payload[0] = (frameType or 0x07).toByte()
            payload[1] = 0x01
            payload[2] = 0x00
            payload[3] = 0x00
            payload[4] = 0x00
            System.arraycopy(data, 0, payload, 5, data.size)
            sendRtmpPacket(0x09, pts, payload)
        } catch (e: Exception) {
            Log.e(TAG, "Send video error: ${e.message}")
        }
    }

    fun sendAudioData(data: ByteArray, pts: Long) {
        if (!isConnected) return
        try {
            val payload = ByteArray(data.size + 2)
            payload[0] = 0xAF.toByte()
            payload[1] = 0x01
            System.arraycopy(data, 0, payload, 2, data.size)
            sendRtmpPacket(0x08, pts, payload)
        } catch (e: Exception) {
            Log.e(TAG, "Send audio error: ${e.message}")
        }
    }

    fun sendAvcSequenceHeader(sps: ByteArray, pps: ByteArray) {
        if (!isConnected) return
        try {
            val payload = buildAvcSequenceHeader(sps, pps)
            sendRtmpPacket(0x09, 0L, payload)
        } catch (e: Exception) {
            Log.e(TAG, "Send SPS/PPS error: ${e.message}")
        }
    }

    fun sendAacSequenceHeader(sampleRate: Int, channels: Int) {
        if (!isConnected) return
        try {
            val payload = buildAacSequenceHeader(sampleRate, channels)
            sendRtmpPacket(0x08, 0L, payload)
        } catch (e: Exception) {
            Log.e(TAG, "Send AAC header error: ${e.message}")
        }
    }

    fun disconnect() {
        try {
            isConnected = false
            output?.close()
            input?.close()
            socket?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Disconnect error: ${e.message}")
        } finally {
            socket = null
            output = null
            input = null
        }
    }

    // ─── HANDSHAKE ─────────────────────────────────────────────────────────────

    private fun performHandshake() {
        output!!.writeByte(RTMP_VERSION.toInt())

        val c1 = ByteArray(1536)
        val time = (System.currentTimeMillis() / 1000).toInt()
        c1[0] = (time shr 24).toByte()
        c1[1] = (time shr 16).toByte()
        c1[2] = (time shr 8).toByte()
        c1[3] = time.toByte()
        java.util.Random().nextBytes(c1.copyOfRange(8, 1536))
        output!!.write(c1)
        output!!.flush()

        input!!.readByte()
        val s1 = ByteArray(1536)
        input!!.readFully(s1)
        val s2 = ByteArray(1536)
        input!!.readFully(s2)

        output!!.write(s1)
        output!!.flush()
    }

    // ─── RTMP COMMANDS ─────────────────────────────────────────────────────────

    private fun sendConnectCommand(app: String, tcUrl: String) {
        val amf = buildAmf {
            string("connect")
            number(1.0)
            objectStart()
            field("app", app)
            field("type", "nonprivate")
            field("tcUrl", tcUrl)
            field("flashVer", "FMLE/3.0")
            objectEnd()
        }
        sendRtmpPacket(0x14, 0L, amf, chunkStreamId = 3, streamId = 0)
        readResponses(1)
    }

    private fun sendCreateStream() {
        val amf = buildAmf {
            string("createStream")
            number(2.0)
            null_()
        }
        sendRtmpPacket(0x14, 0L, amf, chunkStreamId = 3, streamId = 0)
        readResponses(1)
    }

    private fun sendPublish(streamKey: String) {
        val amf = buildAmf {
            string("publish")
            number(0.0)
            null_()
            string(streamKey)
            string("live")
        }
        sendRtmpPacket(0x14, 0L, amf, chunkStreamId = 4, streamId = 1)
        readResponses(1)
    }

    // ─── PACKET WRITER ─────────────────────────────────────────────────────────

    private fun sendRtmpPacket(
        messageType: Int,
        timestamp: Long,
        payload: ByteArray,
        chunkStreamId: Int = this.chunkStreamId,
        streamId: Int = this.streamId,
    ) {
        val out = output ?: return
        var offset = 0

        while (offset < payload.size) {
            val end = minOf(offset + chunkSize, payload.size)
            val chunkPayload = payload.copyOfRange(offset, end)
            val isFirst = offset == 0

            if (isFirst) {
                out.writeByte(chunkStreamId and 0x3F)
                writeUInt24(out, timestamp.toInt() and 0xFFFFFF)
                writeUInt24(out, payload.size)
                out.writeByte(messageType)
                writeUInt32LE(out, streamId)
            } else {
                out.writeByte(0xC0 or (chunkStreamId and 0x3F))
            }

            out.write(chunkPayload)
            offset += chunkSize
        }
        out.flush()
    }

    private fun readResponses(count: Int) {
        try {
            repeat(count) {
                val buf = ByteArray(512)
                if (input!!.available() > 0) input!!.read(buf)
                Thread.sleep(50)
            }
        } catch (_: Exception) {}
    }

    // ─── AMF BUILDER ───────────────────────────────────────────────────────────

    private fun buildAmf(block: AmfBuilder.() -> Unit): ByteArray {
        val builder = AmfBuilder()
        builder.block()
        return builder.toByteArray()
    }

    inner class AmfBuilder {
        private val buf = ByteArrayOutputStream()
        private val out = DataOutputStream(buf)

        fun string(s: String) {
            out.writeByte(0x02)
            out.writeShort(s.length)
            out.write(s.toByteArray())
        }

        fun number(d: Double) {
            out.writeByte(0x00)
            out.writeDouble(d)
        }

        fun null_() { out.writeByte(0x05) }

        fun objectStart() { out.writeByte(0x03) }

        fun objectEnd() {
            out.writeByte(0x00)
            out.writeByte(0x00)
            out.writeByte(0x09)
        }

        fun field(key: String, value: String) {
            out.writeShort(key.length)
            out.write(key.toByteArray())
            string(value)
        }

        fun toByteArray(): ByteArray = buf.toByteArray()
    }

    // ─── SEQUENCE HEADERS ──────────────────────────────────────────────────────

    private fun buildAvcSequenceHeader(sps: ByteArray, pps: ByteArray): ByteArray {
        val buf = ByteArrayOutputStream()
        val out = DataOutputStream(buf)
        out.writeByte(0x17)
        out.writeByte(0x00)
        out.writeByte(0x00); out.writeByte(0x00); out.writeByte(0x00)
        out.writeByte(0x01)
        out.writeByte(sps[1].toInt())
        out.writeByte(sps[2].toInt())
        out.writeByte(sps[3].toInt())
        out.writeByte(0xFF.toByte().toInt())
        out.writeByte(0xE1.toByte().toInt())
        out.writeShort(sps.size)
        out.write(sps)
        out.writeByte(0x01)
        out.writeShort(pps.size)
        out.write(pps)
        return buf.toByteArray()
    }

    private fun buildAacSequenceHeader(sampleRate: Int, channels: Int): ByteArray {
        val rateIndex = when (sampleRate) {
            96000 -> 0; 88200 -> 1; 64000 -> 2; 48000 -> 3
            44100 -> 4; 32000 -> 5; 24000 -> 6; 22050 -> 7
            16000 -> 8; 12000 -> 9; 11025 -> 10; 8000 -> 11
            else -> 4
        }
        val word = (0x10 shl 11) or (rateIndex shl 7) or (channels shl 3)
        return byteArrayOf(
            0xAF.toByte(),
            0x00,
            (word shr 8).toByte(),
            (word and 0xFF).toByte()
        )
    }

    // ─── UTILS ─────────────────────────────────────────────────────────────────

    private fun writeUInt24(out: DataOutputStream, v: Int) {
        out.writeByte((v shr 16) and 0xFF)
        out.writeByte((v shr 8) and 0xFF)
        out.writeByte(v and 0xFF)
    }

    private fun writeUInt32LE(out: DataOutputStream, v: Int) {
        out.writeByte(v and 0xFF)
        out.writeByte((v shr 8) and 0xFF)
        out.writeByte((v shr 16) and 0xFF)
        out.writeByte((v shr 24) and 0xFF)
    }

    private fun parseRtmpUrl(url: String): Map<String, String> {
        val clean = url.removePrefix("rtmp://")
        val hostAndRest = clean.split("/", limit = 2)
        val hostPort = hostAndRest[0].split(":")
        val pathParts = hostAndRest.getOrNull(1)?.split("/", limit = 2)
        return mapOf(
            "host"      to hostPort[0],
            "port"      to (hostPort.getOrNull(1) ?: "1935"),
            "app"       to (pathParts?.getOrNull(0) ?: "live"),
            "streamKey" to (pathParts?.getOrNull(1) ?: "")
        )
    }
}