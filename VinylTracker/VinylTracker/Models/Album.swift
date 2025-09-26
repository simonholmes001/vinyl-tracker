import Foundation
import UIKit

struct Album: Identifiable, Codable, Hashable {
    struct DuplicateKey: Hashable, Codable {
        let title: String
        let artist: String
    }

    var id: UUID
    var title: String
    var artist: String
    var year: Int?
    var genre: String
    var notes: String
    var label: String
    var imageData: Data?
    var dateAdded: Date
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        year: Int? = nil,
        genre: String = "",
        notes: String = "",
        label: String = "",
        imageData: Data? = nil,
        dateAdded: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.artist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
        self.year = year
        self.genre = genre.trimmingCharacters(in: .whitespacesAndNewlines)
        self.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        self.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imageData = imageData
        self.dateAdded = dateAdded
        self.lastUpdated = lastUpdated
    }

    var isValid: Bool {
        !title.isEmpty && !artist.isEmpty
    }

    var duplicateKey: DuplicateKey {
        DuplicateKey(
            title: title.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).trimmingCharacters(in: .whitespacesAndNewlines),
            artist: artist.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    var displayTitle: String { title }
    var displayArtist: String { artist }

    var yearText: String {
        guard let year else { return "" }
        return String(year)
    }

    var hasArtwork: Bool { imageData?.isEmpty == false }

    func artworkImage() -> UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }

    func matches(query: String) -> Bool {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return true }
        let normalizedQuery = trimmedQuery.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        return [title, artist, genre, label]
            .map { $0.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current) }
            .contains { $0.contains(normalizedQuery) }
    }

    func updatingMetadata(
        title: String? = nil,
        artist: String? = nil,
        year: Int?? = nil,
        genre: String? = nil,
        notes: String? = nil,
        label: String? = nil,
        imageData: Data?? = nil
    ) -> Album {
        Album(
            id: id,
            title: title ?? self.title,
            artist: artist ?? self.artist,
            year: year ?? self.year,
            genre: genre ?? self.genre,
            notes: notes ?? self.notes,
            label: label ?? self.label,
            imageData: imageData ?? self.imageData,
            dateAdded: dateAdded,
            lastUpdated: Date()
        )
    }
}

extension Album {
    static func makePlaceholder(index: Int) -> Album {
        Album(
            title: "Album \(index)",
            artist: "Artist \(index)",
            year: 1970 + index,
            genre: "Genre",
            notes: "",
            label: "Label \(index)"
        )
    }
}
