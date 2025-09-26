import XCTest
@testable import VinylTracker

final class CameraPermissionViewTests: XCTestCase {
    func testCameraPermissionManagerProvidesStatus() {
        let status = CameraPermissionManager.cameraPermissionStatus
        XCTAssertNotNil(status)
    }
}
