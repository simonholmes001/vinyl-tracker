import XCTest
@testable import VinylTracker

@MainActor
final class ContentViewIntegrationTests: XCTestCase {
    func testDuplicateAddShowsDuplicateMatch() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ContentViewIntegration", isDirectory: true)
            .appendingPathComponent("library-\(UUID().uuidString).json")
        let repo = CollectionRepository(storageURL: url)
        let viewModel = LibraryViewModel(repository: repo)
        _ = viewModel.addAlbum(title: "OK Computer", artist: "Radiohead", year: nil, genre: "", notes: "", label: "", image: nil, collectionIDs: [])
        let result = viewModel.addAlbum(title: "ok computer", artist: "radiohead", year: nil, genre: "", notes: "", label: "", image: nil, collectionIDs: [])
        if case .duplicate = result {
            XCTAssertNotNil(viewModel.duplicateMatch)
        } else {
            XCTFail("Expected duplicate result")
        }
    }
}
