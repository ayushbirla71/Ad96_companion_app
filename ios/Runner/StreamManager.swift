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



// import Foundation
// import AVFoundation
// import VideoToolbox

// import HaishinKit
// import RTMPHaishinKit

// final class StreamManager {

//     static let shared = StreamManager()

//     private let connection = RTMPConnection()
//     private let mixer = MediaMixer()
//     private lazy var stream = RTMPStream(connection: connection)

//     private init() {

//         Task {
//             do {

//                 // MARK: Add Stream Output
//                 try await mixer.addOutput(stream)

//                 // MARK: Video Settings
//                 try await stream.setVideoSettings(
//                     VideoCodecSettings(
//                         videoSize: CGSize(width: 720, height: 1280),
//                         bitRate: 1_000_000,
//                         profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel as String
//                     )
//                 )

//                 // MARK: Audio Settings
//                 try await stream.setAudioSettings(
//                     AudioCodecSettings(
//                         bitRate: 64_000
//                     )
//                 )

//             } catch {
//                 print("❌ Init Error: \(error)")
//             }
//         }
//     }

//     func startStream(url: String, streamKey: String) {

//         Task {
//             do {

//                 // MARK: Camera
//                 if let camera = AVCaptureDevice.default(
//                     .builtInWideAngleCamera,
//                     for: .video,
//                     position: .back
//                 ) {

//                     try await mixer.attachVideo(camera, track: 0)
//                 }

//                 // MARK: Microphone
//                 if let mic = AVCaptureDevice.default(for: .audio) {

//                     try await mixer.attachAudio(mic, track: 0)
//                 }

//                 // MARK: Connect
//                 try await connection.connect(url)

//                 // MARK: Publish
//                 try await stream.publish(streamKey)

//                 print("✅ Streaming Started")

//             } catch {
//                 print("❌ Stream Error: \(error)")
//             }
//         }
//     }

//     func stopStream() {

//         Task {
//             do {

//                 try await stream.close()
//                 try await connection.close()

//                 print("🛑 Streaming Stopped")

//             } catch {
//                 print("❌ Stop Error: \(error)")
//             }
//         }
//     }
// }


import Foundation
import UIKit
import AVFoundation
import VideoToolbox
import MetalKit
import HaishinKit
import RTMPHaishinKit

final class StreamManager {

    static let shared = StreamManager()

    let hkView = MTHKView(frame: .zero)
    private let connection = RTMPConnection()
    private let mixer = MediaMixer()
    private lazy var stream = RTMPStream(connection: connection)

    private var isStreaming = false
    private var isFrontFacing = false
    private var isLandscape = false

    private init() {
        hkView.videoGravity = .resizeAspectFill
        hkView.backgroundColor = .black
        Task {
            try? await mixer.addOutput(hkView)
            try? await mixer.addOutput(stream)
        }
    }

    ////////////////////////////////////////////////////////////
    /// 1. PREVIEW & SETUP
    ////////////////////////////////////////////////////////////

    func startPreview(isFront: Bool, isLandscape: Bool) {
        #if targetEnvironment(simulator)
        print("❌ ERROR: Camera preview is not supported on the iOS Simulator.")
        return
        #else
        self.isFrontFacing = isFront
        self.isLandscape = isLandscape
        
        Task {
            let video = await AVCaptureDevice.requestAccess(for: .video)
            let audio = await AVCaptureDevice.requestAccess(for: .audio)
            guard video && audio else {
                print("❌ Permissions denied")
                return
            }

            try await configureSettings()
            try await attachCamera()
            try await attachMicrophone()
            
            await mixer.startRunning()
            print("✅ Preview Started")
        }
        #endif
    }

    func switchCamera(isFront: Bool) {
        #if !targetEnvironment(simulator)
        self.isFrontFacing = isFront
        Task {
            try await attachCamera()
        }
        #endif
    }

    func setOrientation(isLandscape: Bool) {
        self.isLandscape = isLandscape
        Task {
            try await configureSettings()
        }
    }

    ////////////////////////////////////////////////////////////
    /// HARDWARE ATTACHMENT
    ////////////////////////////////////////////////////////////

    private func attachCamera() async throws {
        let position: AVCaptureDevice.Position = isFrontFacing ? .front : .back
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            try await mixer.attachVideo(camera, track: 0)
        }
    }

    private func attachMicrophone() async throws {
        if let mic = AVCaptureDevice.default(for: .audio) {
            try await mixer.attachAudio(mic, track: 0)
        }
    }

    ////////////////////////////////////////////////////////////
    /// CONFIGURATION
    ////////////////////////////////////////////////////////////

    private func configureSettings() async throws {
        let width: CGFloat = isLandscape ? 1280 : 720
        let height: CGFloat = isLandscape ? 720 : 1280
        
        let orientation: AVCaptureVideoOrientation = isLandscape ? .landscapeRight : .portrait
        await mixer.setVideoOrientation(orientation)

        try await stream.setVideoSettings(
            VideoCodecSettings(
                videoSize: CGSize(width: width, height: height),
                bitRate: 1_200_000,
                profileLevel: kVTProfileLevel_H264_Main_AutoLevel as String
            )
        )

        try await stream.setAudioSettings(AudioCodecSettings(bitRate: 64_000))
    }

    ////////////////////////////////////////////////////////////
    /// 2. START PUBLISHING
    ////////////////////////////////////////////////////////////

    func startStream(url: String, streamKey: String) {
        if isStreaming { return }

        #if targetEnvironment(simulator)
        print("❌ ERROR: Cannot publish RTMP stream from iOS Simulator.")
        return
        #else
        Task {
            do {
                let connectResp = try await connection.connect(url)
                print("✅ RTMP Connected: \(connectResp.status?.code ?? "")")

                try await Task.sleep(nanoseconds: 2_000_000_000)

                let pubResp = try await stream.publish(streamKey)
                print("✅ STREAM STARTED: \(pubResp.status?.code ?? "")")
                
                isStreaming = true
            } catch {
                print("❌ ERROR => \(error)")
            }
        }
        #endif
    }

    ////////////////////////////////////////////////////////////
    /// STOP STREAM
    ////////////////////////////////////////////////////////////

    func stopStream() {
        Task {
            do {
                try await mixer.attachVideo(nil)
                try await mixer.attachAudio(nil)
                await mixer.stopRunning()
                
                try await stream.close()
                try await connection.close()
                isStreaming = false
                print("🛑 STREAM STOPPED")
            } catch {
                print("❌ STOP ERROR => \(error)")
            }
        }
    }
}