import 'dart:isolate';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/item_provider.dart';
import 'screens/home_screen.dart';
import 'screens/error_fallback_screen.dart';
import 'utils/crash_reporter.dart';

void main() async {
  // 基本的な初期化のみ
  WidgetsFlutterBinding.ensureInitialized();
  
  // アプリ起動をログに記録
  await CrashReporter.logAppStart();
  
  // エラーハンドリングを設定
  FlutterError.onError = (FlutterErrorDetails details) {
    CrashReporter.logCrash('Flutter UI エラー', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  
  // アプリレベルの例外キャッチ
  PlatformDispatcher.instance.onError = (error, stack) {
    CrashReporter.logCrash('アプリレベル例外', error, stack);
    return true;
  };
  
  debugPrint('=== 実機対応版アプリ起動 ===');
  runApp(const SafeApp());
}

class SafeApp extends StatelessWidget {
  const SafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '持ち物管理アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SafeAppWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SafeAppWrapper extends StatefulWidget {
  const SafeAppWrapper({super.key});

  @override
  State<SafeAppWrapper> createState() => _SafeAppWrapperState();
}

class _SafeAppWrapperState extends State<SafeAppWrapper> {
  bool _hasError = false;
  String _errorMessage = '';
  ItemProvider? _itemProvider;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('SafeApp: 初期化開始');
      
      // 段階的に初期化
      await Future.delayed(const Duration(milliseconds: 100));
      
      // ItemProviderを作成（まだデータは読み込まない）
      _itemProvider = ItemProvider();
      
      debugPrint('SafeApp: 初期化完了');
      
      if (mounted) {
        setState(() {
          // 初期化完了
        });
      }
    } catch (e, stackTrace) {
      debugPrint('SafeApp 初期化エラー: $e');
      await CrashReporter.logCrash('SafeApp 初期化エラー', e, stackTrace);
      
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return ErrorFallbackScreen(
        errorMessage: _errorMessage,
        onRetry: () {
          setState(() {
            _hasError = false;
            _errorMessage = '';
          });
          _initializeApp();
        },
      );
    }

    if (_itemProvider == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'アプリを初期化しています...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _itemProvider!,
      child: const SafeHomeScreen(),
    );
  }
}

class SafeHomeScreen extends StatelessWidget {
  const SafeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('持ち物管理'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              '実機で起動成功！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'データベースと画像機能の読み込みを準備中...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('実機での基本機能は動作しています'),
              backgroundColor: Colors.green,
            ),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
