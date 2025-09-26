import XCTest
@testable import VinylTracker

final class AlbumTests: XCTestCase {
    func testAlbumValidationRequiresTitleAndArtist() {
        let valid = Album(title: "In Rainbows", artist: "Radiohead")
        XCTAssertTrue(valid.isValid)

        let noTitle = Album(title: "", artist: "Radiohead")
        XCTAssertFalse(noTitle.isValid)

        let noArtist = Album(title: "In Rainbows", artist: " ")
        XCTAssertFalse(noArtist.isValid)
    }

    func testDuplicateKeyNormalisesText() {
        let albumA = Album(title: " OK Computer ", artist: "Radiohead")
        let albumB = Album(title: "ok computer", artist: "RADIOHEAD")
        XCTAssertEqual(albumA.duplicateKey, albumB.duplicateKey)
    }

    func testMatchesQueryFindsByTitleArtistGenreAndLabel() {
        let album = Album(title: "Blue Train", artist: "John Coltrane", year: 1957, genre: "Jazz", label: "Blue Note")
        XCTAssertTrue(album.matches(query: "john"))
        XCTAssertTrue(album.matches(query: "blue"))
        XCTAssertTrue(album.matches(query: "jazz"))
        XCTAssertTrue(album.matches(query: "note"))
        XCTAssertFalse(album.matches(query: "metal"))
    }

    func testArtworkPresence() {
        let albumWithoutArt = Album(title: "Kind of Blue", artist: "Miles Davis")
        XCTAssertFalse(albumWithoutArt.hasArtwork)

        let dummyData = Data(repeating: 1, count: 10)
        let albumWithArt = Album(title: "Kind of Blue", artist: "Miles Davis", imageData: dummyData)
        XCTAssertTrue(albumWithArt.hasArtwork)
    }
}
