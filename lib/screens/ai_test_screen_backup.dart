import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/ai_service.dart';

class AITestScreen extends StatefulWidget {
  const AITestScreen({super.key});

  @override
  State<AITestScreen> createState() => _AITestScreenState();
}

class _AITestScreenState extends State<AITestScreen> {
  final AIService _aiService = AIService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  ItemAnalysisResult? _analysisResult;
  bool _isAnalyzing = false;
  List<File> _selectedImages = [];
  List<ItemAnalysisResult> _multipleResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI分析テスト'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildApiStatusCard(),
              const SizedBox(height: 16),
              _buildSingleImageSection(),
              const SizedBox(height: 24),
              _buildTestButtons(),
              const SizedBox(height: 32), // 下部に追加余白
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiStatusCard() {
    final isConfigured = _aiService.isApiKeyConfigured;
    return Card(
      color: isConfigured ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isConfigured ? Icons.check_circle : Icons.warning,
              color: isConfigured ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isConfigured
                    ? 'Gemini API が設定されています'
                    : 'Gemini API キーが設定されていません（テストモードで動作）',
                style: TextStyle(
                  color: isConfigured ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '単一画像分析',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // プラットフォーム別のボタン表示
            if (defaultTargetPlatform == TargetPlatform.macOS) ...[
              // macOS専用のファイル選択ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickSingleImageFromGallery,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('ファイルから選択'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              // モバイル用のボタン
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickSingleImage,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('カメラで撮影'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickSingleImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('ギャラリー'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedImage != null && !_isAnalyzing
                    ? _analyzeSingleImage
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isAnalyzing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('分析中...'),
                        ],
                      )
                    : const Text('AI分析実行'),
              ),
            ),
            if (_analysisResult != null) ...[
              const SizedBox(height: 16),
              _buildAnalysisResultCard(_analysisResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'テスト機能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _testMockAnalysis,
                icon: const Icon(Icons.science),
                label: const Text('モック分析テスト'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResultCard(ItemAnalysisResult result, {int? index}) {
    return Container(
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
                Container(
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
            ], // else ブロックの終了
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

  Future<void> _pickSingleImageFromGallery() async {
    debugPrint('🖼️ ギャラリー選択開始');
    try {
      File? selectedFile;
      
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        // macOS専用のファイル選択 - FileType.imageを使用し、allowedExtensionsは使わない
        debugPrint('🍎 macOS用ファイル選択を使用');
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        
        if (result != null && result.files.single.path != null) {
          selectedFile = File(result.files.single.path!);
          debugPrint('✅ macOS: ファイル選択成功: ${result.files.single.path}');
        } else {
          debugPrint('⚠️ macOS: ファイル選択がキャンセルされました');
        }
      } else {
        // その他のプラットフォーム（iOS, Android）
        debugPrint('📱 image_pickerを使用');
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          selectedFile = File(image.path);
          debugPrint('✅ モバイル: 画像選択成功: ${image.path}');
        } else {
          debugPrint('⚠️ モバイル: 画像選択がキャンセルされました');
        }
      }
      
      if (selectedFile != null) {
        setState(() {
          _selectedImage = selectedFile;
          _analysisResult = null;
        });
        
        // 成功メッセージを表示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('画像を選択しました: ${selectedFile.path.split('/').last}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ギャラリー選択エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ギャラリー選択エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeSingleImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final result = await _aiService.analyzeItemFromImage(_selectedImage!);
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分析エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _testMockAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _aiService.getMockAnalysisResult();
      setState(() {
        _analysisResult = result;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('モック分析完了'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('モック分析エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
}
