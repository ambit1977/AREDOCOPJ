import 'dart:isolate';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/item_provider.dart';
import 'screens/home_screen.dart';
import 'screens/error_fallback_screen.dart';
import 'utils/crash_reporter.dart';

void main() async {
  // プラットフォーム固有の初期化を最初に実行
  WidgetsFlutterBinding.ensureInitialized();
  
  // 実機でのメモリ不足を防ぐため、画像キャッシュサイズを制限
  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  
  debugPrint('=== 実機対応版アプリ起動 ===');
  debugPrint('プラットフォーム: ${Platform.operatingSystem}');
  debugPrint('実行環境: ${kDebugMode ? "Debug" : "Release"}');
  
  // アプリ起動をログに記録
  try {
    await CrashReporter.logAppStart();
  } catch (e) {
    debugPrint('クラッシュレポート初期化エラー（続行）: $e');
  }
  
  // 全てのエラーをキャッチするハンドラー
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter UI エラー: ${details.exception}');
    try {
      CrashReporter.logCrash('Flutter UI エラー', details.exception, details.stack);
    } catch (e) {
      debugPrint('クラッシュレポート記録エラー: $e');
    }
    FlutterError.presentError(details);
  };
  
  // アプリレベルの例外キャッチ
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('アプリレベル例外: $error');
    try {
      CrashReporter.logCrash('アプリレベル例外', error, stack);
    } catch (e) {
      debugPrint('クラッシュレポート記録エラー: $e');
    }
    return true;
  };
  
  // Isolateの例外キャッチ
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    debugPrint('Isolate例外: ${errorAndStacktrace.first}');
    try {
      await CrashReporter.logCrash('Isolate例外', errorAndStacktrace.first, errorAndStacktrace.last);
    } catch (e) {
      debugPrint('クラッシュレポート記録エラー: $e');
    }
  }).sendPort);
  
  // システムレベルのUIのオーバーレイスタイル設定
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  // 画面の向きを制限（実機でのパフォーマンス向上）
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  debugPrint('=== アプリ起動準備完了 ===');
  
  // アプリを起動
  runApp(const StandaloneApp());
}

class StandaloneApp extends StatelessWidget {
  const StandaloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '持ち物管理アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // 実機でのパフォーマンス向上のためアニメーション時間を短縮
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const StandaloneAppWrapper(),
      debugShowCheckedModeBanner: false,
      // 実機でのメモリ使用量削減
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // テキストスケールを固定
          ),
          child: child!,
        );
      },
    );
  }
}

class StandaloneAppWrapper extends StatefulWidget {
  const StandaloneAppWrapper({super.key});

  @override
  State<StandaloneAppWrapper> createState() => _StandaloneAppWrapperState();
}

class _StandaloneAppWrapperState extends State<StandaloneAppWrapper> 
    with WidgetsBindingObserver {
  bool _hasError = false;
  String _errorMessage = '';
  bool _isInitialized = false;
  ItemProvider? _itemProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('アプリライフサイクル変更: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('アプリ復帰');
        break;
      case AppLifecycleState.paused:
        debugPrint('アプリ一時停止');
        break;
      case AppLifecycleState.detached:
        debugPrint('アプリ終了');
        break;
      case AppLifecycleState.inactive:
        debugPrint('アプリ非アクティブ');
        break;
      case AppLifecycleState.hidden:
        debugPrint('アプリ隠し');
        break;
    }
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('StandaloneApp: 初期化開始');
      
      // 段階的な初期化でクラッシュを防ぐ
      await Future.delayed(const Duration(milliseconds: 200));
      
      // メモリチェック
      if (Platform.isIOS) {
        debugPrint('iOS実機での初期化');
      }
      
      // ItemProviderを慎重に作成
      debugPrint('ItemProvider作成開始');
      _itemProvider = ItemProvider();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      debugPrint('StandaloneApp: 初期化完了');
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('StandaloneApp 初期化エラー: $e');
      try {
        await CrashReporter.logCrash('StandaloneApp 初期化エラー', e, stackTrace);
      } catch (logError) {
        debugPrint('ログ記録エラー: $logError');
      }
      
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'アプリの初期化に失敗しました: ${e.toString()}';
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
            _isInitialized = false;
          });
          _initializeApp();
        },
      );
    }

    if (!_isInitialized || _itemProvider == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(
                'アプリを初期化しています...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '実機での起動準備中',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 成功時にはシンプルな確認画面を表示
    return Scaffold(
      appBar: AppBar(
        title: const Text('持ち物管理'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '実機でのスタンドアロン起動成功！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'アプリが正常に起動しました。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('メインアプリに進む'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
