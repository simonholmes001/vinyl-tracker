import SwiftUI

struct CollectionManagementView: View {
    @EnvironmentObject private var libraryViewModel: LibraryViewModel

    let onAddAlbum: (Set<UUID>) -> Void
    let onScanAlbum: (Set<UUID>) -> Void

    @State private var showingCreateSheet = false
    @State private var editingCollection: AlbumCollection?
    @State private var deletingCollection: AlbumCollection?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(libraryViewModel.collections) { collection in
                        NavigationLink(destination: CollectionDetailView(collection: collection, onAddAlbum: onAddAlbum, onScanAlbum: onScanAlbum)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(collection.name)
                                    .font(.headline)
                                if !collection.detail.isEmpty {
                                    Text(collection.detail)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Text("\(collection.albumCount) album\(collection.albumCount == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", role: .destructive) {
                                deletingCollection = collection
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button("Edit") {
                                editingCollection = collection
                            }
                            .tint(.blue)
                            Button("Add Album") {
                                onAddAlbum([collection.id])
                            }
                            .tint(.green)
                        }
                        .contextMenu {
                            Button("Add Album") {
                                onAddAlbum([collection.id])
                            }
                            Button("Scan Album") {
                                onScanAlbum([collection.id])
                            }
                            Button("Edit") {
                                editingCollection = collection
                            }
                            Button(role: .destructive) {
                                deletingCollection = collection
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create Collection")
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                NavigationStack {
                    CollectionEditorView(initialName: "", initialDetail: "") { name, detail in
                        libraryViewModel.createCollection(name: name, detail: detail)
                        showingCreateSheet = false
                    } onCancel: {
                        showingCreateSheet = false
                    }
                }
            }
            .sheet(item: $editingCollection) { collection in
                NavigationStack {
                    CollectionEditorView(initialName: collection.name, initialDetail: collection.detail) { name, detail in
                        var updated = collection
                        updated.update(name: name, detail: detail)
                        libraryViewModel.updateCollection(updated)
                        editingCollection = nil
                    } onCancel: {
                        editingCollection = nil
                    }
                }
            }
            .alert("Delete Collection", isPresented: Binding(
                get: { deletingCollection != nil },
                set: { newValue in if !newValue { deletingCollection = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let collection = deletingCollection {
                        libraryViewModel.deleteCollection(collection)
                    }
                    deletingCollection = nil
                }
                Button("Cancel", role: .cancel) {
                    deletingCollection = nil
                }
            } message: {
                if let collection = deletingCollection {
                    Text("Deleting \(collection.name) will not remove its albums from your library. Continue?")
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let collection = libraryViewModel.collections[index]
            libraryViewModel.deleteCollection(collection)
        }
    }
}

private struct CollectionEditorView: View {
    @State private var name: String
    @State private var detail: String

    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    init(initialName: String, initialDetail: String, onSave: @escaping (String, String) -> Void, onCancel: @escaping () -> Void) {
        _name = State(initialValue: initialName)
        _detail = State(initialValue: initialDetail)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        Form {
            Section("Collection") {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)

                TextField("Description", text: $detail, axis: .vertical)
                    .lineLimit(2...5)
            }
        }
        .navigationTitle(name.isEmpty ? "New Collection" : "Edit Collection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    onCancel()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave(name, detail)
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

private struct CollectionDetailView: View {
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
