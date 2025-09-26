import SwiftUI

struct CollectionListView: View {
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
