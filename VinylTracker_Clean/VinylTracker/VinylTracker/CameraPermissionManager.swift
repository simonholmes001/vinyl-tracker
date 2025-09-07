// CameraPermissionManager.swift
// Camera permissions and availability management

import AVFoundation
import Photos
import UIKit

class CameraPermissionManager {
    
    // MARK: - Camera Availability
    
    static var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    static var isPhotoLibraryAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    // MARK: - Permission Management
    
    static func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        #if targetEnvironment(simulator)
        // In simulator, just return false immediately to avoid permission dialogs
        DispatchQueue.main.async {
            completion(false)
        }
        #else
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
        #endif
    }
    
    static func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        #if targetEnvironment(simulator)
        // In simulator, return true for photo library (usually available)
        DispatchQueue.main.async {
            completion(true)
        }
        #else
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
        #endif
    }
    
    // MARK: - Permission Status
    
    static var cameraPermissionStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    static var photoLibraryPermissionStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    // MARK: - Settings Navigation
    
    static func openSettings(completion: @escaping (Bool) -> Void = { _ in }) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            completion(false)
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                completion(success)
            }
        } else {
            completion(false)
        }
    }
    
    // MARK: - Simulator Detection
    
    static var isRunningInSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
