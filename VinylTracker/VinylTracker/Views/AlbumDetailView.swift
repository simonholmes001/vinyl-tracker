import SwiftUI
import UIKit

struct AlbumDetailView: View {
    @EnvironmentObject private var libraryViewModel: LibraryViewModel
    let album: Album

    var body: some View {
        List {
            if let imageData = album.imageData, let image = UIImage(data: imageData) {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 6)
                }
            }

            Section("Album") {
                DetailRow(label: "Title", value: album.displayTitle)
                DetailRow(label: "Artist", value: album.displayArtist)
                if let yearText = yearText, !yearText.isEmpty {
                    DetailRow(label: "Year", value: yearText)
                }
                if !album.genre.isEmpty {
                    DetailRow(label: "Genre", value: album.genre)
                }
                if !album.label.isEmpty {
                    DetailRow(label: "Label", value: album.label)
                }
            }

            if !album.notes.isEmpty {
                Section("Notes") {
                    Text(album.notes)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 4)
                }
            }

            Section("Collections") {
                let collections = libraryViewModel.collectionsContainingAlbum(album)
                if collections.isEmpty {
                    Text("Not in any collection yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(collections) { collection in
                        Text(collection.name)
                    }
                }
            }

            Section("Meta") {
                DetailRow(label: "Added", value: formatted(date: album.dateAdded))
                DetailRow(label: "Updated", value: formatted(date: album.lastUpdated))
            }
        }
        .navigationTitle(album.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var yearText: String? {
        album.year.map(String.init)
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}
