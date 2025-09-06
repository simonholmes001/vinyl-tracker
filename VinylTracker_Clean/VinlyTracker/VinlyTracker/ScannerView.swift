// ScannerView.swift
// Camera scanning interface with mock album recognition

import SwiftUI

struct ScannerView: View {
    let onAlbumScanned: (Album) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isScanning = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Album Scanner")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Tap the button below to simulate scanning an album cover")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if isScanning {
                    ProgressView("Recognizing album...")
                        .padding()
                } else {
                    Button("Scan Mock Album") {
                        simulateScan()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
                }
                
                Spacer()
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func simulateScan() {
        isScanning = true
        
        // Simulate recognition delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isScanning = false
            
            // Mock album recognition - randomly select from famous albums
            let mockAlbums = [
                Album(title: "Abbey Road", artist: "The Beatles", year: 1969, genre: "Rock"),
                Album(title: "Dark Side of the Moon", artist: "Pink Floyd", year: 1973, genre: "Progressive Rock"),
                Album(title: "Thriller", artist: "Michael Jackson", year: 1982, genre: "Pop"),
                Album(title: "Nevermind", artist: "Nirvana", year: 1991, genre: "Grunge"),
                Album(title: "OK Computer", artist: "Radiohead", year: 1997, genre: "Alternative Rock")
            ]
            
            let randomAlbum = mockAlbums.randomElement()!
            onAlbumScanned(randomAlbum)
        }
    }
}

#Preview {
    ScannerView { album in
        print("Scanned: \(album.title)")
    }
}

