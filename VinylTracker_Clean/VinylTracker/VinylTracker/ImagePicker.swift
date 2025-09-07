// ImagePicker.swift
// UIImagePickerController wrapper for SwiftUI camera integration

import SwiftUI
import UIKit
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    let onError: (String) -> Void

    init(
        sourceType: UIImagePickerController.SourceType,
        onImagePicked: @escaping (UIImage) -> Void,
        onError: @escaping (String) -> Void = { _ in }
    ) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
        self.onError = onError
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false

        // Configure camera settings for album covers
        if sourceType == .camera {
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            } else {
                parent.onError("Failed to capture image")
            }

            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
