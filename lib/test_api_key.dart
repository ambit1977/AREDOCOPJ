import 'package:flutter/material.dart';
import '../config/ai_config.dart';
import '../services/ai_service.dart';

void main() {
  runApp(const ApiKeyTestApp());
}

class ApiKeyTestApp extends StatelessWidget {
  const ApiKeyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Key Test',
      home: const ApiKeyTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ApiKeyTestScreen extends StatefulWidget {
  const ApiKeyTestScreen({super.key});

  @override
  State<ApiKeyTestScreen> createState() => _ApiKeyTestScreenState();
}

class _ApiKeyTestScreenState extends State<ApiKeyTestScreen> {
  final AIService _aiService = AIService();
  String? _testResult;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _testApiKey();
  }

  Future<void> _testApiKey() async {
    setState(() {
      _testing = true;
    });

    try {
      // モック分析をテスト
      final result = await _aiService.getMockAnalysisResult();
      setState(() {
        _testResult = '✅ API設定成功\n'
            'APIキー設定済み: ${_aiService.isApiKeyConfigured}\n'
            'モック分析結果: ${result.name}';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ API設定エラー: $e';
      });
    } finally {
      setState(() {
        _testing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Key テスト'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: _aiService.isApiKeyConfigured ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API設定状況',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _aiService.isApiKeyConfigured ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'APIキー設定: ${_aiService.isApiKeyConfigured ? "設定済み" : "未設定"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'テストモード: ${_aiService.isTestMode ? "有効" : "無効"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'APIキー（部分表示）: ${AIConfig.geminiApiKey.isNotEmpty ? "${AIConfig.geminiApiKey.substring(0, 12)}..." : "なし"}',
                      style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_testing) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('APIテスト中...'),
                  ],
                ),
              ),
            ] else if (_testResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'テスト結果',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _testResult!,
                        style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testing ? null : _testApiKey,
                child: const Text('再テスト'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
