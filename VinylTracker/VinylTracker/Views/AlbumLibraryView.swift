import SwiftUI

struct AlbumLibraryView: View {
    @EnvironmentObject private var viewModel: LibraryViewModel

    let onAddAlbum: (Set<UUID>) -> Void
    let onScanAlbum: (Set<UUID>) -> Void

    @State private var albumPendingDeletion: Album?

    private var activeCollection: AlbumCollection? {
        guard let id = viewModel.selectedCollectionID else { return nil }
        return viewModel.collections.first { $0.id == id }
    }

    private var navigationTitle: String {
        if let collection = activeCollection {
            return collection.name
        }
        return "Library"
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredAlbums.isEmpty {
                    EmptyLibraryState(
                        onAddAlbum: { onAddAlbum(activeCollectionIDs()) },
                        onScanAlbum: { onScanAlbum(activeCollectionIDs()) }
                    )
                } else {
                    List {
                        if let duplicate = viewModel.duplicateMatch {
                            DuplicateBanner(duplicate: duplicate) {
                                viewModel.clearDuplicateNotice()
                            }
                        }

                        ForEach(viewModel.filteredAlbums) { album in
                            NavigationLink(destination: AlbumDetailView(album: album)) {
                                AlbumRowView(album: album)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    albumPendingDeletion = album
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        onScanAlbum(activeCollectionIDs())
                    } label: {
                        Image(systemName: "camera")
                    }

                    Button {
                        onAddAlbum(activeCollectionIDs())
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    CollectionFilterMenu(
                        collections: viewModel.collections,
                        selectedID: viewModel.selectedCollectionID
                    ) { selection in
                        viewModel.selectedCollectionID = selection
                    }
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search albums")
            .alert("Delete Album", isPresented: Binding(
                get: { albumPendingDeletion != nil },
                set: { newValue in if !newValue { albumPendingDeletion = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let album = albumPendingDeletion {
                        viewModel.removeAlbum(album)
                    }
                    albumPendingDeletion = nil
                }
                Button("Cancel", role: .cancel) {
                    albumPendingDeletion = nil
                }
            } message: {
                if let album = albumPendingDeletion {
                    Text("Are you sure you want to remove \(album.title) by \(album.artist)?")
                }
            }
        }
    }

    private func activeCollectionIDs() -> Set<UUID> {
        if let collection = activeCollection {
            return [collection.id]
        }
        return []
    }
}

private struct EmptyLibraryState: View {
    let onAddAlbum: () -> Void
    let onScanAlbum: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "music.quarternote.3")
                .font(.system(size: 72))
                .foregroundColor(.secondary)

            Text("Your library is empty")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start by adding albums manually or scanning a cover. We'll keep track of duplicates for you.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 16) {
                Button(action: onAddAlbum) {
                    Label("Add Manually", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)

                Button(action: onScanAlbum) {
                    Label("Scan", systemImage: "camera")
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct DuplicateBanner: View {
    let duplicate: Album
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Duplicate detected", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundColor(.orange)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Text("\(duplicate.title) by \(duplicate.artist) is already in your library.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

private struct CollectionFilterMenu: View {
    let collections: [AlbumCollection]
    let selectedID: UUID?
    let onSelection: (UUID?) -> Void

    var body: some View {
        Menu {
            Button {
                onSelection(nil)
            } label: {
                label("All Albums", isSelected: selectedID == nil)
            }

            if !collections.isEmpty {
                Section("Collections") {
                    ForEach(collections) { collection in
                        Button {
                            onSelection(collection.id)
                        } label: {
                            label(collection.name, isSelected: selectedID == collection.id)
                        }
                    }
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }

    @ViewBuilder
    private func label(_ title: String, isSelected: Bool) -> some View {
        if isSelected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }
}
