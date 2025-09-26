import XCTest
@testable import VinylTracker

final class VinylTrackerTests: XCTestCase {
    func testLibraryViewModelAddsAlbum() {
        let storageURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("VinylTrackerViewModelTests", isDirectory: true)
            .appendingPathComponent("library-\(UUID().uuidString).json")

        let repository = CollectionRepository(storageURL: storageURL)
        let viewModel = LibraryViewModel(repository: repository)

        let result = viewModel.addAlbum(
            title: "In Rainbows",
            artist: "Radiohead",
            year: 2007,
            genre: "Alternative",
            notes: "",
            label: "XL",
            image: nil,
            collectionIDs: [],
            allowDuplicateInsertion: false
        )

        if case .inserted = result {
            XCTAssertEqual(viewModel.filteredAlbums.count, 1)
            XCTAssertEqual(viewModel.filteredAlbums.first?.title, "In Rainbows")
        } else {
            XCTFail("Expected album to be inserted")
        }
    }
}
