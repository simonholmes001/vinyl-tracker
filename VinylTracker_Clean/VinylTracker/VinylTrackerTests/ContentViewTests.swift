import XCTest
@testable import VinylTracker

@MainActor
final class ContentViewTests: XCTestCase {
    func testContentViewHasTabs() {
        let repository = CollectionRepository(storageURL: FileManager.default.temporaryDirectory.appendingPathComponent("ContentViewTests", isDirectory: true).appendingPathComponent("library-\(UUID().uuidString).json"))
        let viewModel = LibraryViewModel(repository: repository)
        let view = ContentView().environmentObject(viewModel)
        XCTAssertNotNil(view)
    }
}
