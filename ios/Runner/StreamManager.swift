import Foundation
import AVFoundation
import HaishinKit
import VideoToolbox

final class StreamManager {

    static let shared = StreamManager()

    private let connection = RTMPConnection()
    private lazy var stream = RTMPStream(connection: connection)

    private init() {

        // VIDEO SETTINGS
        stream.videoSettings = VideoCodecSettings(
            videoSize: CGSize(width: 720, height: 1280),
            bitRate: 1_000_000,
            profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel as String
        )

        // AUDIO SETTINGS
        stream.audioSettings = AudioCodecSettings(
            bitRate: 64_000
        )
    }

    func startStream(url: String, streamKey: String) {

        Task {
            do {

                // BACK CAMERA
                if let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .back
                ) {
                    try await stream.attachCamera(camera)
                }

                // MICROPHONE
                if let mic = AVCaptureDevice.default(for: .audio) {
                    try await stream.attachAudio(mic)
                }

                // CONNECT
                connection.connect(url)

                // PUBLISH
                stream.publish(streamKey)

                print("✅ Streaming started")

            } catch {
                print("❌ Stream error: \(error)")
            }
        }
    }

    func stopStream() {
        stream.close()
        connection.close()

        print("🛑 Streaming stopped")
    }
}