import Foundation
import UIKit
import Vision

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
        collections = collections.map { collection in
            var mutable = collection
            if mutable.albumIDs.contains(id) {
                mutable.removeAlbum(id)
            }
            return mutable
        }
        persistSnapshot()
    }

    func createCollection(name: String, detail: String = "") -> AlbumCollection {
        var collection = AlbumCollection(name: name, detail: detail)
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

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var searchQuery: String = "" {
        didSet { applyFilters() }
    }

    @Published var selectedCollectionID: UUID? {
        didSet { applyFilters() }
    }

    @Published private(set) var albums: [Album] = []
    @Published private(set) var filteredAlbums: [Album] = []
    @Published private(set) var collections: [AlbumCollection] = []
    @Published private(set) var duplicateMatch: Album?
    @Published private(set) var lastOperationError: String?

    private let repository: CollectionRepository

    init(repository: CollectionRepository? = nil) {
        self.repository = repository ?? CollectionRepository()
        refreshFromRepository()
    }

    func refreshFromRepository() {
        albums = repository.allAlbums
        collections = repository.collections
        applyFilters()
    }

    func createCollection(name: String, detail: String = "") {
        let collection = repository.createCollection(name: name, detail: detail)
        if collection.isValid {
            refreshFromRepository()
            selectedCollectionID = collection.id
        }
    }

    func updateCollection(_ collection: AlbumCollection) {
        repository.updateCollection(collection)
        refreshFromRepository()
    }

    func deleteCollection(_ collection: AlbumCollection) {
        repository.deleteCollection(id: collection.id)
        if selectedCollectionID == collection.id {
            selectedCollectionID = nil
        }
        refreshFromRepository()
    }

    @discardableResult
    func addAlbum(
        title: String,
        artist: String,
        year: Int?,
        genre: String,
        notes: String,
        label: String,
        image: UIImage?,
        collectionIDs: [UUID],
        allowDuplicateInsertion: Bool = false
    ) -> CollectionRepository.AlbumInsertResult {
        lastOperationError = nil
        let album = Album(
            title: title,
            artist: artist,
            year: year,
            genre: genre,
            notes: notes,
            label: label,
            imageData: image?.jpegData(compressionQuality: 0.8)
        )

        let result = repository.addAlbum(
            album,
            to: collectionIDs,
            allowDuplicateInsertion: allowDuplicateInsertion
        )

        switch result {
        case .inserted:
            duplicateMatch = nil
        case .duplicate(let existing):
            duplicateMatch = existing
        case .rejected:
            lastOperationError = "Album title and artist are required."
        }

        refreshFromRepository()
        return result
    }

    func addExistingAlbum(_ albumID: UUID, to collectionIDs: [UUID]) {
        repository.link(albumID: albumID, to: collectionIDs)
        refreshFromRepository()
    }

    func removeAlbum(_ album: Album) {
        repository.removeAlbum(id: album.id)
        refreshFromRepository()
    }

    func removeAlbum(_ album: Album, from collection: AlbumCollection) {
        repository.remove(albumID: album.id, from: collection.id)
        refreshFromRepository()
    }

    func collectionsContainingAlbum(_ album: Album) -> [AlbumCollection] {
        repository.collectionsContainingAlbum(album.id)
    }

    func albums(in collection: AlbumCollection?) -> [Album] {
        if let collection {
            return repository.albums(in: collection.id)
        }
        return repository.allAlbums
    }

    func makeScannerViewModel() -> ScannerViewModel {
        ScannerViewModel(repository: repository)
    }

    func clearDuplicateNotice() {
        duplicateMatch = nil
    }

    private func applyFilters() {
        let base = repository.albums(in: selectedCollectionID)
        guard !searchQuery.isEmpty else {
            filteredAlbums = base
            return
        }
        filteredAlbums = base.filter { $0.matches(query: searchQuery) }
    }
}

@MainActor
final class ScannerViewModel: ObservableObject, Identifiable {
    let id = UUID()
    enum ScanState: Equatable {
        case idle
        case processing
        case suggestion(AlbumRecognitionSuggestion, duplicate: Album?)
        case failure(String)
    }

    @Published private(set) var state: ScanState = .idle
    @Published private(set) var capturedImage: UIImage?

    private let repository: CollectionRepository
    private let recognitionService: AlbumRecognitionService
    private var recognitionTask: Task<Void, Never>?

