// ScannerView.swift
// Real camera scanning interface with album recognition

import SwiftUI

struct ScannerView: View {
    let onAlbumScanned: (Album) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingCamera = false
    @State private var showingPermissionView = false
    @State private var isProcessing = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Album Scanner")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Take a photo of an album cover to add it to your collection")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Processing State
                if isProcessing {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Analyzing album cover...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Camera Button
                        Button(action: openCamera) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!CameraPermissionManager.isCameraAvailable)
                    }
                    .padding(.horizontal, 40)
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
            .sheet(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera) { image in
                    handleCapturedImage(image)
                } onError: { error in
                    showError(error)
                }
            }
            .sheet(isPresented: $showingPermissionView) {
                CameraPermissionView {
                    showingPermissionView = false
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Camera Functions
    
    private func openCamera() {
        CameraPermissionManager.checkCameraPermission { granted in
            if granted {
                showingCamera = true
            } else {
                showingPermissionView = true
            }
        }
    }
    
    private func handleCapturedImage(_ image: UIImage) {
        capturedImage = image
        isProcessing = true
        
        // Simulate album recognition processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            recognizeAlbum(from: image)
        }
    }
    
    private func recognizeAlbum(from image: UIImage) {
        // TODO: Implement real album recognition using Vision framework + ML
        // For now, we'll use mock recognition with random albums
        
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
        
        isProcessing = false
        
        // Simulate successful recognition
        let recognizedAlbum = mockAlbums.randomElement()!
        onAlbumScanned(recognizedAlbum)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ScannerView { album in
        print("Scanned: \(album.title)")
    }
}

