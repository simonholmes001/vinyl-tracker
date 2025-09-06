import XCTest
@testable import VinlyTracker

class AlbumTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testAlbum_InitWithAllParameters_ShouldSetAllProperties() {
        // Given
        let title = "Abbey Road"
        let artist = "The Beatles"
        let year = 1969
        let genre = "Rock"
        let label = "Apple Records"
        
        // When
        let album = Album(title: title, artist: artist, year: year, genre: genre, label: label)
        
        // Then
        XCTAssertEqual(album.title, title)
        XCTAssertEqual(album.artist, artist)
        XCTAssertEqual(album.year, year)
        XCTAssertEqual(album.genre, genre)
        XCTAssertEqual(album.label, label)
        XCTAssertNotNil(album.id)
        XCTAssertNotNil(album.dateAdded)
    }
    
    func testAlbum_InitWithMinimalParameters_ShouldUseDefaults() {
        // Given
        let title = "Unknown Album"
        let artist = "Unknown Artist"
        
        // When
        let album = Album(title: title, artist: artist)
        
        // Then
        XCTAssertEqual(album.title, title)
        XCTAssertEqual(album.artist, artist)
        XCTAssertEqual(album.year, 0)
        XCTAssertEqual(album.genre, "")
        XCTAssertEqual(album.label, "")
    }
    
    func testAlbum_ID_ShouldBeUnique() {
        // Given & When
        let album1 = Album(title: "Test", artist: "Test")
        let album2 = Album(title: "Test", artist: "Test")
        
        // Then
        XCTAssertNotEqual(album1.id, album2.id)
    }
    
    func testAlbum_DateAdded_ShouldBeCurrentDate() {
        // Given
        let beforeCreation = Date()
        
        // When
        let album = Album(title: "Test", artist: "Test")
        let afterCreation = Date()
        
        // Then
        XCTAssertGreaterThanOrEqual(album.dateAdded, beforeCreation)
        XCTAssertLessThanOrEqual(album.dateAdded, afterCreation)
    }
    
    // MARK: - Validation Tests
    
    func testAlbum_isValid_WithValidTitleAndArtist_ShouldReturnTrue() {
        // Given
        let album = Album(title: "Valid Title", artist: "Valid Artist")
        
        // When
        let isValid = album.isValid
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    func testAlbum_isValid_WithEmptyTitle_ShouldReturnFalse() {
        // Given
        let album = Album(title: "", artist: "Valid Artist")
        
        // When
        let isValid = album.isValid
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testAlbum_isValid_WithWhitespaceOnlyTitle_ShouldReturnFalse() {
        // Given
        let album = Album(title: "   \n\t  ", artist: "Valid Artist")
        
        // When
        let isValid = album.isValid
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testAlbum_isValid_WithEmptyArtist_ShouldReturnFalse() {
        // Given
        let album = Album(title: "Valid Title", artist: "")
        
        // When
        let isValid = album.isValid
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testAlbum_isValid_WithWhitespaceOnlyArtist_ShouldReturnFalse() {
        // Given
        let album = Album(title: "Valid Title", artist: "   \n\t  ")
        
        // When
        let isValid = album.isValid
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testAlbum_isValid_WithBothTitleAndArtistEmpty_ShouldReturnFalse() {
        // Given
        let album = Album(title: "", artist: "")
        
        // When
        let isValid = album.isValid
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    // MARK: - Similarity Detection Tests
    
    func testAlbum_isSimilarTo_WithIdenticalTitleAndArtist_ShouldReturnTrue() {
        // Given
        let album1 = Album(title: "Abbey Road", artist: "The Beatles")
        let album2 = Album(title: "Abbey Road", artist: "The Beatles")
        
        // When
        let isSimilar = album1.isSimilarTo(album2)
        
        // Then
        XCTAssertTrue(isSimilar)
    }
    
    func testAlbum_isSimilarTo_WithDifferentCasing_ShouldReturnTrue() {
        // Given
        let album1 = Album(title: "abbey road", artist: "the beatles")
        let album2 = Album(title: "ABBEY ROAD", artist: "THE BEATLES")
        
        // When
        let isSimilar = album1.isSimilarTo(album2)
        
        // Then
        XCTAssertTrue(isSimilar)
    }
    
    func testAlbum_isSimilarTo_WithExtraWhitespace_ShouldReturnTrue() {
        // Given
        let album1 = Album(title: "  Abbey Road  ", artist: "  The Beatles  ")
        let album2 = Album(title: "Abbey Road", artist: "The Beatles")
        
        // When
        let isSimilar = album1.isSimilarTo(album2)
        
        // Then
        XCTAssertTrue(isSimilar)
    }
    
    func testAlbum_isSimilarTo_WithDifferentTitle_ShouldReturnFalse() {
        // Given
        let album1 = Album(title: "Abbey Road", artist: "The Beatles")
        let album2 = Album(title: "Revolver", artist: "The Beatles")
        
        // When
        let isSimilar = album1.isSimilarTo(album2)
        
        // Then
        XCTAssertFalse(isSimilar)
    }
    
    func testAlbum_isSimilarTo_WithDifferentArtist_ShouldReturnFalse() {
        // Given
        let album1 = Album(title: "Abbey Road", artist: "The Beatles")
        let album2 = Album(title: "Abbey Road", artist: "Pink Floyd")
        
        // When
        let isSimilar = album1.isSimilarTo(album2)
        
        // Then
        XCTAssertFalse(isSimilar)
    }
    
    func testAlbum_isSimilarTo_WithDifferentTitleAndArtist_ShouldReturnFalse() {
        // Given
        let album1 = Album(title: "Abbey Road", artist: "The Beatles")
        let album2 = Album(title: "Dark Side of the Moon", artist: "Pink Floyd")
        
        // When
        let isSimilar = album1.isSimilarTo(album2)
        
        // Then
        XCTAssertFalse(isSimilar)
    }
    
    // MARK: - Display Property Tests
    
    func testAlbum_displayTitle_ShouldTrimWhitespace() {
        // Given
        let album = Album(title: "  Abbey Road  ", artist: "The Beatles")
        
        // When
        let displayTitle = album.displayTitle
        
        // Then
        XCTAssertEqual(displayTitle, "Abbey Road")
    }
    
    func testAlbum_displayArtist_ShouldTrimWhitespace() {
        // Given
        let album = Album(title: "Abbey Road", artist: "  The Beatles  ")
        
        // When
        let displayArtist = album.displayArtist
        
        // Then
        XCTAssertEqual(displayArtist, "The Beatles")
    }
    
    func testAlbum_yearString_WithValidYear_ShouldReturnYearAsString() {
        // Given
        let album = Album(title: "Test", artist: "Test", year: 1969)
        
        // When
        let yearString = album.yearString
        
        // Then
        XCTAssertEqual(yearString, "1969")
    }
    
    func testAlbum_yearString_WithZeroYear_ShouldReturnEmptyString() {
        // Given
        let album = Album(title: "Test", artist: "Test", year: 0)
        
        // When
        let yearString = album.yearString
        
        // Then
        XCTAssertEqual(yearString, "")
    }
    
    func testAlbum_yearString_WithNegativeYear_ShouldReturnEmptyString() {
        // Given
        let album = Album(title: "Test", artist: "Test", year: -1)
        
        // When
        let yearString = album.yearString
        
        // Then
        XCTAssertEqual(yearString, "")
    }
    
    func testAlbum_displayName_WithAllFields_ShouldReturnCompleteDisplayName() {
        // Given
        let album = Album(title: "Abbey Road", artist: "The Beatles", year: 1969, genre: "Rock")
        
        // When
        let displayName = album.displayName
        
        // Then
        XCTAssertEqual(displayName, "Abbey Road by The Beatles (1969) - Rock")
    }
    
    func testAlbum_displayName_WithoutYear_ShouldExcludeYear() {
        // Given
        let album = Album(title: "Abbey Road", artist: "The Beatles", genre: "Rock")
        
        // When
        let displayName = album.displayName
        
        // Then
        XCTAssertEqual(displayName, "Abbey Road by The Beatles - Rock")
    }
    
    func testAlbum_displayName_WithoutGenre_ShouldExcludeGenre() {
        // Given
        let album = Album(title: "Abbey Road", artist: "The Beatles", year: 1969)
        
        // When
        let displayName = album.displayName
        
        // Then
        XCTAssertEqual(displayName, "Abbey Road by The Beatles (1969)")
    }
    
    func testAlbum_displayName_WithMinimalData_ShouldReturnBasicDisplayName() {
        // Given
        let album = Album(title: "Abbey Road", artist: "The Beatles")
        
        // When
        let displayName = album.displayName
        
        // Then
        XCTAssertEqual(displayName, "Abbey Road by The Beatles")
    }
    
    func testAlbum_displayName_WithEmptyGenre_ShouldExcludeGenre() {
        // Given
        let album = Album(title: "Abbey Road", artist: "The Beatles", year: 1969, genre: "")
        
        // When
        let displayName = album.displayName
        
        // Then
        XCTAssertEqual(displayName, "Abbey Road by The Beatles (1969)")
    }
    
    // MARK: - Codable Tests
    
    func testAlbum_Codable_ShouldEncodeAndDecodeCorrectly() throws {
        // Given
        let originalAlbum = Album(title: "Abbey Road", artist: "The Beatles", year: 1969, genre: "Rock", label: "Apple")
        
        // When
        let encodedData = try JSONEncoder().encode(originalAlbum)
        let decodedAlbum = try JSONDecoder().decode(Album.self, from: encodedData)
        
        // Then
        XCTAssertEqual(decodedAlbum.title, originalAlbum.title)
        XCTAssertEqual(decodedAlbum.artist, originalAlbum.artist)
        XCTAssertEqual(decodedAlbum.year, originalAlbum.year)
        XCTAssertEqual(decodedAlbum.genre, originalAlbum.genre)
        XCTAssertEqual(decodedAlbum.label, originalAlbum.label)
        // Note: ID and dateAdded will be different for decoded album due to initialization
    }
}
