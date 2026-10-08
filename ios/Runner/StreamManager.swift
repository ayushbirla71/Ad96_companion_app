import Foundation
import UIKit
import AVFoundation
import VideoToolbox
import MetalKit
import Flutter
import HaishinKit
import RTMPHaishinKit

/// Errors surfaced to Flutter as `FlutterError(code:message:)`.
enum StreamError: Error {
    case simulator
    case permissionDenied
    case previewFailed(String)
    case alreadyStreaming
    case connectFailed(String)

    var flutterError: FlutterError {
        switch self {
        case .simulator:
            return FlutterError(code: "SIMULATOR", message: "Camera streaming is not supported on the iOS Simulator.", details: nil)
        case .permissionDenied:
            return FlutterError(code: "PERMISSION_DENIED", message: "Camera or microphone permission denied.", details: nil)
        case .previewFailed(let reason):
            return FlutterError(code: "PREVIEW_FAILED", message: reason, details: nil)
        case .alreadyStreaming:
            return FlutterError(code: "ALREADY_STREAMING", message: "A stream is already running.", details: nil)
        case .connectFailed(let reason):
            return FlutterError(code: "CONNECT_FAILED", message: reason, details: nil)
        }
    }
}

final class StreamManager {

    static let shared = StreamManager()

    let hkView = MTHKView(frame: .zero)
    private let connection = RTMPConnection()
    private let mixer = MediaMixer()
    private lazy var stream = RTMPStream(connection: connection)
    private var setupTask: Task<Void, Never>?

    /// Set before connecting, so a second start can never overlap the first.
    private var isStreaming = false
    private var isStopping = false
    private var previewRunning = false
    private var isFrontFacing = false
    private var isLandscape = false

    private var stopTask: Task<Void, Never>?
    private var monitorTask: Task<Void, Never>?

    /// Events for Flutter (`streaming_events` EventChannel).
    var eventSink: FlutterEventSink?

    private init() {
        hkView.videoGravity = .resizeAspectFill
        hkView.backgroundColor = .black
        setupTask = Task {
            try? await mixer.addOutput(hkView)
            try? await mixer.addOutput(stream)
        }
        observeSystemEvents()
    }

    // MARK: - Events to Flutter

    func emit(_ event: String, reason: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(["event": event, "reason": reason ?? NSNull()])
        }
    }

    // MARK: - 1. Preview & setup

    /// Returns once permissions are resolved and the preview is running.
    func startPreview(isFront: Bool, isLandscape: Bool) async throws {
        #if targetEnvironment(simulator)
        throw StreamError.simulator
        #else
        self.isFrontFacing = isFront
        self.isLandscape = isLandscape

        await setupTask?.value

        let video = await AVCaptureDevice.requestAccess(for: .video)
        let audio = await AVCaptureDevice.requestAccess(for: .audio)
        guard video && audio else { throw StreamError.permissionDenied }

        do {
            try await configureSettings()
            try await attachCamera()
            try await attachMicrophone()
            await mixer.startRunning()
            previewRunning = true
        } catch {
            throw StreamError.previewFailed("\(error)")
        }
        #endif
    }

    func switchCamera(isFront: Bool) async throws {
        #if !targetEnvironment(simulator)
        self.isFrontFacing = isFront
        do {
            try await attachCamera()
        } catch {
            throw StreamError.previewFailed("\(error)")
        }
        #endif
    }

    func setOrientation(isLandscape: Bool) async throws {
        self.isLandscape = isLandscape
        do {
            try await configureSettings()
        } catch {
            throw StreamError.previewFailed("\(error)")
        }
    }

    // MARK: - Hardware attachment

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

    // MARK: - Configuration

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

    // MARK: - 2. Publish

    /// Returns only after the RTMP connection is up and publishing has begun.
    func startStream(url: String, streamKey: String) async throws {
        #if targetEnvironment(simulator)
        throw StreamError.simulator
        #else
        if isStreaming { throw StreamError.alreadyStreaming }
        isStreaming = true
        isStopping = false
        emit("connecting")

        do {
            _ = try await connection.connect(url)

            // Give the server a moment between connect and publish.
            try await Task.sleep(nanoseconds: 2_000_000_000)
            if isStopping { throw CancellationError() }

            _ = try await stream.publish(streamKey)
            if isStopping { throw CancellationError() }

            startMonitor()
            emit("live")
        } catch {
            let cancelledByStop = isStopping
            isStreaming = false
            try? await stream.close()
            try? await connection.close()
            if !cancelledByStop {
                emit("failed", reason: "\(error)")
            }
            throw StreamError.connectFailed("\(error)")
        }
        #endif
    }

    /// Watches the RTMP connection so a server-side drop reaches Flutter
    /// instead of leaving the UI showing LIVE.
    private func startMonitor() {
        monitorTask?.cancel()
        monitorTask = Task { [weak self] in
            guard let self = self else { return }
            for await status in await self.connection.status {
                if Task.isCancelled { return }
                guard self.isStreaming && !self.isStopping else { continue }

                if status.code == RTMPConnection.Code.connectClosed.rawValue
                    || status.code == RTMPConnection.Code.connectFailed.rawValue {
                    self.emit("failed", reason: "RTMP connection lost: \(status.code)")
                    await self.stopStream()
                    return
                }
            }
        }
    }

    // MARK: - 3. Stop

    /// Idempotent and awaitable: concurrent callers share one stop run.
    /// Releases the stream, the camera and the microphone.
    func stopStream() async {
        if let running = stopTask {
            await running.value
            return
        }
        let task = Task { await self.performStop() }
        stopTask = task
        await task.value
        stopTask = nil
    }

    private func performStop() async {
        isStopping = true
        monitorTask?.cancel()
        monitorTask = nil
        let wasStreaming = isStreaming

        try? await stream.close()
        try? await connection.close()
        try? await mixer.attachVideo(nil)
        try? await mixer.attachAudio(nil)
        await mixer.stopRunning()

        isStreaming = false
        previewRunning = false
        isStopping = false
        if wasStreaming { emit("stopped") }
    }

    /// For `applicationWillTerminate`: blocks briefly so the stop can finish.
    func stopStreamSync(timeout: TimeInterval = 1.5) {
        guard isStreaming || previewRunning else { return }
        let done = DispatchSemaphore(value: 0)
        Task {
            await self.stopStream()
            done.signal()
        }
        _ = done.wait(timeout: .now() + timeout)
    }

    // MARK: - System events

    private func observeSystemEvents() {
        let center = NotificationCenter.default

        center.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleBackground()
        }

        // Phone call, Siri, another app taking the audio session.
        center.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard
                let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                AVAudioSession.InterruptionType(rawValue: raw) == .began
            else { return }
            self?.handleInterruption(reason: "audio-interrupted")
        }
    }

    /// The camera is cut when the app is backgrounded, so end the session
    /// cleanly instead of leaving a dead RTMP publish behind.
    private func handleBackground() {
        guard isStreaming || previewRunning else { return }
        emit("interrupted", reason: "background")

        let application = UIApplication.shared
        var taskId = UIBackgroundTaskIdentifier.invalid
        taskId = application.beginBackgroundTask(withName: "stop-stream") {
            application.endBackgroundTask(taskId)
        }
        Task {
            await self.stopStream()
            application.endBackgroundTask(taskId)
        }
    }

    private func handleInterruption(reason: String) {
        guard isStreaming || previewRunning else { return }
        emit("interrupted", reason: reason)
        Task { await self.stopStream() }
    }
}
