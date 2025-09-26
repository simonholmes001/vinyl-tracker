import Foundation
import UIKit

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
