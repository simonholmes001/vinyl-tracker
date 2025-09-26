import XCTest
@testable import VinylTracker

@MainActor
final class AddAlbumViewTests: XCTestCase {
    func testAddAlbumViewRequiresTitleAndArtist() {
        let viewModel = LibraryViewModel(repository: CollectionRepository(storageURL: temporaryURL()))
        let result = viewModel.addAlbum(
            title: "",
            artist: "",
            year: nil,
            genre: "",
            notes: "",
            label: "",
            image: nil,
            collectionIDs: []
        )

        XCTAssertEqual(result, .rejected)
    }

    private func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("AddAlbumViewTests", isDirectory: true)
            .appendingPathComponent("library-\(UUID().uuidString).json")
    }
}
