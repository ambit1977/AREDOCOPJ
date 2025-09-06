import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/item_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 実機でのパフォーマンス最適化
  if (Platform.isIOS) {
    // 画像キャッシュサイズを制限（メモリ不足防止）
    PaintingBinding.instance.imageCache.maximumSize = 30;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 30 << 20; // 30MB
    
    // システムUIの設定
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
  
  // 簡素化されたログ
  debugPrint('=== アプリ起動開始 ===');
  
  // 基本的なエラーハンドリングのみ
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter エラー: ${details.exception}');
    FlutterError.presentError(details);
  };
  
  debugPrint('=== アプリ起動準備完了 ===');
  runApp(const OptimizedApp());
}

class OptimizedApp extends StatelessWidget {
  const OptimizedApp({super.key});

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
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LazyHomeScreen(),
        debugShowCheckedModeBanner: false,
        // メモリ使用量削減
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}

class LazyHomeScreen extends StatefulWidget {
  const LazyHomeScreen({super.key});

  @override
  State<LazyHomeScreen> createState() => _LazyHomeScreenState();
}

class _LazyHomeScreenState extends State<LazyHomeScreen> {
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // 遅延初期化（UI表示後に実行）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDataLazily();
    });
  }

  Future<void> _initializeDataLazily() async {
    try {
      // UI描画完了を待つ
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('遅延データ初期化開始');
      
      // データベース初期化
      final dbService = DatabaseService();
      await dbService.database;
      
      // ItemProviderのデータ読み込み
      if (mounted) {
        await context.read<ItemProvider>().loadItems();
      }
      
      debugPrint('遅延データ初期化完了');
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('遅延初期化エラー: $e');
      
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('エラー'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('初期化エラーが発生しました'),
              const SizedBox(height: 8),
              Text(
                _errorMessage.length > 100 
                    ? '${_errorMessage.substring(0, 100)}...' 
                    : _errorMessage,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isInitialized = false;
                  });
                  _initializeDataLazily();
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'データを読み込んでいます...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '実機での起動処理中',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}
