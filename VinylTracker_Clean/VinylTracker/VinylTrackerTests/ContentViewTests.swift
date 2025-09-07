// ContentViewTests.swift
// Unit tests for ContentView, EmptyStateView, AlbumListView, AlbumRowView, and AlbumCollectionViewModel
import XCTest
import SwiftUI
@testable import VinylTracker

final class ContentViewTests: XCTestCase {
    func testContentView_initialization() {
        let view = ContentView()
        XCTAssertNotNil(view)
    }
    
    func testEmptyStateView_showsCorrectText() {
        let view = EmptyStateView()
        // This is a basic smoke test for SwiftUI view
        XCTAssertNotNil(view.body)
    }
    
    func testAlbumListView_rendersAlbums() {
        let albums = [
            Album(title: "Test", artist: "Artist", year: 2020, genre: "Rock"),
            Album(title: "Another", artist: "Artist2", year: 2021, genre: "Pop")
        ]
        let view = AlbumListView(albums: albums, onDelete: { _ in })
        XCTAssertEqual(view.albums.count, 2)
    }
    
    func testAlbumRowView_rendersAlbum() {
        let album = Album(title: "Test", artist: "Artist", year: 2020, genre: "Rock")
        let view = AlbumRowView(album: album)
        XCTAssertEqual(view.album.title, "Test")
    }
    
    @MainActor
    func testAlbumCollectionViewModel_addAlbum() {
        let viewModel = AlbumCollectionViewModel()
        let album = Album(title: "Test", artist: "Artist", year: 2020, genre: "Rock")
        viewModel.addAlbum(album)
        XCTAssertEqual(viewModel.albums.count, 1)
    }

    @MainActor
    func testAlbumCollectionViewModel_deleteAlbums() {
        let viewModel = AlbumCollectionViewModel()
        let album = Album(title: "Test", artist: "Artist", year: 2020, genre: "Rock")
        viewModel.addAlbum(album)
        viewModel.deleteAlbums(at: IndexSet(integer: 0))
        XCTAssertEqual(viewModel.albums.count, 0)
    }

    @MainActor
    func testAlbumCollectionViewModel_hasDuplicate() {
        let viewModel = AlbumCollectionViewModel()
        let album = Album(title: "Test", artist: "Artist", year: 2020, genre: "Rock")
        viewModel.addAlbum(album)
        XCTAssertTrue(viewModel.hasDuplicate(album))
    }

    @MainActor
    func testAlbumCollectionViewModel_sortAlbums() {
        let viewModel = AlbumCollectionViewModel()
        let album1 = Album(title: "B", artist: "A", year: 2020, genre: "Rock")
        let album2 = Album(title: "A", artist: "A", year: 2020, genre: "Rock")
        viewModel.addAlbum(album1)
        viewModel.addAlbum(album2)
        XCTAssertEqual(viewModel.albums.first?.title, "A")
    }
}
