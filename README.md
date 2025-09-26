# Vinyl Tracker

Vinyl Tracker is a SwiftUI iOS app for cataloguing a personal vinyl collection. It combines manual data entry, Vision-powered cover recognition, and lightweight JSON persistence to keep your library organised across albums and custom collections.

## Overview
- **Platform:** iOS 17+
- **Language & UI:** Swift 5.9, SwiftUI
- **Architecture:** MVVM with an actor-isolated data layer
- **Persistence:** JSON file stored in Application Support (no Core Data)

## What You Can Do
- Add albums manually with artwork, notes, label, genre, and optional year.
- Scan a sleeve using the device camera to pre-fill title and artist using Vision text recognition.
- Detect duplicates instantly; link an existing album into additional collections instead of re-adding it.
- Create, rename, and delete collections; see per-collection album counts at a glance.
- Filter library views by search term or selected collection, and view album details including membership across collections.
- Capture or pick photos for album artwork and persist them alongside metadata.

## Recent Changes
- `ScannerViewModel` now conforms to `Identifiable`, enabling the scanner sheet to be presented via `.sheet(item:)`.
- `CollectionRepository` remains isolated to the main actor; `LibraryViewModel` and `VinylTrackerApp` now create the repository inside a main-actor context to avoid concurrency violations.
- SwiftUI previews and tests that spin up `CollectionRepository` are annotated with `@MainActor` to mirror runtime behaviour.

## Project Structure
```
VinylTracker/
  VinylTracker.xcodeproj        # Primary Xcode project
  VinylTracker/                 # App target source
    Models/                     # Album and AlbumCollection types
    Services/                   # CollectionRepository & AlbumRecognitionService
    ViewModels/                 # LibraryViewModel, ScannerViewModel
    Views/                      # SwiftUI screens and components
  VinylTrackerTests/            # Unit tests
  VinylTrackerUITests/          # UI tests

VinylTracker_Clean/             # Clean reference snapshot of the project
```

The `VinylTracker` directory is the actively developed target. `VinylTracker_Clean` holds a clean copy of the same app for comparison or onboarding.

## Building & Running
1. Open `VinylTracker/VinylTracker.xcodeproj` in Xcode 15 or later.
2. Select the `VinylTracker` scheme and an iOS 17+ simulator or device.
3. Build (`⌘B`) or run (`⌘R`). The app seeds an empty library on first launch.

## Testing
The project ships with unit and UI tests.
```bash
# From the repo root
xcodebuild test \
  -project VinylTracker/VinylTracker.xcodeproj \
  -scheme VinylTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
```

## Data Storage
`CollectionRepository` persists the album library and collections to `Application Support/VinylTracker/library.json`. The repository is actor-isolated and writes through a background queue; `waitForPersistence()` is available for deterministic tests.

## Contributing Tips
- Keep repository initialisation on the main actor. Inject a mock repository into `LibraryViewModel` when testing off the main thread.
- When presenting `ScannerView`, pass a `ScannerViewModel` instance via `.sheet(item:)`; its `id` property is used for SwiftUI diffing.
- Prefer `LibraryViewModel.makeScannerViewModel()` for creating scanner instances so they share the app’s repository.

## License
This project is licensed under the MIT License. See `LICENSE` for details.
