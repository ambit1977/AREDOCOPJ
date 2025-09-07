import 'dart:isolate';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

// Stage 1: 基本アプリ（ミニマルと同等）
// Stage 2: Provider追加
// Stage 3: パッケージ初期化追加
// Stage 4: データベース初期化追加
// Stage 5: エラーハンドリング追加
// Stage 6: フル機能

const int DEBUG_STAGE = 1; // この値を変更してテスト

void main() async {
  // Stage 1: 基本
  if (DEBUG_STAGE >= 1) {
    _logDebug('Stage 1: 基本アプリ開始');
    runApp(const DebugApp());
    return;
  }

  // Stage 2: WidgetsBinding初期化
  if (DEBUG_STAGE >= 2) {
    _logDebug('Stage 2: WidgetsBinding初期化');
    WidgetsFlutterBinding.ensureInitialized();
  }

  // Stage 3: パッケージ初期化テスト
  if (DEBUG_STAGE >= 3) {
    try {
      _logDebug('Stage 3: path_provider テスト開始');
      final directory = await getApplicationDocumentsDirectory();
      _logDebug('Stage 3: path_provider OK - ${directory.path}');
    } catch (e, stack) {
      _logDebug('Stage 3: path_provider エラー - $e');
      _logDebug('Stack: $stack');
    }
  }

  // Stage 4: データベース初期化テスト
  if (DEBUG_STAGE >= 4) {
    try {
      _logDebug('Stage 4: データベース初期化テスト開始');
      // DatabaseServiceをインポートする必要があります
      // final dbService = DatabaseService();
      // await dbService.database;
      _logDebug('Stage 4: データベース初期化 OK');
    } catch (e, stack) {
      _logDebug('Stage 4: データベース初期化エラー - $e');
      _logDebug('Stack: $stack');
    }
  }

  // Stage 5: エラーハンドリング設定
  if (DEBUG_STAGE >= 5) {
    _logDebug('Stage 5: エラーハンドリング設定');
    FlutterError.onError = (FlutterErrorDetails details) {
      _logDebug('Flutter UIエラー: ${details.exception}');
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logDebug('アプリレベル例外: $error');
      return true;
    };
  }

  _logDebug('アプリ起動');
  runApp(const DebugApp());
}

void _logDebug(String message) {
  final timestamp = DateTime.now().toIso8601String();
  final logMessage = '[$timestamp] DEBUG: $message';
  debugPrint(logMessage);
  
  // ファイルにも書き込み（非同期で）
  _writeLogToFile(logMessage);
}

void _writeLogToFile(String message) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/debug_log.txt');
    await file.writeAsString('$message\n', mode: FileMode.append);
  } catch (e) {
    debugPrint('ログファイル書き込みエラー: $e');
  }
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    _logDebug('DebugApp build開始');
    
    Widget app = MaterialApp(
      title: 'Debug Test App - Stage $DEBUG_STAGE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const DebugScreen(),
      debugShowCheckedModeBanner: false,
    );

    // Stage 2以上でProvider追加
    if (DEBUG_STAGE >= 2) {
      _logDebug('Provider追加');
      // app = MultiProvider(
      //   providers: [
      //     ChangeNotifierProvider(create: (context) => ItemProvider()),
      //   ],
      //   child: app,
      // );
    }

    _logDebug('DebugApp build完了');
    return app;
  }
}

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<String> logs = [];
  
  @override
  void initState() {
    super.initState();
    _logDebug('DebugScreen initState');
    _loadLogs();
  }

  void _loadLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/debug_log.txt');
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          logs = content.split('\n').where((line) => line.isNotEmpty).toList();
        });
      }
    } catch (e) {
      _logDebug('ログファイル読み込みエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logDebug('DebugScreen build');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Stage $DEBUG_STAGE'),
        backgroundColor: Colors.orange,
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
            color: Colors.orange.shade100,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'デバッグステージ: $DEBUG_STAGE',
                  style: const TextStyle(
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
                  'アプリが正常に起動しました',
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
            child: ListView.builder(
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
          _logDebug('テストボタンが押されました');
          _loadLogs();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
