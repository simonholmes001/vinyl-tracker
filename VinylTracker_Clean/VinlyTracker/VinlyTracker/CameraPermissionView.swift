// CameraPermissionView.swift
// UI for handling camera permission requests and settings navigation

import SwiftUI

struct CameraPermissionView: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: "camera.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                // Title and Description
                VStack(spacing: 16) {
                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("To scan album covers, VinylTracker needs access to your camera. Please enable camera access in Settings.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Open Settings") {
                        CameraPermissionManager.openSettings()
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Cancel") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("Camera Permission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CameraPermissionView {
        print("Permission view dismissed")
    }
}
