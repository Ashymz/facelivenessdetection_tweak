# Facelivenessdetection

A real-time facial verification feature using Google ML Kit for liveliness detection. It ensures user interaction through smiling, blinking, and head movements. Features include face detection, dynamic feedback, a countdown timer, and customizable UI—ideal for secure authentication and anti-spoofisng verification. 🚀

## Features

- **Detects user presence** with a face detection engine.
- **Displays dynamic UI feedback** for each rule.
- **Animated transitions** when detecting face presence.
- **Handles countdown timers** before validation.
- **Efficient state management** with rule tracking.
- **🆕 Automatic image capture** for each completed rule.
- **🆕 Configurable image storage** with custom directory support.
- **🆕 Responsive UI** that adapts to different screen sizes.
- **🆕 Fast rule processing** with 1-second countdown timers.

## Setup 
## iOS 
# Uncomment this line to define a global platform for your project
```dart
platform :ios, '15.5.0'
```

Add two rows to the ios/Runner/Info.plist:

**one with the key Privacy** - Camera Usage Description and a usage description.
**and one with the key Privacy** - Microphone Usage Description and a usage description.
**If editing Info.plist as text, add**:
```dart
 <key>NSCameraUsageDescription</key>
 <string>your usage description here</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>your usage description here</string>
```
## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  facelivenessdetection: ^1.0.0
  path_provider: ^2.1.1  # Required for image capture
```

Then run:
```bash
flutter pub get
```

## Usage

### Basic Usage

To use this widget, add it inside a Flutter screen:

![image](https://github.com/user-attachments/assets/eb0ca715-27f8-4aa5-9e23-fd11825e8960)
![image](https://github.com/user-attachments/assets/5f6729b3-8ec8-4d2a-b728-bcbb299379ae)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:facelivenessdetection/facelivenessdetection.dart';

class FaceVerificationWidget extends StatefulWidget {
  @override
  _FaceVerificationWidgetState createState() => _FaceVerificationWidgetState();
}

class _FaceVerificationWidgetState extends State<FaceVerificationWidget> {
  final List<String> _completedRuleset = [];

  @override
  Widget build(BuildContext context) {
    return FaceDetectorView(
      onSuccessValidation: (validated) {},
      child: ({required countdown, required state, required hasFace}) {
        return [
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/face_verification_icon.png', height: 30, width: 30),
              const SizedBox(width: 10),
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    hasFace ? 'User face found' : 'User face not found',
                    style: _textStyle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            _rulesetHints[state] ?? 'Please follow instructions',
            style: _textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          if (countdown > 0)
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'IN\n'),
                  TextSpan(
                    text: countdown.toString(),
                    style: _textStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: _textStyle.copyWith(fontSize: 16),
            )
          else
            const Column(
              children: [
                SizedBox(height: 50),
                CupertinoActivityIndicator(),
              ],
            ),
        ];
      },
      onRulesetCompleted: (ruleset) {
        if (!_completedRuleset.contains(ruleset)) {
          setState(() => _completedRuleset.add(ruleset));
        }
      },
    );
  }
}

/// Text style for UI consistency
const TextStyle _textStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.w400,
  fontSize: 12,
);

/// Ruleset hints for better performance (eliminating switch-case)
const Map<Rulesets, String> _rulesetHints = {
  Rulesets.smiling: 'Please Smile',
  Rulesets.blink: 'Please Blink',
  Rulesets.tiltUp: 'Please Look Up',
  Rulesets.tiltDown: 'Please Look Down',
  Rulesets.toLeft: 'Please Look Left',
  Rulesets.toRight: 'Please Look Right',
};
```

### Advanced Usage with Image Capture

For applications that need to capture images during face verification:

