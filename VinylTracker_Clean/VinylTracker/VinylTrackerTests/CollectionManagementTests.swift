import XCTest
@testable import VinylTracker

@MainActor
final class CollectionRepositoryTests: XCTestCase {
    private func makeStorageURL() -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("VinylRepositoryTests", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("library-\(UUID().uuidString).json")
    }

    func testAddAlbumInsertsAndPersists() {
        let storageURL = makeStorageURL()
        let repository = CollectionRepository(storageURL: storageURL)

        let result = repository.addAlbum(Album(title: "Kind of Blue", artist: "Miles Davis"))
        XCTAssertEqual(repository.allAlbums.count, 1)
        guard case .inserted = result else {
            XCTFail("Expected insert result")
            return
        }

        repository.waitForPersistence()
        let reloaded = CollectionRepository(storageURL: storageURL)
        XCTAssertEqual(reloaded.allAlbums.count, 1)
    }

    func testDuplicateDetectionPreventsSecondInsertAndLinksCollections() {
        let storageURL = makeStorageURL()
        let repository = CollectionRepository(storageURL: storageURL)

        let collection = repository.createCollection(name: "Jazz Classics")
        let album = Album(title: "Blue Train", artist: "John Coltrane")
        _ = repository.addAlbum(album, to: [collection.id])
        repository.waitForPersistence()

        let duplicate = Album(title: "blue train", artist: "john coltrane")
        let result = repository.addAlbum(duplicate, to: [collection.id])

        guard case .duplicate(let existing) = result else {
            return XCTFail("Expected duplicate response")
        }
        XCTAssertEqual(existing.title, album.title)
        XCTAssertEqual(repository.collectionsContainingAlbum(existing.id).first?.id, collection.id)
    }

    func testRemovingAlbumPurgesFromCollections() {
        let storageURL = makeStorageURL()
        let repository = CollectionRepository(storageURL: storageURL)

        let collection = repository.createCollection(name: "Favorites")
        let album = Album(title: "Hounds of Love", artist: "Kate Bush")
        let result = repository.addAlbum(album, to: [collection.id])
        guard case .inserted(let stored) = result else { return XCTFail("Expected stored album") }
        repository.waitForPersistence()

        repository.removeAlbum(id: stored.id)
        repository.waitForPersistence()

        XCTAssertTrue(repository.allAlbums.isEmpty)
        XCTAssertTrue(repository.collectionsContainingAlbum(stored.id).isEmpty)
        let refreshedCollection = repository.collections.first { $0.id == collection.id }
        XCTAssertEqual(refreshedCollection?.albumCount, 0)
    }

    func testLinkingExistingAlbumAddsToCollection() {
        let storageURL = makeStorageURL()
        let repository = CollectionRepository(storageURL: storageURL)

        let album = Album(title: "The Wall", artist: "Pink Floyd")
        let rock = repository.createCollection(name: "Rock")
        let live = repository.createCollection(name: "Live Shows")
        let result = repository.addAlbum(album, to: [rock.id])
        guard case .inserted(let stored) = result else { return XCTFail("Expected insert") }

        repository.link(albumID: stored.id, to: [live.id])
        repository.waitForPersistence()

        let containing = repository.collectionsContainingAlbum(stored.id)
        XCTAssertEqual(Set(containing.map { $0.id }), Set([rock.id, live.id]))
    }
}
