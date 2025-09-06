import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Web platform specific import
import 'dart:html' as html;

class WebCameraService {
  static final WebCameraService _instance = WebCameraService._internal();
  factory WebCameraService() => _instance;
  WebCameraService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<String?> takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await _convertImageToBase64(image);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await _convertImageToBase64(image);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<String> _convertImageToBase64(XFile image) async {
    final Uint8List bytes = await image.readAsBytes();
    final String base64String = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  Future<void> showImageSourceDialog(
    BuildContext context,
    Function(String?) onImageSelected,
  ) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('カメラで撮影'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await takePicture();
                  onImageSelected(imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('ギャラリーから選択'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickImageFromGallery();
                  onImageSelected(imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('キャンセル'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