```dart
import 'package:flutter/material.dart';
import 'package:facelivenessdetection/facelivenessdetection.dart';
import 'dart:io';

class FaceVerificationWithCapture extends StatefulWidget {
  @override
  _FaceVerificationWithCaptureState createState() => _FaceVerificationWithCaptureState();
}

class _FaceVerificationWithCaptureState extends State<FaceVerificationWithCapture> {
  final List<CapturedImage> _capturedImages = [];
  final List<Rulesets> _completedRuleset = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Verification with Capture')),
      body: Column(
        children: [
          // Face Detection Widget
          Expanded(
            flex: 2,
            child: FaceDetectorView(
              cameraSize: const Size(200, 200),
              onSuccessValidation: (validated) {
                print('Face verification completed: $validated');
              },
              onValidationDone: (controller) {
                return const Text('Verification Completed!');
              },
              // Enable image capture
              enableImageCapture: true,
              onImageCaptured: (imagePath, rule) {
                setState(() {
                  _capturedImages.add(CapturedImage(path: imagePath, rule: rule));
                });
                print('Image captured for $rule: $imagePath');
              },
              onImageCaptureError: (error) {
                print('Image capture error: $error');
              },
              child: ({required countdown, required state, required hasFace}) {
                return Column(
                  children: [
                    Text(
                      hasFace ? 'Face detected' : 'No face detected',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _rulesetHints[state] ?? 'Please follow instructions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (countdown > 0)
                      Text('$countdown', style: TextStyle(fontSize: 24))
                    else
                      CircularProgressIndicator(),
                  ],
                );
              },
              onRulesetCompleted: (ruleset) {
                if (!_completedRuleset.contains(ruleset)) {
                  setState(() => _completedRuleset.add(ruleset));
                }
              },
            ),
          ),
          // Captured Images Display
          Expanded(
            flex: 1,
            child: _capturedImages.isEmpty
                ? Center(child: Text('No images captured yet'))
                : GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _capturedImages.length,
                    itemBuilder: (context, index) {
                      final capturedImage = _capturedImages[index];
                      return Column(
                        children: [
                          Expanded(
                            child: Image.file(
                              File(capturedImage.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            capturedImage.rule.name,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CapturedImage {
  final String path;
  final Rulesets rule;
  
  CapturedImage({required this.path, required this.rule});
}
```

### Configuration Options

The `FaceDetectorView` widget supports various configuration options:

```dart
FaceDetectorView(
  // Required parameters
  onSuccessValidation: (bool validated) {},
  child: ({required countdown, required state, required hasFace}) => Widget,
  
  // Optional parameters
  ruleset: [Rulesets.smiling, Rulesets.blink], // Default: all rules
  cameraSize: Size(200, 200), // Camera preview size
  pauseDurationInSeconds: 1, // Countdown duration for each rule
  enableImageCapture: false, // Enable automatic image capture
  imageCaptureDirectory: '/custom/path', // Custom directory for images
  onImageCaptured: (String imagePath, Rulesets rule) {}, // Image capture callback
  onImageCaptureError: (String error) {}, // Error callback
  onRulesetCompleted: (Rulesets rule) {}, // Rule completion callback
  onValidationDone: (CameraController? controller) => Widget, // Completion widget
  backgroundColor: Colors.white, // Background color
  dotRadius: 3, // Progress dots radius
  contextPadding: 16, // UI padding
)
```

### Image Capture Service

The package includes a built-in `ImageCaptureService` for managing captured images:

```dart
import 'package:facelivenessdetection/facelivenessdetection.dart';
import 'dart:io';

// Save image with custom directory
final String? imagePath = await ImageCaptureService.captureImageForRule(
  imageBytes: imageBytes,
  rule: Rulesets.smiling,
  customDirectory: '/custom/path',
);

// Get all captured images
final List<File> images = await ImageCaptureService.getAllCapturedImages();

// Convert image to base64 for backend upload
final String? base64Image = await ImageCaptureService.imageToBase64(imageFile);

// Get image metadata
final Map<String, dynamic>? metadata = ImageCaptureService.getImageMetadata(imagePath);
// Returns: {'rule': 'smile', 'timestamp': 1234567890, 'dateTime': DateTime(...), 'filePath': '...'}

// Clean up old images (older than 7 days)
await ImageCaptureService.cleanupOldImages(maxAgeInDays: 7);
```

