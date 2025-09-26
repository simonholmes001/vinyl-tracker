import Foundation

@MainActor
final class CollectionRepository: ObservableObject {
    enum AlbumInsertResult: Equatable {
        case inserted(Album)
        case duplicate(existing: Album)
        case rejected
    }

    @Published private(set) var albumsByID: [UUID: Album] = [:]
    @Published private(set) var collections: [AlbumCollection] = []

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let persistenceQueue = DispatchQueue(label: "app.vinyltracker.persistence", qos: .utility)

    init(fileManager: FileManager = .default, storageURL: URL? = nil) {
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        if let storageURL {
            self.fileURL = storageURL
            CollectionRepository.ensureDirectoryExists(for: storageURL, fileManager: fileManager)
        } else {
            self.fileURL = CollectionRepository.makeStorageURL(fileManager: fileManager)
        }
        loadFromDisk()
    }

    var allAlbums: [Album] {
        albumsByID.values.sorted { lhs, rhs in
            if lhs.artist.caseInsensitiveCompare(rhs.artist) == .orderedSame {
                return lhs.title.caseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return lhs.artist.caseInsensitiveCompare(rhs.artist) == .orderedAscending
        }
    }

    func album(withID id: UUID) -> Album? {
        albumsByID[id]
    }

    func duplicate(for album: Album) -> Album? {
        albumsByID.values.first { $0.duplicateKey == album.duplicateKey }
    }

    func duplicate(forTitle title: String, artist: String) -> Album? {
        let probe = Album(title: title, artist: artist)
        return duplicate(for: probe)
    }

    @discardableResult
    func addAlbum(
        _ album: Album,
        to collectionIDs: [UUID] = [],
        allowDuplicateInsertion: Bool = false
    ) -> AlbumInsertResult {
        guard album.isValid else { return .rejected }

        if let existing = duplicate(for: album), !allowDuplicateInsertion {
            add(albumID: existing.id, to: collectionIDs)
            persistSnapshot()
            return .duplicate(existing: existing)
        }

        var stored = album
        stored.dateAdded = Date()
        stored.lastUpdated = Date()
        albumsByID[stored.id] = stored
        add(albumID: stored.id, to: collectionIDs)
        persistSnapshot()
        return .inserted(stored)
    }

    func updateAlbum(_ album: Album) {
        guard albumsByID[album.id] != nil else { return }
        var updated = album
        updated.lastUpdated = Date()
        albumsByID[album.id] = updated
        persistSnapshot()
    }

    func removeAlbum(id: UUID) {
        guard albumsByID.removeValue(forKey: id) != nil else { return }
        var dirty = false
        collections = collections.map { collection in
            var mutable = collection
            if mutable.albumIDs.contains(id) {
                mutable.removeAlbum(id)
                dirty = true
            }
            return mutable
        }
        if dirty {
            persistSnapshot()
        } else {
            persistSnapshot()
        }
    }

    func createCollection(name: String, detail: String = "") -> AlbumCollection {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        var collection = AlbumCollection(name: cleanedName, detail: cleanedDetail)
        guard collection.isValid else { return collection }
        collections.append(collection)
        collections.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        persistSnapshot()
        return collection
    }

    func updateCollection(_ collection: AlbumCollection) {
        guard let index = collections.firstIndex(where: { $0.id == collection.id }) else { return }
        var updated = collection
        updated.updatedAt = Date()
        collections[index] = updated
        persistSnapshot()
    }

    func deleteCollection(id: UUID) {
        guard let index = collections.firstIndex(where: { $0.id == id }) else { return }
        collections.remove(at: index)
        persistSnapshot()
    }

    func link(albumID: UUID, to collectionIDs: [UUID]) {
        guard albumsByID[albumID] != nil else { return }
        guard !collectionIDs.isEmpty else { return }
        add(albumID: albumID, to: collectionIDs)
        persistSnapshot()
    }

    private func add(albumID: UUID, to collectionIDs: [UUID]) {
        guard !collectionIDs.isEmpty else { return }
        collections = collections.map { collection in
            var mutable = collection
            if collectionIDs.contains(collection.id) {
                mutable.addAlbum(albumID)
            }
            return mutable
        }
    }

    func remove(albumID: UUID, from collectionID: UUID) {
        guard let index = collections.firstIndex(where: { $0.id == collectionID }) else { return }
        collections[index].removeAlbum(albumID)
        persistSnapshot()
    }

    func albums(in collectionID: UUID?) -> [Album] {
        guard let collectionID else { return allAlbums }
        guard let collection = collections.first(where: { $0.id == collectionID }) else { return [] }
        return collection.albumIDs.compactMap { albumsByID[$0] }
            .sorted { $0.title.caseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func collectionsContainingAlbum(_ albumID: UUID) -> [AlbumCollection] {
        collections.filter { $0.albumIDs.contains(albumID) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func searchAlbums(matching query: String) -> [Album] {
        allAlbums.filter { $0.matches(query: query) }
    }

    func waitForPersistence() {
        persistenceQueue.sync { }
    }

    private func persistSnapshot() {
        let snapshot = PersistedLibrary(
            version: 1,
            albums: Array(albumsByID.values),
            collections: collections
        )
        let encoder = encoder
        let url = fileURL
        persistenceQueue.async {
            do {
                let data = try encoder.encode(snapshot)
                try data.write(to: url, options: .atomic)
            } catch {
                NSLog("Failed to persist library: %@", error.localizedDescription)
            }
        }
    }

    private func loadFromDisk() {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            return
        }

        do {
            let snapshot = try decoder.decode(PersistedLibrary.self, from: data)
            let albumRecords = Dictionary(uniqueKeysWithValues: snapshot.albums.map { ($0.id, $0) })
            let sanitisedCollections = snapshot.collections.map { collection -> AlbumCollection in
                var mutable = collection
                let validIDs = collection.albumIDs.filter { albumRecords[$0] != nil }
                mutable.albumIDs = Set(validIDs)
                return mutable
            }
            albumsByID = albumRecords
            collections = sanitisedCollections.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            NSLog("Failed to load persisted library: %@", error.localizedDescription)
        }
    }

    private static func makeStorageURL(fileManager: FileManager) -> URL {
        let directory: URL
        if let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            directory = supportDirectory.appendingPathComponent("VinylTracker", isDirectory: true)
        } else {
            directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        }

        ensureDirectoryExists(for: directory, fileManager: fileManager)

        return directory.appendingPathComponent("library.json", isDirectory: false)
    }

    private static func ensureDirectoryExists(for url: URL, fileManager: FileManager) {
        let directory = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
}

private struct PersistedLibrary: Codable {
    let version: Int
    let albums: [Album]
    let collections: [AlbumCollection]
}
