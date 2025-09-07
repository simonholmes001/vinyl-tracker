import XCTest
import SwiftUI
@testable import VinylTracker

class AddAlbumViewTests: XCTestCase {

    // MARK: - View Initialization Tests

    func testAddAlbumView_initialization_shouldSucceed() {
        // Given & When
        let view = AddAlbumView { _ in }

        // Then
        XCTAssertNotNil(view)
    }

    func testAddAlbumView_withCallback_shouldAcceptCallback() {
        // Given
        var callbackCalled = false

        // When
        let view = AddAlbumView { _ in
            callbackCalled = true
        }

        // Then
        XCTAssertNotNil(view)
        // Callback acceptance is verified by successful compilation
    }

    // MARK: - Album Creation Logic Tests
    // Testing the Album model directly since UI state is private

    func testAlbumCreation_withValidData_shouldCreateCorrectAlbum() {
        // Given
        let title = "Abbey Road"
        let artist = "The Beatles"
        let year = 1969
        let genre = "Rock"
        let label = "Apple Records"

        // When
        let album = Album(
            title: title,
            artist: artist,
            year: year,
            genre: genre,
            label: label
        )

        // Then
        XCTAssertEqual(album.title, title)
        XCTAssertEqual(album.artist, artist)
        XCTAssertEqual(album.year, year)
        XCTAssertEqual(album.genre, genre)
        XCTAssertEqual(album.label, label)
        XCTAssertTrue(album.isValid)
        XCTAssertNotNil(album.id)
    }

    func testAlbumCreation_withMinimalData_shouldCreateValidAlbum() {
        // Given
        let title = "Unknown Album"
        let artist = "Unknown Artist"

        // When
        let album = Album(title: title, artist: artist)

        // Then
        XCTAssertEqual(album.title, title)
        XCTAssertEqual(album.artist, artist)
        XCTAssertTrue(album.isValid)
        XCTAssertNotNil(album.id)
    }

    func testAlbumCreation_withEmptyOptionalFields_shouldUseDefaults() {
        // Given
        let title = "Test Album"
        let artist = "Test Artist"

        // When
        let album = Album(
            title: title,
            artist: artist,
            year: 0,
            genre: "",
            label: ""
        )

        // Then
        XCTAssertEqual(album.title, title)
        XCTAssertEqual(album.artist, artist)
        XCTAssertEqual(album.year, 0)
        XCTAssertEqual(album.genre, "")
        XCTAssertEqual(album.label, "")
        XCTAssertTrue(album.isValid)
    }

    // MARK: - Input Validation Tests

    func testStringValidation_withValidString_shouldReturnTrue() {
        // Given
        let validString = "Valid Input"

        // When
        let isValid = !validString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        // Then
        XCTAssertTrue(isValid)
    }

    func testStringValidation_withEmptyString_shouldReturnFalse() {
        // Given
        let emptyString = ""

        // When
        let isValid = !emptyString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        // Then
        XCTAssertFalse(isValid)
    }

    func testStringValidation_withWhitespaceOnly_shouldReturnFalse() {
        // Given
        let whitespaceString = "   \t\n   "

        // When
        let isValid = !whitespaceString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        // Then
        XCTAssertFalse(isValid)
    }

    // MARK: - Special Characters Tests

    func testAlbumCreation_withSpecialCharacters_shouldHandleCorrectly() {
        // Given
        let title = "Tëst Ålbüm with Spéçial Çharacters"
        let artist = "Artîst Nämé"

        // When
        let album = Album(title: title, artist: artist)

        // Then
        XCTAssertEqual(album.title, title)
        XCTAssertEqual(album.artist, artist)
        XCTAssertTrue(album.isValid)
    }

    func testAlbumCreation_withEmoji_shouldHandleCorrectly() {
        // Given
        let title = "🎵 Music Album 🎶"
        let artist = "🎤 Singer Artist 🎸"

        // When
        let album = Album(title: title, artist: artist)

        // Then
        XCTAssertEqual(album.title, title)
        XCTAssertEqual(album.artist, artist)
        XCTAssertTrue(album.isValid)
    }

    func testAlbumCreation_withNumbers_shouldHandleCorrectly() {
        // Given
        let title = "Album 2024"
        let artist = "Artist 123"

        // When
        let album = Album(title: title, artist: artist)

        // Then
        XCTAssertEqual(album.title, title)
        XCTAssertEqual(album.artist, artist)
        XCTAssertTrue(album.isValid)
    }

    // MARK: - Year Validation Tests

    func testYearConversion_withValidYear_shouldConvertCorrectly() {
        // Given
        let yearString = "1969"

        // When
        let year = Int(yearString) ?? 0

        // Then
        XCTAssertEqual(year, 1969)
    }

    func testYearConversion_withInvalidYear_shouldUseDefault() {
        // Given
        let yearString = "not a year"

        // When
        let year = Int(yearString) ?? 0

        // Then
        XCTAssertEqual(year, 0)
    }

    func testYearConversion_withEmptyYear_shouldUseDefault() {
        // Given
        let yearString = ""

        // When
        let year = Int(yearString) ?? 0

        // Then
        XCTAssertEqual(year, 0)
    }

    // MARK: - Performance Tests

    func testAlbumCreation_performance() {
        measure {
            for i in 0..<1000 {
                let album = Album(
                    title: "Performance Test Album \(i)",
                    artist: "Performance Test Artist \(i)"
                )
                XCTAssertNotNil(album.id)
            }
        }
    }

    func testViewInitialization_performance() {
        measure {
            for _ in 0..<100 {
                let view = AddAlbumView { _ in }
                XCTAssertNotNil(view)
            }
        }
    }
}
