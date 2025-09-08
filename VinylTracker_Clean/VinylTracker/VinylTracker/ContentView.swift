// ContentView.swift
// Modern landing page for VinylTracker

import SwiftUI

struct ContentView: View {
    @State private var showingCollection = false
    @State private var showingAddOptions = false
    @State private var showingCheckOptions = false
    @State private var showingScanner = false
    @State private var showingAddAlbum = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.8),
                        Color.blue.opacity(0.6),
                        Color.cyan.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App title and welcome message
                    VStack(spacing: 16) {
                        Text("🎵 Vinyl Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Organize your vinyl collection with ease")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Action cards
                    VStack(spacing: 20) {
                        LandingActionCard(
                            icon: "opticaldisc",
                            title: "View Collection",
                            subtitle: "Browse your vinyl albums"
                        ) {
                            showingCollection = true
                        }
                        
                        LandingActionCard(
                            icon: "plus.circle",
                            title: "Add Album",
                            subtitle: "Scan or enter manually"
                        ) {
                            showingAddOptions = true
                        }
                        
                        LandingActionCard(
                            icon: "magnifyingglass.circle",
                            title: "Check Album",
                            subtitle: "Verify if you own this album"
                        ) {
                            showingCheckOptions = true
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingCollection) {
            AlbumCollectionView()
        }
        .sheet(isPresented: $showingScanner) {
            ScannerView { album in
                // Handle the scanned album if needed
                showingScanner = false
            }
        }
        .sheet(isPresented: $showingAddAlbum) {
            AddAlbumView { album in
                // Handle the added album if needed
                showingAddAlbum = false
            }
        }
        .actionSheet(isPresented: $showingAddOptions) {
            ActionSheet(
                title: Text("Add Album"),
                message: Text("How would you like to add an album?"),
                buttons: [
                    .default(Text("📸 Scan with Camera")) {
                        showingScanner = true
                    },
                    .default(Text("✍️ Add Manually")) {
                        showingAddAlbum = true
                    },
                    .cancel()
                ]
            )
        }
        .actionSheet(isPresented: $showingCheckOptions) {
            ActionSheet(
                title: Text("Check Album"),
                message: Text("How would you like to check for an album?"),
                buttons: [
                    .default(Text("📸 Scan with Camera")) {
                        showingScanner = true
                    },
                    .default(Text("✍️ Search Manually")) {
                        showingAddAlbum = true
                    },
                    .cancel()
                ]
            )
        }
    }
}

// Modern action card component
struct LandingActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.purple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
