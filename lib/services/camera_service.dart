import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Conditional imports
import 'web_camera_service.dart' if (dart.library.io) 'mobile_camera_service.dart' as web_service;

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  /// ファイル名から現在のアプリディレクトリでの完全パスを取得
  static Future<String> getImagePath(String fileName) async {
    if (kIsWeb || fileName.startsWith('data:image')) {
      return fileName; // WebやBase64の場合はそのまま返す
    }
    
    if (fileName.contains('/')) {
      // 既に完全パスの場合、ファイル名のみを抽出
      fileName = path.basename(fileName);
    }
    
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDocDir.path, 'images');
      
      // ディレクトリが存在しない場合は作成
      final Directory imagesDirObject = Directory(imagesDir);
      if (!await imagesDirObject.exists()) {
        await imagesDirObject.create(recursive: true);
      }
      
      return path.join(imagesDir, fileName);
    } catch (e) {
      debugPrint('画像パス取得エラー: $e');
      rethrow;
    }
  }

  /// 画像ファイルが存在するかチェック
  static Future<bool> imageExists(String imagePath) async {
    if (kIsWeb || imagePath.startsWith('data:image')) {
      return true; // WebやBase64の場合
    }
    
    try {
      final String fullPath = await getImagePath(imagePath);
      final File file = File(fullPath);
      return await file.exists();
    } catch (e) {
      debugPrint('画像存在チェックエラー: $e');
      return false;
    }
  }

  Future<String?> takePicture() async {
    if (kIsWeb) {
      return await web_service.WebCameraService().takePicture();
    }
    
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
    if (kIsWeb) {
      return await web_service.WebCameraService().pickImageFromGallery();
    }
    
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
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDocDir.path, 'images');
      
      // Create images directory if it doesn't exist
      await Directory(imagesDir).create(recursive: true);
      
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String localPath = path.join(imagesDir, fileName);
      
      // 元のファイルが存在するか確認
      final File sourceFile = File(image.path);
      if (!await sourceFile.exists()) {
        debugPrint('元の画像ファイルが存在しません: ${image.path}');
        throw Exception('元の画像ファイルが存在しません');
      }
      
      // まずファイルを読み込む
      final List<int> imageBytes = await sourceFile.readAsBytes();
      
      // 新しいファイルに書き込む
      final File localFile = File(localPath);
      await localFile.writeAsBytes(imageBytes);
      
      // 保存したファイルが本当に存在するか確認
      if (!await localFile.exists()) {
        debugPrint('保存した画像ファイルが見つかりません: $localPath');
        throw Exception('画像の保存に失敗しました');
      }
      
      debugPrint('画像を保存しました: $localPath');
      
      // ファイル名のみを返す（絶対パスではなく）
      return fileName;
    } catch (e) {
      debugPrint('画像保存エラー: $e');
      rethrow;
    }
  }

  Future<void> showImageSourceDialog(
    BuildContext context,
    Function(String?) onImageSelected,
  ) async {
    if (kIsWeb) {
      return await web_service.WebCameraService().showImageSourceDialog(context, onImageSelected);
    }
    
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
