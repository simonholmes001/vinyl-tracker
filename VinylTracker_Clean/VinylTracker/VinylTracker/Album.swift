// Album.swift
// Core data model with TDD validation

import Foundation

struct Album: Identifiable, Codable {
    let id = UUID()
    let title: String
    let artist: String
    let year: Int
    let genre: String
    let label: String
    let dateAdded = Date()
    
    init(title: String, artist: String, year: Int = 0, genre: String = "", label: String = "") {
        self.title = title
        self.artist = artist
        self.year = year
        self.genre = genre
        self.label = label
    }
    
    // MARK: - Validation (TDD)
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Duplicate Detection (TDD)
    func isSimilarTo(_ other: Album) -> Bool {
        let thisTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let otherTitle = other.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let thisArtist = artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let otherArtist = other.artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return thisTitle == otherTitle && thisArtist == otherArtist
    }
    
    // MARK: - Display Properties
    var displayTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var displayArtist: String {
        artist.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var yearString: String {
        year > 0 ? "\(year)" : ""
    }
    
    var displayName: String {
        var name = "\(displayTitle) by \(displayArtist)"
        if !yearString.isEmpty {
            name += " (\(yearString))"
        }
        if !genre.isEmpty {
            name += " - \(genre)"
        }
        return name
    }
}

