import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

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
        return await _saveImageToLocalDirectory(image);
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
        return await _saveImageToLocalDirectory(image);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<String> _saveImageToLocalDirectory(XFile image) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String imagesDir = path.join(appDocDir.path, 'images');
    
    // Create images directory if it doesn't exist
    await Directory(imagesDir).create(recursive: true);
    
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String localPath = path.join(imagesDir, fileName);
    
    // Copy file to local directory
    await File(image.path).copy(localPath);
    
    return localPath;
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
