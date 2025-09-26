import XCTest
@testable import VinylTracker

final class ScannerViewModelTests: XCTestCase {
    func testDuplicateLookupFindsExistingAlbum() {
        let storageURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScannerViewModelTests", isDirectory: true)
            .appendingPathComponent("library-\(UUID().uuidString).json")

        let repository = CollectionRepository(storageURL: storageURL)
        _ = repository.addAlbum(Album(title: "Abraxas", artist: "Santana"))

        let viewModel = ScannerViewModel(repository: repository)
        let duplicate = viewModel.duplicateIfExists(title: "abraxas", artist: "santana")
        XCTAssertNotNil(duplicate)
    }
}
