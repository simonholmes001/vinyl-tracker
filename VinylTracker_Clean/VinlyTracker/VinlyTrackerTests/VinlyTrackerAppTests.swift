// VinlyTrackerAppTests.swift
// Minimal test for app entry point
import XCTest
import SwiftUI
@testable import VinlyTracker

final class VinlyTrackerAppTests: XCTestCase {
    func testApp_initialization() {
        let app = VinylTrackerApp()
        XCTAssertNotNil(app)
    }
    
    func testApp_body() {
        let app = VinylTrackerApp()
        XCTAssertNotNil(app.body)
    }
}
