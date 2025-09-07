import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/ai_service.dart';

class AITestScreen extends StatefulWidget {
  const AITestScreen({Key? key}) : super(key: key);

  @override
  _AITestScreenState createState() => _AITestScreenState();
}

class _AITestScreenState extends State<AITestScreen> {
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = AIService();

  File? _selectedImage;
  List<File> _selectedImages = [];
  ItemAnalysisResult? _analysisResult;
  List<ItemAnalysisResult> _multipleResults = [];
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 機能テスト'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'AI 画像解析テスト',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // 単一画像選択とテスト
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '単一画像テスト',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _pickSingleImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('画像を選択'),
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeSingleImage,
                          icon: _isAnalyzing 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.psychology),
                          label: Text(_isAnalyzing ? '解析中...' : 'AI 解析実行'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 複数画像選択とテスト
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '複数画像テスト',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (Platform.isMacOS) ...[
                        ElevatedButton.icon(
                          onPressed: _pickMultipleImages,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('複数画像を選択'),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickFromCamera(),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('カメラ'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickFromGallery(),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('ギャラリー'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_selectedImages.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text('選択された画像: ${_selectedImages.length}枚'),
                        const SizedBox(height: 10),
                        Container(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeMultipleImages,
                          icon: _isAnalyzing 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.psychology),
                          label: Text(_isAnalyzing ? '解析中...' : '複数画像AI解析実行'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 解析結果表示
              if (_analysisResult != null) ...[
                const Text(
                  '単一画像解析結果:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildAnalysisResultCard(_analysisResult!),
                const SizedBox(height: 20),
              ],
              
              if (_multipleResults.isNotEmpty) ...[
                const Text(
                  '複数画像解析結果:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._multipleResults.asMap().entries.map((entry) {
                  int index = entry.key;
                  ItemAnalysisResult result = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: _buildAnalysisResultCard(result, index: index + 1),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResultCard(ItemAnalysisResult result, {int? index}) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: result.hasError ? Colors.red.shade50 : Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index != null)
                Text(
                  '画像 $index',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              if (result.hasError) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'エラー:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    result.error!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.label, size: 16),
                    const SizedBox(width: 4),
                    const Text('名前: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(result.name, style: const TextStyle(fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.category, size: 16),
                    const SizedBox(width: 4),
                    const Text('カテゴリ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(result.category, style: const TextStyle(fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    const Text('収納場所: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(result.location, style: const TextStyle(fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, size: 16),
                    const SizedBox(width: 4),
                    const Text('説明: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(result.description, style: const TextStyle(fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      result.isReliable ? Icons.check_circle : Icons.warning,
                      color: result.isReliable ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text('信頼度: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${(result.confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: result.isReliable ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickSingleImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _analysisResult = null;
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    if (Platform.isMacOS) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedImages = result.paths.map((path) => File(path!)).toList();
          _multipleResults = [];
        });
      }
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImages = [File(image.path)];
        _multipleResults = [];
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
        _multipleResults = [];
      });
    }
  }

  Future<void> _analyzeSingleImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _aiService.analyzeItemFromImage(_selectedImage!);
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      setState(() {
        _analysisResult = ItemAnalysisResult.error('解析エラー: $e');
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeMultipleImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _multipleResults = [];
    });

    try {
      List<ItemAnalysisResult> results = [];
      for (File image in _selectedImages) {
        final result = await _aiService.analyzeItemFromImage(image);
        results.add(result);
        
        // 進行状況を表示するため、1つずつ結果を更新
        setState(() {
          _multipleResults = List.from(results);
        });
      }
    } catch (e) {
      final errorResult = ItemAnalysisResult.error('解析エラー: $e');
      setState(() {
        _multipleResults.add(errorResult);
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
}
