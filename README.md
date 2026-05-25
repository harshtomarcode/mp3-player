# Folder Player

A simple, ad-free iOS MP3 player for personal audio files stored in the iPhone **Files** app (including downloads saved in Folders).

## Features

- Browse and open MP3 files from the Files app
- Play, pause, stop, and scrub through the track
- Adjust playback speed from **0.5× to 2×** in **0.25×** steps
- Control in-app volume from 0% to 100%

## Requirements

- macOS with **Xcode 15** or later
- iPhone or iPad running **iOS 17** or later
- An Apple Developer account (free or paid) to run the app on a physical device

## Getting Started

1. Clone this repository.
2. Open `FolderPlayer/FolderPlayer.xcodeproj` in Xcode.
3. Select the **FolderPlayer** target → **Signing & Capabilities**.
4. Set your **Team** and update the **Bundle Identifier** if needed (default: `com.example.FolderPlayer`).
5. Connect your iPhone or choose a simulator, then press **Run** (⌘R).

## Using the App

1. Tap **Choose MP3 from Files**.
2. Navigate to your downloaded MP3 (e.g. **On My iPhone** → **Downloads** or any folder in Files).
3. Select the file to load it.
4. Use the play/pause and stop controls.
5. Drag the **Playback Speed** slider to change speed (0.5×, 0.75×, 1×, 1.25×, 1.5×, 1.75×, 2×).
6. Drag the **Volume** slider to adjust playback volume.

## Project Structure

```
FolderPlayer/
├── FolderPlayer.xcodeproj
└── FolderPlayer/
    ├── FolderPlayerApp.swift      # App entry point
    ├── ContentView.swift          # Main UI
    ├── AudioPlayerViewModel.swift # AVAudioPlayer playback logic
    └── Assets.xcassets
```

## Technical Notes

- Uses **SwiftUI** and **AVFoundation** (`AVAudioPlayer`) for audio playback.
- File access uses the system document picker (`.fileImporter`), which works with files stored anywhere in the Files app, including third-party cloud providers and local folders.
- Speed changes apply immediately during playback via `enableRate` and the `rate` property.
- Volume control adjusts the player’s output level (0.0–1.0), independent of the device’s hardware volume buttons.

## License

For personal use.
