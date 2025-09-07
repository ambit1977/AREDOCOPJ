import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/ai_config.dart';

class AIService {
  late final GenerativeModel _model;
  
  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AIConfig.geminiApiKey,
    );
  }
  
  /// 画像からアイテムの情報を分析して返す
  Future<ItemAnalysisResult> analyzeItemFromImage(File imageFile) async {
    // テストモードの場合はモックデータを返す
    if (AIConfig.isTestMode) {
      return getMockAnalysisResult();
    }
    
    try {
      // 画像をバイト配列として読み込み
      final imageBytes = await imageFile.readAsBytes();
      
      // Gemini APIに画像とプロンプトを送信
      final content = [
        Content.multi([
          TextPart(AIPrompts.itemAnalysisPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];
      
      final response = await _model.generateContent(content);
      final responseText = response.text;
      
      debugPrint('🤖 Gemini API応答: $responseText');
      
      if (responseText == null || responseText.isEmpty) {
        throw Exception('AIからの応答が空です');
      }
      
      // JSONレスポンスをパース（より厳密な検索）
      final jsonMatch = RegExp(r'\{[^}]*"name"[^}]*\}', dotAll: true).firstMatch(responseText) ??
                       RegExp(r'\{.*?\}', dotAll: true).firstMatch(responseText);
      
      if (jsonMatch == null) {
        debugPrint('❌ JSONが見つかりません。応答全文: $responseText');
        // JSONが見つからない場合は、応答をパースして手動で構築
        return _parseNonJsonResponse(responseText);
      }
      
      final jsonStr = jsonMatch.group(0)!;
      debugPrint('📄 抽出されたJSON: $jsonStr');
      
      try {
        final jsonData = json.decode(jsonStr) as Map<String, dynamic>;
        return ItemAnalysisResult.fromJson(jsonData);
      } catch (e) {
        debugPrint('❌ JSON解析エラー: $e');
        return _parseNonJsonResponse(responseText);
      }
      
    } catch (e) {
      print('AI分析エラー: $e');
      // エラーの場合はデフォルト値を返す
      return ItemAnalysisResult(
        name: '未分類アイテム',
        category: 'その他',
        location: '未設定',
        description: '分析できませんでした',
        confidence: 0.0,
        error: e.toString(),
      );
    }
  }
  
  /// 複数の画像を一括で分析
  Future<List<ItemAnalysisResult>> analyzeMultipleItems(List<File> imageFiles) async {
    final results = <ItemAnalysisResult>[];
    
    for (final imageFile in imageFiles) {
      final result = await analyzeItemFromImage(imageFile);
      results.add(result);
      
      // API制限を考慮して少し待機
      await Future.delayed(const Duration(milliseconds: AIConfig.multiAnalysisDelayMs));
    }
    
    return results;
  }
  
  /// JSON以外の応答をパースしてItemAnalysisResultを作成
  ItemAnalysisResult _parseNonJsonResponse(String responseText) {
    debugPrint('📝 非JSON応答をパース中: $responseText');
    
    // 応答から情報を抽出（キーワードベース）
    String name = '未分類アイテム';
    String category = 'その他';
    String location = '未設定';
    String description = responseText.length > 100 
        ? responseText.substring(0, 100) + '...' 
        : responseText;
    double confidence = 0.5;
    
    // 簡単なキーワード検索で情報を抽出
    if (responseText.contains('家') || responseText.contains('建物') || responseText.contains('住宅')) {
      name = '建物';
      category = 'その他';
      location = '不動産';
      confidence = 0.8;
    } else if (responseText.contains('車') || responseText.contains('自動車')) {
      name = '自動車';
      category = 'その他';
      location = 'ガレージ';
      confidence = 0.7;
    }
    
    return ItemAnalysisResult(
      name: name,
      category: category,
      location: location,
      description: 'AI応答: $description',
      confidence: confidence,
      error: '構造化された応答が得られませんでした',
    );
  }
  
  /// APIキーが設定されているかチェック
  bool get isApiKeyConfigured => AIConfig.isApiKeyConfigured;
  
  /// テストモードかどうか
  bool get isTestMode => AIConfig.isTestMode;
  
  /// テスト用のモック分析結果を返す
  Future<ItemAnalysisResult> getMockAnalysisResult() async {
    // 開発・テスト用のモックデータ
    await Future.delayed(const Duration(seconds: 2)); // API呼び出しをシミュレート
    
    // ランダムなテストデータを生成
    final mockData = [
      {
        'name': 'ワイヤレスマウス',
        'category': '電子機器',
        'location': 'デスク',
        'description': 'ブラックのワイヤレスマウス、使用感あり',
        'confidence': 0.95,
      },
      {
        'name': 'コーヒーカップ',
        'category': 'キッチン用品',
        'location': 'キッチン',
        'description': '白いセラミック製のマグカップ',
        'confidence': 0.88,
      },
      {
        'name': 'ノート',
        'category': '文房具',
        'location': '本棚',
        'description': 'A5サイズの方眼ノート',
        'confidence': 0.92,
      },
      {
        'name': 'Tシャツ',
        'category': '衣類',
        'location': 'クローゼット',
        'description': 'ネイビーの半袖Tシャツ',
        'confidence': 0.85,
      },
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % mockData.length;
    final selectedData = mockData[random];
    
    return ItemAnalysisResult(
      name: selectedData['name'] as String,
      category: selectedData['category'] as String,
      location: selectedData['location'] as String,
      description: selectedData['description'] as String,
      confidence: selectedData['confidence'] as double,
    );
  }
}

/// AI分析結果を格納するクラス
class ItemAnalysisResult {
  final String name;
  final String category;
  final String location;
  final String description;
  final double confidence;
  final String? error;
  
  ItemAnalysisResult({
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    required this.confidence,
    this.error,
  });
  
  factory ItemAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ItemAnalysisResult(
      name: json['name'] as String? ?? '未分類',
      category: json['category'] as String? ?? 'その他',
      location: json['location'] as String? ?? '未設定',
      description: json['description'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'location': location,
      'description': description,
      'confidence': confidence,
      if (error != null) 'error': error,
    };
  }
  
  /// 分析結果が信頼できるかどうか
  bool get isReliable => confidence >= AIConfig.confidenceThreshold;
  
  /// エラーがあるかどうか
  bool get hasError => error != null;
  
  @override
  String toString() {
    return 'ItemAnalysisResult(name: $name, category: $category, confidence: $confidence)';
  }
}
