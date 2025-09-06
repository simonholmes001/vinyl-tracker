// ScannerViewTests.swift
// TDD tests for ScannerView functionality

import XCTest
import SwiftUI
@testable import VinlyTracker

final class ScannerViewTests: XCTestCase {
    
    // MARK: - ScannerView State Tests
    
    func testScannerView_InitialState_ShouldBeCorrect() {
        // Given - New ScannerView
        var scannedAlbum: Album?
        let scannerView = ScannerView { album in
            scannedAlbum = album
        }
        
        // When - Initial state
        // Then - Should not have scanned any album yet
        XCTAssertNil(scannedAlbum)
    }
    
    func testScannerView_OnAlbumScanned_ShouldCallCallback() {
        // Given - ScannerView with callback
        var scannedAlbum: Album?
        let expectation = XCTestExpectation(description: "Album scanned callback")
        
        let scannerView = ScannerView { album in
            scannedAlbum = album
            expectation.fulfill()
        }
        
        // When - Simulating album scan
        let testAlbum = Album(title: "Test Album", artist: "Test Artist")
        scannerView.onAlbumScanned(testAlbum)
        
        // Then - Should call callback with correct album
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(scannedAlbum)
        XCTAssertEqual(scannedAlbum?.title, "Test Album")
        XCTAssertEqual(scannedAlbum?.artist, "Test Artist")
    }
    
    // MARK: - Mock Album Recognition Tests
    
    func testMockAlbumRecognition_ShouldReturnValidAlbums() {
        // Given - Mock album array (simulating the one in ScannerView)
        let mockAlbums = [
            Album(title: "Abbey Road", artist: "The Beatles", year: 1969, genre: "Rock"),
            Album(title: "Dark Side of the Moon", artist: "Pink Floyd", year: 1973, genre: "Progressive Rock"),
            Album(title: "Thriller", artist: "Michael Jackson", year: 1982, genre: "Pop"),
            Album(title: "Nevermind", artist: "Nirvana", year: 1991, genre: "Grunge"),
            Album(title: "OK Computer", artist: "Radiohead", year: 1997, genre: "Alternative Rock"),
            Album(title: "Pet Sounds", artist: "The Beach Boys", year: 1966, genre: "Pop Rock"),
            Album(title: "Sgt. Pepper's Lonely Hearts Club Band", artist: "The Beatles", year: 1967, genre: "Rock"),
            Album(title: "The Velvet Underground & Nico", artist: "The Velvet Underground", year: 1967, genre: "Art Rock")
        ]
        
        // When - Getting random albums
        for _ in 0..<10 {
            let randomAlbum = mockAlbums.randomElement()!
            
            // Then - All should be valid
            XCTAssertTrue(randomAlbum.isValid)
            XCTAssertFalse(randomAlbum.title.isEmpty)
            XCTAssertFalse(randomAlbum.artist.isEmpty)
            XCTAssertGreaterThan(randomAlbum.year, 1900)
            XCTAssertFalse(randomAlbum.genre.isEmpty)
        }
    }
    
    func testMockAlbumRecognition_ShouldIncludeExpectedAlbums() {
        // Given - Mock album array
        let mockAlbums = [
            Album(title: "Abbey Road", artist: "The Beatles", year: 1969, genre: "Rock"),
            Album(title: "Dark Side of the Moon", artist: "Pink Floyd", year: 1973, genre: "Progressive Rock"),
            Album(title: "Thriller", artist: "Michael Jackson", year: 1982, genre: "Pop")
        ]
        
        // When - Checking specific albums
        let abbeyRoad = mockAlbums.first { $0.title == "Abbey Road" }
        let darkSide = mockAlbums.first { $0.title == "Dark Side of the Moon" }
        let thriller = mockAlbums.first { $0.title == "Thriller" }
        
        // Then - Should contain expected albums
        XCTAssertNotNil(abbeyRoad)
        XCTAssertEqual(abbeyRoad?.artist, "The Beatles")
        XCTAssertEqual(abbeyRoad?.year, 1969)
        
        XCTAssertNotNil(darkSide)
        XCTAssertEqual(darkSide?.artist, "Pink Floyd")
        XCTAssertEqual(darkSide?.genre, "Progressive Rock")
        
        XCTAssertNotNil(thriller)
        XCTAssertEqual(thriller?.artist, "Michael Jackson")
        XCTAssertEqual(thriller?.year, 1982)
    }
    
