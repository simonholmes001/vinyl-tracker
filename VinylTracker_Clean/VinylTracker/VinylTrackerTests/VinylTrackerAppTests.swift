// VinylTrackerAppTests.swift
// Minimal test for app entry point
import XCTest
import SwiftUI
@testable import VinylTracker

final class VinylTrackerAppTests: XCTestCase {
    func testApp_initialization() {
        let app = VinylTrackerApp()
        XCTAssertNotNil(app)
    }
    
    func testApp_body() {
        let app = VinylTrackerApp()
        XCTAssertNotNil(app.body)
    }
}
