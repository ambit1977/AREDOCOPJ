import 'package:flutter/material.dart';

// This is a stub file for mobile platforms to make conditional imports work
class WebCameraService {
  Future<String?> takePicture() async {
    // This will never be called on mobile
    return null;
  }

  Future<String?> pickImageFromGallery() async {
    // This will never be called on mobile
    return null;
  }

  Future<void> showImageSourceDialog(
    BuildContext context,
    Function(String?) onImageSelected,
  ) async {
    // This will never be called on mobile
  }
}
