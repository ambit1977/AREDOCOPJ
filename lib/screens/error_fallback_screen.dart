import 'package:flutter/material.dart';
import '../utils/crash_reporter.dart';

class ErrorFallbackScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  
  const ErrorFallbackScreen({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エラーが発生しました'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'アプリの実行中にエラーが発生しました',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showDetailedLog(context),
              icon: const Icon(Icons.bug_report),
              label: const Text('詳細ログを表示'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _clearLogs(context),
              icon: const Icon(Icons.delete),
              label: const Text('ログをクリア'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDetailedLog(BuildContext context) async {
    final logs = await CrashReporter.getLogs();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('詳細ログ'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Text(
                logs,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    }
  }
  
  void _clearLogs(BuildContext context) async {
    try {
      await CrashReporter.clearLogs();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ログをクリアしました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログのクリアに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
