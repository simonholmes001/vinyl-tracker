import Foundation

struct AlbumCollection: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var detail: String
    var albumIDs: Set<UUID>
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        detail: String = "",
        albumIDs: Set<UUID> = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.detail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        self.albumIDs = albumIDs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var isValid: Bool { !name.isEmpty }
    var albumCount: Int { albumIDs.count }

    mutating func addAlbum(_ albumID: UUID) -> Bool {
        let inserted = albumIDs.insert(albumID).inserted
        if inserted { updatedAt = Date() }
        return inserted
    }

    mutating func removeAlbum(_ albumID: UUID) {
        if albumIDs.remove(albumID) != nil {
            updatedAt = Date()
        }
    }

    mutating func update(name: String, detail: String) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.detail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedAt = Date()
    }
}
