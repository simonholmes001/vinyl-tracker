import SwiftUI

@main
@MainActor
struct VinylTrackerApp: App {
    @StateObject private var libraryViewModel = LibraryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(libraryViewModel)
        }
    }
}
