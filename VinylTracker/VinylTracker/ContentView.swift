import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var libraryViewModel: LibraryViewModel
    @State private var showingAddAlbum = false
    @State private var activeScannerModel: ScannerViewModel?
    @State private var preselectedCollectionIDs: Set<UUID> = []

    var body: some View {
        TabView {
            AlbumLibraryView(
                onAddAlbum: handleAddAlbum,
                onScanAlbum: handleScanAlbum
            )
            .tabItem {
                Label("Library", systemImage: "opticaldisc")
            }

            CollectionListView(
                onAddAlbum: handleAddAlbum,
                onScanAlbum: handleScanAlbum
            )
            .tabItem {
                Label("Collections", systemImage: "square.grid.2x2")
            }
        }
        .sheet(isPresented: $showingAddAlbum) {
            NavigationStack {
                AddAlbumView(
                    preselectedCollections: Array(preselectedCollectionIDs)
                ) {
                    showingAddAlbum = false
                }
            }
            .environmentObject(libraryViewModel)
        }
        .sheet(item: $activeScannerModel) { scannerModel in
            NavigationStack {
                ScannerView(
                    viewModel: scannerModel,
                    preselectedCollections: Array(preselectedCollectionIDs)
                ) {
                    activeScannerModel = nil
                }
            }
            .environmentObject(libraryViewModel)
        }
    }

    private func handleAddAlbum(selectedCollectionID: Set<UUID>) {
        preselectedCollectionIDs = selectedCollectionID
        showingAddAlbum = true
    }

    private func handleScanAlbum(selectedCollectionID: Set<UUID>) {
        preselectedCollectionIDs = selectedCollectionID
        activeScannerModel = libraryViewModel.makeScannerViewModel()
    }
}
