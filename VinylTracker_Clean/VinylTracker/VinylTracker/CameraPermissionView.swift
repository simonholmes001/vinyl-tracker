// CameraPermissionView.swift
// UI for handling camera permission requests and settings navigation

import SwiftUI

struct CameraPermissionView: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""

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

                    Text(permissionMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Action Buttons
                VStack(spacing: 12) {
                    Button("Open Settings") {
                        openSettingsWithFeedback()
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
            .alert("Settings", isPresented: $showingAlert) {
                Button("OK") {
                    if CameraPermissionManager.isRunningInSimulator {
                        onDismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var permissionMessage: String {
        if CameraPermissionManager.isRunningInSimulator {
            return "To scan album covers, VinylTracker needs camera access. On a real device, you can enable this in Settings > Privacy & Security > Camera > VinylTracker. Camera functionality is limited in the simulator."
        } else {
            return "To scan album covers, VinylTracker needs access to your camera. Please enable camera access in Settings."
        }
    }

    private func openSettingsWithFeedback() {
        if CameraPermissionManager.isRunningInSimulator {
            alertMessage = "Camera permissions are limited in the iOS Simulator. On a real device, this would open your app's camera settings where you can enable camera access."
            showingAlert = true
            // Don't dismiss immediately in simulator - let user read the alert
        } else {
            CameraPermissionManager.openSettings { success in
                DispatchQueue.main.async {
                    if !success {
                        self.alertMessage = "Unable to open Settings. Please manually go to Settings > Privacy & Security > Camera > VinylTracker to enable camera access."
                        self.showingAlert = true
                    } else {
                        // Settings opened successfully, dismiss the view
                        self.onDismiss()
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
