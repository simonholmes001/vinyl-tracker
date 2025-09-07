// ContentView.swift
// Main view controller following MVVM pattern

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AlbumCollectionViewModel()
    @State private var showingScanner = false
    @State private var showingAddForm = false
    @State private var showingDuplicateAlert = false
    @State private var pendingAlbum: Album?

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.albums.isEmpty {
                    EmptyStateView()
                } else {
                    AlbumListView(albums: viewModel.albums, onDelete: viewModel.deleteAlbums)
                }
            }
            .navigationTitle("Vinyl Collection (\(viewModel.albums.count))")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingScanner = true }) {
                        Image(systemName: "camera")
                    }
                    .accessibilityLabel("Scan Album")

                    Button(action: { showingAddForm = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Album")
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView { album in
                    handleNewAlbum(album)
                    showingScanner = false
                }
            }
            .sheet(isPresented: $showingAddForm) {
                AddAlbumView { album in
                    handleNewAlbum(album)
                    showingAddForm = false
                }
            }
            .alert("Duplicate Album", isPresented: $showingDuplicateAlert) {
                Button("Add Anyway") {
                    if let album = pendingAlbum {
                        viewModel.addAlbum(album, allowDuplicates: true)
                        pendingAlbum = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    pendingAlbum = nil
                }
            } message: {
                Text("This album appears to already be in your collection. Add it anyway?")
            }
        }
    }

    private func handleNewAlbum(_ album: Album) {
        if viewModel.hasDuplicate(album) {
            pendingAlbum = album
            showingDuplicateAlert = true
        } else {
            viewModel.addAlbum(album)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Albums Yet")
                .font(.title2)
                .fontWeight(.medium)

            Text("Start building your vinyl collection by scanning album covers or adding them manually")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct AlbumListView: View {
    let albums: [Album]
    let onDelete: (IndexSet) -> Void

    var body: some View {
        List {
            ForEach(albums) { album in
                AlbumRowView(album: album)
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(PlainListStyle())
    }
}

struct AlbumRowView: View {
    let album: Album

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(album.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                Text(album.displayArtist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack {
                    if !album.yearString.isEmpty {
                        Text(album.yearString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if !album.genre.isEmpty {
                        Text("• \(album.genre)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            if !album.genre.isEmpty {
                Text(album.genre)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - ViewModel (Following MVVM + TDD)

@MainActor
class AlbumCollectionViewModel: ObservableObject {
    @Published var albums: [Album] = []

    func addAlbum(_ album: Album, allowDuplicates: Bool = false) {
        guard album.isValid else { return }

        if !allowDuplicates && hasDuplicate(album) {
            return // Duplicate detected
        }

        albums.append(album)
        sortAlbums()
    }

    func deleteAlbums(at offsets: IndexSet) {
        albums.remove(atOffsets: offsets)
    }

    func hasDuplicate(_ album: Album) -> Bool {
        albums.contains { existing in
            existing.isSimilarTo(album)
        }
    }

    private func sortAlbums() {
        albums.sort { first, second in
            if first.artist.lowercased() == second.artist.lowercased() {
                return first.title.lowercased() < second.title.lowercased()
            }
            return first.artist.lowercased() < second.artist.lowercased()
        }
    }
}

#Preview {
    ContentView()
}
