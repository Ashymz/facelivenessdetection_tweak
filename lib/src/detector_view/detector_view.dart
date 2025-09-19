import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:facelivenessdetection/src/camera_view/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DetectorView extends StatefulWidget {
  const DetectorView({
    super.key,
    required this.title,
    required this.onImage,
    this.text,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onCameraFeedReady,
    this.onCameraLensDirectionChanged,
    this.onController,
    this.cameraSize = const Size(200, 200),
  });
  final Size cameraSize;
  final String title;

  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onCameraFeedReady;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;
  final void Function(CameraController controller)? onController;

  @override
  State<DetectorView> createState() => DetectorViewState();
}

class DetectorViewState extends State<DetectorView> {
  final GlobalKey<CameraViewState> _cameraViewKey = GlobalKey<CameraViewState>();

  @override
  Widget build(BuildContext context) {
    return CameraView(
      key: _cameraViewKey,
      cameraSize: widget.cameraSize,
      onController: widget.onController,
      onImage: (image) {
        widget.onImage.call(image);
      },
      onCameraFeedReady: widget.onCameraFeedReady,
      initialCameraLensDirection: widget.initialCameraLensDirection,
      onCameraLensDirectionChanged: widget.onCameraLensDirectionChanged,
    );
  }

  /// Captures an image from the camera
  Future<Uint8List?> captureImage() async {
    return await _cameraViewKey.currentState?.captureImage();
  }
}
