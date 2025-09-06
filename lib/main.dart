import 'dart:isolate';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'providers/item_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'utils/crash_reporter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // アプリ起動をログに記録
  await CrashReporter.logAppStart();
  
  // 詳細なログ設定
  debugPrint('=== アプリ起動開始 ===');
  debugPrint('プラットフォーム: ${Platform.operatingSystem}');
  debugPrint('Flutterバージョン: ${Platform.version}');
  
  // エラーハンドリングを最初に設定
  FlutterError.onError = (FlutterErrorDetails details) {
    CrashReporter.logCrash('Flutter UI エラー', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  
  // アプリレベルの例外キャッチ
  PlatformDispatcher.instance.onError = (error, stack) {
    CrashReporter.logCrash('アプリレベル例外', error, stack);
    return true;
  };
  
  // Isolateの例外キャッチ
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await CrashReporter.logCrash('Isolate例外', errorAndStacktrace.first, errorAndStacktrace.last);
  }).sendPort);
  
  try {
    debugPrint('データベース初期化開始...');
    final dbService = DatabaseService();
    await dbService.database;
    debugPrint('データベース初期化完了');
  } catch (e, stackTrace) {
    await CrashReporter.logCrash('データベース初期化エラー', e, stackTrace);
  }
  
  debugPrint('=== アプリ起動準備完了 ===');
  runApp(const MyApp());
}

void _logError(String title, dynamic error, dynamic stackTrace) {
  final timestamp = DateTime.now().toIso8601String();
  final logMessage = '''
[$timestamp] $title:
エラー: $error
スタックトレース: $stackTrace
==============================
''';
  
  debugPrint(logMessage);
  
  // 実機ではコンソールに出力されない場合があるため、ファイルにも書き込み
  _writeErrorToFile(logMessage);
}

void _writeErrorToFile(String message) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/crash_log.txt');
    await file.writeAsString(message, mode: FileMode.append);
  } catch (e) {
    // ファイル書き込みエラーは無視
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemProvider()),
      ],
      child: MaterialApp(
        title: '持ち物管理アプリ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
