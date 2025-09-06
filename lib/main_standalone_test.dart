import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // システムレベルの設定を最小限に
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  
  runApp(const StandaloneTestApp());
}

class StandaloneTestApp extends StatelessWidget {
  const StandaloneTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'スタンドアロンテスト',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const StandaloneTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StandaloneTestScreen extends StatefulWidget {
  const StandaloneTestScreen({super.key});

  @override
  State<StandaloneTestScreen> createState() => _StandaloneTestScreenState();
}

class _StandaloneTestScreenState extends State<StandaloneTestScreen> {
  int _counter = 0;
  String _status = '実機スタンドアロン起動テスト';

  @override
  void initState() {
    super.initState();
    _checkStandaloneStatus();
  }

  void _checkStandaloneStatus() {
    // 3秒後にスタンドアロン起動成功と判定
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _status = '✅ スタンドアロン起動成功！';
        });
      }
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタンドアロンテスト'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _status.contains('成功') ? Icons.check_circle : Icons.hourglass_empty,
              color: _status.contains('成功') ? Colors.green : Colors.orange,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'タップ回数:',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'このアプリが実機で単体起動できれば、\n基本的な機能は正常に動作しています。',
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
        onPressed: _incrementCounter,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
