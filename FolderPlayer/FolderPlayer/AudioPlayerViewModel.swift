import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioPlayerViewModel: NSObject, ObservableObject {
    @Published private(set) var fileName: String?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var errorMessage: String?
    @Published var playbackSpeed: Float = 1.0 {
        didSet {
            let snapped = round(playbackSpeed * 4) / 4
            if abs(snapped - playbackSpeed) > 0.001 {
                playbackSpeed = snapped
                return
            }
            applyPlaybackSpeed()
        }
    }
    @Published var volume: Float = 1.0 {
        didSet { player?.volume = volume }
    }

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private var securityScopedURL: URL?

    func loadFile(from url: URL) {
        stopProgressTimer()
        stopSecurityScopedAccess()
        errorMessage = nil

        let didStartAccess = url.startAccessingSecurityScopedResource()
        if didStartAccess {
            securityScopedURL = url
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.enableRate = true
            audioPlayer.prepareToPlay()
            audioPlayer.volume = volume
            audioPlayer.rate = playbackSpeed

            player = audioPlayer
            fileName = url.lastPathComponent
            duration = audioPlayer.duration
            currentTime = 0
            isPlaying = false
        } catch {
            stopSecurityScopedAccess()
            player = nil
            fileName = nil
            duration = 0
            currentTime = 0
            isPlaying = false
            errorMessage = "Could not open this audio file."
        }
    }

    func togglePlayback() {
        guard let player else { return }

        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopProgressTimer()
        } else {
            player.enableRate = true
            player.rate = playbackSpeed
            player.play()
            isPlaying = true
            startProgressTimer()
        }
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
        player?.prepareToPlay()
        currentTime = 0
        isPlaying = false
        stopProgressTimer()
    }

    func seek(to time: TimeInterval) {
        guard let player else { return }
        let clamped = min(max(time, 0), duration)
        player.currentTime = clamped
        currentTime = clamped
    }

    private func applyPlaybackSpeed() {
        guard let player else { return }
        let wasPlaying = player.isPlaying
        player.enableRate = true
        player.rate = playbackSpeed
        if wasPlaying {
            player.play()
        }
    }

    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                self.currentTime = player.currentTime
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func stopSecurityScopedAccess() {
        securityScopedURL?.stopAccessingSecurityScopedResource()
        securityScopedURL = nil
    }

    deinit {
        progressTimer?.invalidate()
        securityScopedURL?.stopAccessingSecurityScopedResource()
    }
}

extension AudioPlayerViewModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentTime = self.duration
            self.stopProgressTimer()
        }
    }
}