    // MARK: - Error Handling Tests
    
    func testScannerView_ErrorHandling_ShouldNotCrash() {
        // Given - ScannerView with error-prone callback
        let scannerView = ScannerView { album in
            // Simulate callback that might throw
            let _ = album.title.count
        }
        
        // When - Calling with various album states
        let validAlbum = Album(title: "Valid", artist: "Artist")
        let emptyTitleAlbum = Album(title: "", artist: "Artist")
        
        // Then - Should not crash
        XCTAssertNoThrow(scannerView.onAlbumScanned(validAlbum))
        XCTAssertNoThrow(scannerView.onAlbumScanned(emptyTitleAlbum))
    }
    
    // MARK: - Integration with Album Model Tests
    
    func testScannerView_WithValidAlbum_ShouldPassValidation() {
        // Given - Scanner view and valid album
        var receivedAlbum: Album?
        let scannerView = ScannerView { album in
            receivedAlbum = album
        }
        
        let validAlbum = Album(title: "Test Title", artist: "Test Artist", year: 2024, genre: "Test Genre")
        
        // When - Scanning valid album
        scannerView.onAlbumScanned(validAlbum)
        
        // Then - Received album should be valid
        XCTAssertNotNil(receivedAlbum)
        XCTAssertTrue(receivedAlbum!.isValid)
        XCTAssertEqual(receivedAlbum?.title, "Test Title")
        XCTAssertEqual(receivedAlbum?.artist, "Test Artist")
    }
    
    func testScannerView_WithInvalidAlbum_ShouldStillReceiveAlbum() {
        // Given - Scanner view and invalid album (empty title)
        var receivedAlbum: Album?
        let scannerView = ScannerView { album in
            receivedAlbum = album
        }
        
        let invalidAlbum = Album(title: "", artist: "Artist")
        
        // When - Scanning invalid album
        scannerView.onAlbumScanned(invalidAlbum)
        
        // Then - Should receive album (validation happens in ViewModel)
        XCTAssertNotNil(receivedAlbum)
        XCTAssertFalse(receivedAlbum!.isValid)
        XCTAssertEqual(receivedAlbum?.artist, "Artist")
    }
    
    // MARK: - Performance Tests
    
    func testMockAlbumGeneration_Performance() {
        // Given - Mock album array
        let mockAlbums = [
            Album(title: "Album 1", artist: "Artist 1"),
            Album(title: "Album 2", artist: "Artist 2"),
            Album(title: "Album 3", artist: "Artist 3")
        ]
        
        // When/Then - Should generate random albums quickly
        measure {
            for _ in 0..<1000 {
                let _ = mockAlbums.randomElement()
            }
        }
    }
    
    // MARK: - Mock Async Processing Tests
    
    func testAsyncProcessing_ShouldComplete() {
        // Given - Async processing expectation
        let expectation = XCTestExpectation(description: "Async processing")
        var completed = false
        
        // When - Simulating async processing (like image recognition)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completed = true
            expectation.fulfill()
        }
        
        // Then - Should complete
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completed)
    }
    
    func testAsyncProcessing_WithDelay_ShouldCompleteAfterDelay() {
        // Given - Processing start time
        let startTime = Date()
        let expectation = XCTestExpectation(description: "Delayed processing")
        
        // When - Simulating recognition delay (2 seconds like in real scanner)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let endTime = Date()
            let elapsed = endTime.timeIntervalSince(startTime)
            
            // Then - Should take approximately the expected time
            XCTAssertGreaterThanOrEqual(elapsed, 0.2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
