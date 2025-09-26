import SwiftUI
import UIKit

struct AlbumRowView: View {
    let album: Album

    var body: some View {
        HStack(spacing: 16) {
            ArtworkThumbnail(imageData: album.imageData)

            VStack(alignment: .leading, spacing: 4) {
                Text(album.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                Text(album.displayArtist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if !album.yearText.isEmpty {
                        Label(album.yearText, systemImage: "calendar")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.secondary)
                    }

                    if !album.genre.isEmpty {
                        Text(album.genre)
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct ArtworkThumbnail: View {
    let imageData: Data?

    var body: some View {
        Group {
            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                    Image(systemName: "opticaldisc")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