    init(
        repository: CollectionRepository,
        recognitionService: AlbumRecognitionService = AlbumRecognitionService()
    ) {
        self.repository = repository
        self.recognitionService = recognitionService
    }

    func processCapturedImage(_ image: UIImage) {
        recognitionTask?.cancel()
        capturedImage = image
        state = .processing

        recognitionTask = Task { [weak self] in
            guard let self else { return }
            do {
                let suggestion = try await recognitionService.analyse(image: image)
                let duplicate = repository.duplicate(forTitle: suggestion.suggestedTitle, artist: suggestion.suggestedArtist)
                self.state = .suggestion(suggestion, duplicate: duplicate)
            } catch {
                let recognitionError = (error as? AlbumRecognitionError)?.errorDescription ?? error.localizedDescription
                self.state = .failure(recognitionError)
            }
        }
    }

    func reset() {
        recognitionTask?.cancel()
        recognitionTask = nil
        capturedImage = nil
        state = .idle
    }

    func duplicateIfExists(title: String, artist: String) -> Album? {
        repository.duplicate(forTitle: title, artist: artist)
    }
}

struct AlbumRecognitionSuggestion: Equatable {
    let suggestedTitle: String
    let suggestedArtist: String
    let candidateLines: [String]
    let confidence: Float
}

enum AlbumRecognitionError: Error, LocalizedError {
    case invalidImage
    case noTextDetected
    case cancelled
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The captured image could not be processed."
        case .noTextDetected:
            return "No readable text was detected on the album cover."
        case .cancelled:
            return "The recognition request was cancelled."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

final class AlbumRecognitionService {
    private let recognitionQueue = DispatchQueue(label: "app.vinyltracker.recognition", qos: .userInitiated)

    func analyse(image: UIImage) async throws -> AlbumRecognitionSuggestion {
        guard let cgImage = image.cgImage else {
            throw AlbumRecognitionError.invalidImage
        }

        if Task.isCancelled { throw AlbumRecognitionError.cancelled }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: AlbumRecognitionError.underlying(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    continuation.resume(throwing: AlbumRecognitionError.noTextDetected)
                    return
                }

                let ordered = observations.sorted { lhs, rhs in
                    lhs.boundingBox.minY > rhs.boundingBox.minY
                }

                let recognitions: [(String, Float)] = ordered.compactMap { observation in
                    guard let candidate = observation.topCandidates(1).first else { return nil }
                    let trimmed = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmed.count >= 2 else { return nil }
                    return (trimmed, candidate.confidence)
                }

                guard !recognitions.isEmpty else {
                    continuation.resume(throwing: AlbumRecognitionError.noTextDetected)
                    return
                }

                let candidateLines = recognitions.map { $0.0 }
                let confidence = recognitions.map { $0.1 }.reduce(0, +) / Float(recognitions.count)

                let (title, artist) = AlbumRecognitionService.inferTitleAndArtist(from: candidateLines)

                continuation.resume(returning: AlbumRecognitionSuggestion(
                    suggestedTitle: title,
                    suggestedArtist: artist,
                    candidateLines: candidateLines,
                    confidence: confidence
                ))
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.02

            recognitionQueue.async {
                if Task.isCancelled {
                    continuation.resume(throwing: AlbumRecognitionError.cancelled)
                    return
                }

                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation), options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: AlbumRecognitionError.underlying(error))
                }
            }
        }
    }

    private static func inferTitleAndArtist(from lines: [String]) -> (String, String) {
        guard !lines.isEmpty else { return ("", "") }

        if lines.count == 1 {
            return (lines[0], "")
        }

        let artistKeywords = ["feat", "featuring", "and", "with", "band", "orchestra"]
        let artistCandidate = lines.first { line in
            let lowercased = line.lowercased()
            return artistKeywords.contains { lowercased.contains($0) }
        }

        if let artistCandidate, let artistIndex = lines.firstIndex(of: artistCandidate) {
            var remaining = lines
            remaining.remove(at: artistIndex)
            let titleCandidate = remaining.max(by: { $0.count < $1.count }) ?? remaining.first ?? ""
            return (titleCandidate, artistCandidate)
        }

        let titleCandidate = lines.max(by: { $0.count < $1.count }) ?? lines[0]
        let artistCandidateFallback = lines.first { $0 != titleCandidate } ?? ""
        return (titleCandidate, artistCandidateFallback)
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
