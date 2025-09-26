import XCTest
@testable import VinylTracker

@MainActor
final class VinylTrackerAppTests: XCTestCase {
    func testAppInitialisesLibraryViewModel() {
        let app = VinylTrackerApp()
        XCTAssertNotNil(app.body)
    }
}
