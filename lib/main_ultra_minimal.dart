import 'package:flutter/material.dart';

void main() {
  runApp(const UltraMinimalApp());
}

class UltraMinimalApp extends StatelessWidget {
  const UltraMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultra Minimal',
      home: Scaffold(
        body: Container(
          color: Colors.green,
          child: const Center(
            child: Text(
              'iOS実機テスト成功',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