### Backend Integration

Here's how to integrate captured images with your backend:

```dart
class FaceVerificationService {
  // Upload all captured images to backend
  static Future<void> uploadCapturedImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      final file = File(imagePath);
      final base64Image = await ImageCaptureService.imageToBase64(file);
      final metadata = ImageCaptureService.getImageMetadata(imagePath);
      
      if (base64Image != null && metadata != null) {
        await _uploadToBackend({
          'image': base64Image,
          'rule': metadata['rule'],
          'timestamp': metadata['timestamp'],
          'mimeType': 'image/jpeg',
        });
      }
    }
  }
  
  // Upload single image with multipart form data
  static Future<void> uploadImageFile(File imageFile, String rule) async {
    final request = http.MultipartRequest('POST', Uri.parse('your-api-endpoint'));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['rule'] = rule;
    request.fields['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    
    final response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    }
  }
  
  static Future<void> _uploadToBackend(Map<String, dynamic> data) async {
    // Your backend upload logic here
    final response = await http.post(
      Uri.parse('your-api-endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    }
  }
}
```

### Image Storage Locations

**Default Storage:**
- **iOS**: `~/Documents/face_detection_captures/`
- **Android**: `/storage/emulated/0/Android/data/your.package.name/files/Documents/face_detection_captures/`
- **Web**: Browser's download folder (when using custom directory)

**Custom Directory:**
```dart
FaceDetectorView(
  enableImageCapture: true,
  imageCaptureDirectory: '/custom/path/to/images', // Custom storage location
  onImageCaptured: (imagePath, rule) {
    // Handle captured image
  },
)
```

### Image File Naming Convention

Images are automatically named with the following pattern:
```
{rule_name}_{timestamp}.jpg
```

Examples:
- `smile_1703123456789.jpg`
- `blink_1703123456790.jpg`
- `tilt_up_1703123456791.jpg`

### Available Rules

The package supports the following face liveness rules:

- `Rulesets.smiling` - User must smile
- `Rulesets.blink` - User must blink
- `Rulesets.tiltUp` - User must look up
- `Rulesets.tiltDown` - User must look down
- `Rulesets.toLeft` - User must look left
- `Rulesets.toRight` - User must look right

## For Package Developers

### Publishing the Package

To publish this package to pub.dev:

1. **Update version** in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

2. **Run analysis** to ensure no issues:
```bash
flutter analyze
```

3. **Run tests**:
```bash
flutter test
```

4. **Check for issues**:
```bash
flutter pub publish --dry-run
```

5. **Publish**:
```bash
flutter pub publish
```

### Development Setup

For local development and testing:

1. **Clone the repository**:
```bash
git clone <repository-url>
cd facelivenessdetection_tweak
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run the example**:
```bash
cd example
flutter run
```

4. **Test on different platforms**:
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d web
```

### Package Structure

```
lib/
├── facelivenessdetection.dart          # Main export file
└── src/
    ├── face_detection/
    │   └── face_detector.dart          # Core FaceDetectorView widget
    ├── camera_view/
    │   └── camera_view.dart            # Camera integration
    ├── detector_view/
    │   └── detector_view.dart          # Detector wrapper
    ├── image_capture/
    │   └── image_capture_service.dart  # Image capture service
    ├── painter/
    │   ├── dotted_painter.dart         # Progress dots painter
    │   └── translator.dart             # UI translations
    ├── rule_set/
    │   └── rule_set.dart               # Rule definitions
    └── debouncer/
        └── debouncer.dart              # Timer management
```

### Key Features for Developers

- **Modular Design**: Each component is separated for easy maintenance
- **Configurable**: Extensive customization options for different use cases
- **Responsive**: Adapts to different screen sizes automatically
- **Error Handling**: Comprehensive error handling and callbacks
- **Performance**: Optimized for real-time face detection
- **Cross-Platform**: Works on iOS, Android, and Web

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Run `flutter analyze` and `flutter test`
6. Submit a pull request

### License

This package is licensed under the MIT License. See the LICENSE file for details.
