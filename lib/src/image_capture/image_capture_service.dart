import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:facelivenessdetection/src/rule_set/rule_set.dart';

class ImageCaptureService {
  static const String _imageDirectory = 'face_detection_captures';
  
  /// Captures and saves an image for a specific rule
  static Future<String?> captureImageForRule({
    required Uint8List imageBytes,
    required Rulesets rule,
    String? customDirectory,
  }) async {
    try {
      final directory = await _getImageDirectory(customDirectory);
      final fileName = _generateFileName(rule);
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      debugPrint('Error capturing image for rule $rule: $e');
      return null;
    }
  }
  
  /// Gets the directory for storing captured images
  static Future<Directory> _getImageDirectory(String? customDirectory) async {
    Directory directory;
    
    if (customDirectory != null) {
      directory = Directory(customDirectory);
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      directory = Directory('${appDir.path}/$_imageDirectory');
    }
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }
  
  /// Generates a meaningful filename for the captured image
  static String _generateFileName(Rulesets rule) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ruleName = _getRuleName(rule);
    return '${ruleName}_$timestamp.jpg';
  }
  
  /// Converts rule enum to readable string
  static String _getRuleName(Rulesets rule) {
    switch (rule) {
      case Rulesets.smiling:
        return 'smile';
      case Rulesets.blink:
        return 'blink';
      case Rulesets.tiltUp:
        return 'tilt_up';
      case Rulesets.tiltDown:
        return 'tilt_down';
      case Rulesets.toLeft:
        return 'look_left';
      case Rulesets.toRight:
        return 'look_right';
    }
  }
  
  /// Cleans up old captured images (optional utility)
  static Future<void> cleanupOldImages({
    int maxAgeInDays = 7,
    String? customDirectory,
  }) async {
    try {
      final directory = await _getImageDirectory(customDirectory);
      final files = directory.listSync();
      final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old images: $e');
    }
  }
  
  /// Gets all captured images from the directory
  static Future<List<File>> getAllCapturedImages({
    String? customDirectory,
  }) async {
    try {
      final directory = await _getImageDirectory(customDirectory);
      final files = directory.listSync();
      return files.whereType<File>().toList();
    } catch (e) {
      debugPrint('Error getting captured images: $e');
      return [];
    }
  }
  
  /// Converts image file to base64 string for backend upload
  static Future<String?> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }
  
  /// Gets image metadata (rule, timestamp) from filename
  static Map<String, dynamic>? getImageMetadata(String filePath) {
    try {
      final fileName = filePath.split('/').last;
      final parts = fileName.split('_');
      if (parts.length >= 2) {
        final ruleName = parts[0];
        final timestamp = int.tryParse(parts[1].split('.').first);
        
        return {
          'rule': ruleName,
          'timestamp': timestamp,
          'dateTime': timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null,
          'filePath': filePath,
        };
      }
    } catch (e) {
      debugPrint('Error parsing image metadata: $e');
    }
    return null;
  }
}
