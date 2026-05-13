// import Foundation
// import AVFoundation
// import HaishinKit
// import VideoToolbox

// final class StreamManager {

//     static let shared = StreamManager()

//     private let connection = RTMPConnection()
//     private lazy var stream = RTMPStream(connection: connection)

//     private init() {

//         // VIDEO SETTINGS
//         stream.videoSettings = VideoCodecSettings(
//             videoSize: CGSize(width: 720, height: 1280),
//             bitRate: 1_000_000,
//             profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel as String
//         )

//         // AUDIO SETTINGS
//         stream.audioSettings = AudioCodecSettings(
//             bitRate: 64_000
//         )
//     }

//     func startStream(url: String, streamKey: String) {

//         Task {
//             do {

//                 // BACK CAMERA
//                 if let camera = AVCaptureDevice.default(
//                     .builtInWideAngleCamera,
//                     for: .video,
//                     position: .back
//                 ) {
//                     try await stream.attachCamera(camera)
//                 }

//                 // MICROPHONE
//                 if let mic = AVCaptureDevice.default(for: .audio) {
//                     try await stream.attachAudio(mic)
//                 }

//                 // CONNECT
//                 connection.connect(url)

//                 // PUBLISH
//                 stream.publish(streamKey)

//                 print("✅ Streaming started")

//             } catch {
//                 print("❌ Stream error: \(error)")
//             }
//         }
//     }

//     func stopStream() {
//         stream.close()
//         connection.close()

//         print("🛑 Streaming stopped")
//     }
// }



import Foundation
import AVFoundation
import VideoToolbox

import HaishinKit
import RTMPHaishinKit

final class StreamManager {

    static let shared = StreamManager()

    private let connection = RTMPConnection()
    private let mixer = MediaMixer()
    private lazy var stream = RTMPStream(connection: connection)

    private init() {

        Task {
            do {

                // MARK: Add Stream Output
                try await mixer.addOutput(stream)

                // MARK: Video Settings
                try await stream.setVideoSettings(
                    VideoCodecSettings(
                        videoSize: CGSize(width: 720, height: 1280),
                        bitRate: 1_000_000,
                        profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel as String
                    )
                )

                // MARK: Audio Settings
                try await stream.setAudioSettings(
                    AudioCodecSettings(
                        bitRate: 64_000
                    )
                )

            } catch {
                print("❌ Init Error: \(error)")
            }
        }
    }

    func startStream(url: String, streamKey: String) {

        Task {
            do {

                // MARK: Camera
                if let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .back
                ) {

                    try await mixer.attachVideo(camera, track: 0)
                }

                // MARK: Microphone
                if let mic = AVCaptureDevice.default(for: .audio) {

                    try await mixer.attachAudio(mic, track: 0)
                }

                // MARK: Connect
                try await connection.connect(url)

                // MARK: Publish
                try await stream.publish(streamKey)

                print("✅ Streaming Started")

            } catch {
                print("❌ Stream Error: \(error)")
            }
        }
    }

    func stopStream() {

        Task {
            do {

                try await stream.close()
                try await connection.close()

                print("🛑 Streaming Stopped")

            } catch {
                print("❌ Stop Error: \(error)")
            }
        }
    }
}