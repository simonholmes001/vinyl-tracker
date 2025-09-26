import XCTest
import UIKit
@testable import VinylTracker

final class CameraIntegrationTests: XCTestCase {
    func testRecognitionServiceRejectsInvalidImage() async {
        let service = AlbumRecognitionService()
        await XCTAssertThrowsErrorAsync(try await service.analyse(image: UIImage())) { error in
            if case AlbumRecognitionError.invalidImage = error {
                // expected
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

private func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure () async throws -> T, _ errorHandler: (Error) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) async {
    do {
        _ = try await expression()
        XCTFail("Expected error", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
