import '../config/api_keys.dart';

/// AI機能の設定クラス
class AIConfig {
  // Gemini APIキー（ローカルファイルまたは環境変数から読み込む）
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: ApiKeys.geminiApiKey, // ローカルファイルのキーを使用
  );
  
  /// APIキーが正しく設定されているかチェック
  static bool get isApiKeyConfigured => 
      geminiApiKey.isNotEmpty && 
      geminiApiKey != 'YOUR_NEW_API_KEY_HERE' &&
      geminiApiKey != 'your_actual_api_key_here';
  
  /// テストモード（モックデータを使用）かどうか
  static bool get isTestMode => !isApiKeyConfigured;
  
  /// AI分析のタイムアウト時間（秒）
  static const int analysisTimeoutSeconds = 30;
  
  /// 複数画像分析時の間隔（ミリ秒）
  static const int multiAnalysisDelayMs = 500;
  
  /// サポートされているカテゴリ一覧
  static const List<String> supportedCategories = [
    '衣類',
    '電子機器',
    '本・雑誌',
    'キッチン用品',
    '文房具',
    '化粧品',
    'その他',
  ];
  
  /// 信頼度の閾値（この値以上で信頼できると判断）
  static const double confidenceThreshold = 0.7;
  
  /// API使用時の注意事項
  static const String apiUsageNote = '''
Gemini API を使用するには以下の手順が必要です：

1. Google AI Studio (https://makersuite.google.com/app/apikey) でAPIキーを取得
2. AIServiceクラスの_apiKeyを実際のキーに置き換え
3. 本番環境では環境変数 GEMINI_API_KEY に設定

現在はテストモードで動作しており、実際のAI分析は行われません。
''';
}

/// AI分析用のプロンプトテンプレート
class AIPrompts {
  /// 基本的なアイテム分析プロンプト
  static const String itemAnalysisPrompt = '''
この画像に写っているアイテムを分析して、以下の情報を**必ずJSON形式のみ**で返してください。説明文は一切不要です。

{
  "name": "アイテムの名前（日本語）",
  "category": "カテゴリ（衣類, 電子機器, 本・雑誌, キッチン用品, 文房具, 化粧品, その他のいずれか）",
  "location": "推奨される収納場所（例：クローゼット、デスク、キッチン、本棚など）",
  "description": "アイテムの簡単な説明",
  "confidence": 0.85
}

**重要**: 
- JSON以外の文字は一切含めないでください
- confidenceは0.0から1.0の数値
- categoryは必ず指定された7つから選択
- 説明や追加のテキストは不要、JSON形式のみ返答
''';

  /// より詳細な分析が必要な場合のプロンプト
  static const String detailedAnalysisPrompt = '''
この画像に写っているアイテムを詳細に分析して、以下の情報をJSON形式で返してください：

{
  "name": "アイテムの名前（日本語、ブランド名も含む）",
  "category": "カテゴリ（以下から選択: 衣類, 電子機器, 本・雑誌, キッチン用品, 文房具, 化粧品, その他）",
  "location": "推奨される収納場所",
  "description": "アイテムの詳細な説明（色、サイズ、特徴など）",
  "confidence": 0.0から1.0の信頼度,
  "color": "主要な色",
  "material": "材質（分かる場合）",
  "brand": "ブランド名（分かる場合）",
  "condition": "状態（新品、中古、使用感など）"
}

可能な限り詳細な情報を抽出してください。不明な項目は空文字または "不明" としてください。
''';
}
