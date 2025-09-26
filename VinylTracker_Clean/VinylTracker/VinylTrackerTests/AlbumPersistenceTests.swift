import XCTest
@testable import VinylTracker

@MainActor
final class AlbumPersistenceTests: XCTestCase {
    func testRepositoryPersistsAlbumsAcrossInstances() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AlbumPersistenceTests", isDirectory: true)
            .appendingPathComponent("library-\(UUID().uuidString).json")
        let repoA = CollectionRepository(storageURL: url)
        _ = repoA.addAlbum(Album(title: "Black Star", artist: "David Bowie"))
        repoA.waitForPersistence()

        let repoB = CollectionRepository(storageURL: url)
        XCTAssertEqual(repoB.allAlbums.first?.title, "Black Star")
    }
}
