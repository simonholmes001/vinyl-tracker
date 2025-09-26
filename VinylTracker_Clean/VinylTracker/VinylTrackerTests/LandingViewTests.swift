import XCTest
@testable import VinylTracker

@MainActor
final class LandingViewTests: XCTestCase {
    func testAlbumCollectionViewLoads() {
        let repo = CollectionRepository(storageURL: FileManager.default.temporaryDirectory.appendingPathComponent("LandingViewTests", isDirectory: true).appendingPathComponent("library-\(UUID().uuidString).json"))
        let viewModel = LibraryViewModel(repository: repo)
        let view = AlbumCollectionView(onAddAlbum: { _ in }, onScanAlbum: { _ in }).environmentObject(viewModel)
        XCTAssertNotNil(view)
    }
}
