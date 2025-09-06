import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CrashReporter {
  static const String _logFileName = 'app_crash_log.txt';
  static const int _maxLogSize = 1024 * 1024; // 1MB
  
  /// クラッシュレポートをファイルに記録
  static Future<void> logCrash(String title, dynamic error, dynamic stackTrace) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final deviceInfo = await _getDeviceInfo();
      
      final logEntry = '''
========================================
[$timestamp] $title
デバイス情報: $deviceInfo
エラー: $error
スタックトレース: $stackTrace
========================================

''';
      
      debugPrint(logEntry);
      await _writeToFile(logEntry);
    } catch (e) {
      debugPrint('クラッシュレポート記録エラー: $e');
    }
  }
  
  /// アプリ起動時の情報を記録
  static Future<void> logAppStart() async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final deviceInfo = await _getDeviceInfo();
      
      final logEntry = '''
========================================
[$timestamp] アプリ起動
デバイス情報: $deviceInfo
========================================

''';
      
      debugPrint(logEntry);
      await _writeToFile(logEntry);
    } catch (e) {
      debugPrint('アプリ起動ログ記録エラー: $e');
    }
  }
  
  /// デバイス情報を取得
  static Future<String> _getDeviceInfo() async {
    final platform = Platform.operatingSystem;
    final version = Platform.operatingSystemVersion;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final availableSpace = await _getAvailableSpace(directory.path);
      
      return 'プラットフォーム: $platform, バージョン: $version, 利用可能容量: ${availableSpace}MB';
    } catch (e) {
      return 'プラットフォーム: $platform, バージョン: $version';
    }
  }
  
  /// 利用可能なストレージ容量を取得（概算）
  static Future<int> _getAvailableSpace(String path) async {
    try {
      final result = await Process.run('df', ['-k', path]);
      final lines = result.stdout.toString().split('\n');
      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length > 3) {
          final available = int.tryParse(parts[3]);
          return available != null ? (available / 1024).round() : 0;
        }
      }
    } catch (e) {
      // エラーの場合は0を返す
    }
    return 0;
  }
  
  /// ログファイルに書き込み
  static Future<void> _writeToFile(String logEntry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      
      // ファイルサイズをチェックして大きすぎる場合は初期化
      if (await file.exists()) {
        final size = await file.length();
        if (size > _maxLogSize) {
          await file.writeAsString('=== ログファイル初期化 ===\n');
        }
      }
      
      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      debugPrint('ログファイル書き込みエラー: $e');
    }
  }
  
  /// ログファイルの内容を取得
  static Future<String> getLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      debugPrint('ログファイル読み込みエラー: $e');
    }
    return 'ログファイルが見つかりません';
  }
  
  /// ログファイルをクリア
  static Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('ログファイル削除エラー: $e');
    }
  }
}
