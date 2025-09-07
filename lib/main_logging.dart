import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  // ログ開始
  await _logToFile('=== アプリ起動開始 ===');
  await _logToFile('プラットフォーム: ${Platform.operatingSystem}');
  await _logToFile('デバッグモード: $kDebugMode');
  
  try {
    await _logToFile('WidgetsFlutterBinding.ensureInitialized() 実行中...');
    WidgetsFlutterBinding.ensureInitialized();
    await _logToFile('WidgetsFlutterBinding.ensureInitialized() 完了');
    
    await _logToFile('runApp() 実行中...');
    runApp(const LoggingTestApp());
    await _logToFile('runApp() 完了');
    
  } catch (e, stack) {
    await _logToFile('main()でエラー発生: $e');
    await _logToFile('スタックトレース: $stack');
    rethrow;
  }
}

Future<void> _logToFile(String message) async {
  final timestamp = DateTime.now().toIso8601String();
  final logMessage = '[$timestamp] $message';
  
  // デバッグ出力
  debugPrint(logMessage);
  
  // ファイル出力（実機でのデバッグ用）
  try {
    final directory = Directory('/var/mobile/Containers/Data/Application/Documents') 
        ?? Directory.systemTemp;
    final file = File('${directory.path}/startup_log.txt');
    await file.writeAsString('$logMessage\n', mode: FileMode.append);
  } catch (e) {
    debugPrint('ログファイル書き込みエラー: $e');
  }
}

class LoggingTestApp extends StatelessWidget {
  const LoggingTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    _logToFile('LoggingTestApp.build() 開始');
    
    return MaterialApp(
      title: 'Logging Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const LoggingTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoggingTestScreen extends StatefulWidget {
  const LoggingTestScreen({super.key});

  @override
  State<LoggingTestScreen> createState() => _LoggingTestScreenState();
}

class _LoggingTestScreenState extends State<LoggingTestScreen> {
  List<String> logs = [];
  
  @override
  void initState() {
    super.initState();
    _logToFile('LoggingTestScreen.initState() 開始');
    _loadLogs();
  }

  void _loadLogs() async {
    try {
      _logToFile('ログファイル読み込み開始');
      final directory = Directory('/var/mobile/Containers/Data/Application/Documents') 
          ?? Directory.systemTemp;
      final file = File('${directory.path}/startup_log.txt');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final newLogs = content.split('\n').where((line) => line.isNotEmpty).toList();
        
        setState(() {
          logs = newLogs;
        });
        
        _logToFile('ログファイル読み込み完了: ${logs.length}行');
      } else {
        _logToFile('ログファイルが存在しません');
      }
    } catch (e) {
      _logToFile('ログファイル読み込みエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Logging Test'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade100,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'スタートアップログ取得テスト',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'プラットフォーム: ${Platform.operatingSystem}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'ログ件数: ${logs.length}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'アプリが起動しました',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('ログを読み込み中...'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[logs.length - 1 - index]; // 最新が上に
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          log,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _logToFile('テストボタンが押されました');
          _loadLogs();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
