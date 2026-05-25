import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var player = AudioPlayerViewModel()
    @State private var isFilePickerPresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                fileSection
                playbackSection
                speedSection
                volumeSection
                Spacer()
            }
            .padding()
            .navigationTitle("Player")
            .fileImporter(
                isPresented: $isFilePickerPresented,
                allowedContentTypes: [.mpeg4Audio, .mp3, .audio],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    player.loadFile(from: url)
                case .failure:
                    break
                }
            }
        }
    }

    private var fileSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(player.fileName ?? "No file selected")
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if let errorMessage = player.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                isFilePickerPresented = true
            } label: {
                Label("Choose MP3 from Files", systemImage: "folder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var playbackSection: some View {
        VStack(spacing: 16) {
            if player.duration > 0 {
                Slider(
                    value: Binding(
                        get: { player.currentTime },
                        set: { player.seek(to: $0) }
                    ),
                    in: 0...player.duration
                )

                HStack {
                    Text(formatTime(player.currentTime))
                    Spacer()
                    Text(formatTime(player.duration))
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 24) {
                Button {
                    player.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .disabled(player.fileName == nil)

                Button {
                    player.togglePlayback()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                }
                .disabled(player.fileName == nil)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var speedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Playback Speed", systemImage: "gauge.with.dots.needle.67percent")
                Spacer()
                Text(speedLabel(player.playbackSpeed))
                    .font(.headline.monospacedDigit())
            }

            Slider(
                value: $player.playbackSpeed,
                in: 0.5...2.0,
                step: 0.25
            )
            .disabled(player.fileName == nil)

            HStack {
                Text("0.5×")
                Spacer()
                Text("2×")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var volumeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Volume", systemImage: "speaker.wave.2.fill")
                Spacer()
                Text("\(Int(player.volume * 100))%")
                    .font(.headline.monospacedDigit())
            }

            Slider(value: $player.volume, in: 0...1)
                .disabled(player.fileName == nil)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func speedLabel(_ speed: Float) -> String {
        speed == 1.0 ? "1×" : String(format: "%.2g×", speed)
    }
}

#Preview {
    ContentView()
}
