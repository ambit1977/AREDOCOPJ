import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../services/camera_service.dart';
import '../screens/edit_item_screen.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  Widget _buildImage({required double width, required double height, BoxFit fit = BoxFit.cover}) {
    if (item.imagePath == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(
          Icons.inventory,
          color: Colors.grey,
        ),
      );
    }

    // 画像読み込みエラー時の表示
    Widget errorContainer = Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );

    try {
      // Web版ではBase64形式、モバイル版ではファイルパス
      if (kIsWeb && item.imagePath!.startsWith('data:image')) {
        // Base64画像の場合
        try {
          final String base64String = item.imagePath!.split(',')[1];
          final Uint8List bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            // メモリキャッシュを使用してパフォーマンス向上
            cacheWidth: width.isFinite && width > 0 ? (width * 2).toInt() : null,
            gaplessPlayback: true, // 画像読み込み中に前の画像を表示し続ける
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Base64画像読み込みエラー: $error');
              return errorContainer;
            },
          );
        } catch (e) {
          debugPrint('Base64デコードエラー: $e');
          return errorContainer;
        }
      } else {
        // ファイルパスの場合（モバイル版）
        // 動的にパスを解決するFutureBuilderを使用
        return FutureBuilder<String>(
          future: CameraService.getImagePath(item.imagePath!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            
            if (snapshot.hasError) {
              debugPrint('画像パス解決エラー: ${snapshot.error}');
              return errorContainer;
            }
            
            if (!snapshot.hasData) {
              debugPrint('画像パスデータなし');
              return errorContainer;
            }
            
            final String fullPath = snapshot.data!;
            final file = File(fullPath);
            
            return Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              // メモリキャッシュを使用してパフォーマンス向上
              cacheWidth: width.isFinite && width > 0 ? (width * 2).toInt() : null,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('画像ファイル読み込みエラー: $error, パス: $fullPath');
                return errorContainer;
              },
            );
          },
        );
      }
    } catch (e) {
      debugPrint('画像表示処理エラー: $e');
      return errorContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showItemDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: _buildImage(width: 60, height: 60),
                ),
              ),
              const SizedBox(width: 12),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuSelection(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('削除'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(
                    width: 300, // 固定幅に変更
                    height: 200,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailRow('カテゴリ', item.category),
              const SizedBox(height: 8),
              _buildDetailRow('収納場所', item.location),
              const SizedBox(height: 8),
              _buildDetailRow(
                '登録日',
                DateFormat('yyyy/MM/dd HH:mm').format(item.createdAt),
              ),
              if (item.updatedAt != item.createdAt) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  '更新日',
                  DateFormat('yyyy/MM/dd HH:mm').format(item.updatedAt),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () => _navigateToEditScreen(context),
            child: const Text(
              '編集',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${item.name}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ItemProvider>().deleteItem(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('アイテムを削除しました')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) async {
    try {
      // 詳細ダイアログを閉じる
      Navigator.pop(context);
      
      // 編集画面に遷移
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => EditItemScreen(item: item),
        ),
      );
      
      // 編集が完了した場合、リストを更新
      if (result == true && context.mounted) {
        context.read<ItemProvider>().loadItems();
      }
    } catch (e, stackTrace) {
      debugPrint('編集画面への遷移エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('編集画面を開けませんでした: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
