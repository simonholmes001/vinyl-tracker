import SwiftUI

struct CollectionDetailView: View {
    @EnvironmentObject private var libraryViewModel: LibraryViewModel

    private let collectionID: UUID
    private let initialCollection: AlbumCollection
    let onAddAlbum: (Set<UUID>) -> Void
    let onScanAlbum: (Set<UUID>) -> Void

    init(collection: AlbumCollection, onAddAlbum: @escaping (Set<UUID>) -> Void, onScanAlbum: @escaping (Set<UUID>) -> Void) {
        self.collectionID = collection.id
        self.initialCollection = collection
        self.onAddAlbum = onAddAlbum
        self.onScanAlbum = onScanAlbum
    }

    private var collection: AlbumCollection {
        libraryViewModel.collections.first(where: { $0.id == collectionID }) ?? initialCollection
    }

    private var albums: [Album] {
        libraryViewModel.albums(in: collection)
    }

    var body: some View {
        List {
            if collection.albumCount == 0 {
                Section {
                    Text("No albums yet. Use the buttons above to add or scan.")
                        .foregroundColor(.secondary)
                        .padding(.vertical)
                }
            } else {
                Section {
                    ForEach(albums) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            AlbumRowView(album: album)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                libraryViewModel.removeAlbum(album, from: collection)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    onScanAlbum([collectionID])
                } label: {
                    Image(systemName: "camera")
                }

                Button {
                    onAddAlbum([collectionID])
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
