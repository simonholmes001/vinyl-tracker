# Camera Integration Setup Instructions

## Required Info.plist Permissions

Add these permissions to your app's Info.plist file:

### 1. Camera Usage Description
```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to scan album covers for automatic recognition and cataloging of your vinyl collection.</string>
```

### 2. Photo Library Usage Description
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app accesses your photo library to scan existing photos of album covers for automatic recognition.</string>
```

## How to Add in Xcode:

1. Open your project in Xcode
2. Select your target in the Project Navigator
3. Go to the "Info" tab
4. Click the "+" button to add new entries
5. Add both keys above with their descriptions

## Features Added:

- ✅ Real camera integration with AVFoundation
- ✅ Photo library access for existing images
- ✅ Camera permission handling with user-friendly prompts
- ✅ Error handling for permission denied scenarios
- ✅ Settings deep-link for permission management
- ✅ Fallback mock scanning for testing
- ✅ Image processing pipeline ready for ML integration

## Next Steps:

1. Add the Info.plist permissions
2. Build and test camera functionality
3. Implement Vision framework for real album recognition
4. Add Core ML model for album identification
5. Integrate with music databases (Discogs, MusicBrainz, etc.)

## Testing:

- Test camera permission flow
- Test photo library access
- Test permission denied scenarios
- Test mock scanning functionality
- Verify image capture quality for album covers
