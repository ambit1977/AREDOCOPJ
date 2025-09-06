import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../services/camera_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final CameraService _cameraService = CameraService();

  String? _selectedImagePath;
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  bool _isLoadingLocations = false;

  @override
  void initState() {
    super.initState();
    // フォーカスリスナーは削除 - onTapのみを使用する
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    // フォーカスノードは削除
    super.dispose();
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<ItemProvider>().addItem(
            name: _nameController.text.trim(),
            category: _categoryController.text.trim(),
            location: _locationController.text.trim(),
            imagePath: _selectedImagePath,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アイテムを追加しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectImage() {
    _cameraService.showImageSourceDialog(
      context,
      (imagePath) {
        if (imagePath != null) {
          setState(() {
            _selectedImagePath = imagePath;
          });
        }
      },
    );
  }
  
  // カテゴリ選択ダイアログを表示
  void _showCategorySelectionDialog() async {
    print('カテゴリ選択ダイアログを開く');
    
    // 現在のダイアログが表示されている場合は何もしない
    if (_isLoadingCategories) return;
    
    // フォーカスを外してキーボードを閉じる
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoadingCategories = true;
    });
    
    try {
      final itemProvider = context.read<ItemProvider>();
      final TextEditingController newCategoryController = TextEditingController();
      
      print('カテゴリ数: ${itemProvider.categories.length}');
      
      // ダイアログを表示
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: true, // 背景タップでダイアログを閉じることができる
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('カテゴリを選択'),
          content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 新規カテゴリ入力
                    const Text('新しいカテゴリを追加', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: newCategoryController,
                      decoration: InputDecoration(
                        hintText: 'カテゴリ名を入力',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            final text = newCategoryController.text.trim();
                            print('新しいカテゴリ追加ボタン: $text');
                            if (text.isNotEmpty) {
                              Navigator.of(dialogContext).pop(text);
                            }
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        final text = value.trim();
                        print('新しいカテゴリ送信: $text');
                        if (text.isNotEmpty) {
                          Navigator.of(dialogContext).pop(text);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    if (itemProvider.frequentCategories.isNotEmpty) ...[
                      const Text('よく使うカテゴリ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: itemProvider.frequentCategories.map((category) {
                          return ActionChip(
                            label: Text(category),
                            onPressed: () {
                              print('よく使うカテゴリ選択: $category');
                              Navigator.of(dialogContext).pop(category);
                            },
                          );
                        }).toList(),
                      ),
                      const Divider(height: 24),
                    ],
                    
                    if (itemProvider.categories.isNotEmpty) ...[
                      const Text('すべてのカテゴリ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: itemProvider.categories.map((category) {
                          return ActionChip(
                            label: Text(category),
                            onPressed: () {
                              print('カテゴリ選択: $category');
                              Navigator.of(dialogContext).pop(category);
                            },
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      const Text('まだカテゴリがありません。上記で新しいカテゴリを作成してください。'),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('カテゴリダイアログ: キャンセルボタンが押された');
                  Navigator.of(dialogContext).pop(null);
                },
                child: const Text('キャンセル'),
              ),
            ],
          ),
      );
      
      print('カテゴリ選択結果: $result');
      
      // 選択されたカテゴリをテキストフィールドに設定
      if (result != null && result.isNotEmpty) {
        setState(() {
          _categoryController.text = result;
        });
        print('カテゴリが設定されました: $result');
      }
    } catch (e) {
      print('カテゴリ選択ダイアログエラー: $e');
    } finally {
      // ダイアログが閉じた後にローディング状態をリセット
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }
  
  // 場所選択ダイアログを表示
  void _showLocationSelectionDialog() async {
    print('場所選択ダイアログを開く');
    
    // 現在のダイアログが表示されている場合は何もしない
    if (_isLoadingLocations) return;
    
    // フォーカスを外してキーボードを閉じる
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoadingLocations = true;
    });
    
    try {
      final itemProvider = context.read<ItemProvider>();
      final TextEditingController newLocationController = TextEditingController();
      
      print('場所数: ${itemProvider.locations.length}');
      
      // ダイアログを表示
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: true, // 背景タップでダイアログを閉じることができる
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('収納場所を選択'),
          content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 新規場所入力
                    const Text('新しい収納場所を追加', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: newLocationController,
                      decoration: InputDecoration(
                        hintText: '収納場所名を入力',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            final text = newLocationController.text.trim();
                            print('新しい場所追加ボタン: $text');
                            if (text.isNotEmpty) {
                              Navigator.of(dialogContext).pop(text);
                            }
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        final text = value.trim();
                        print('新しい場所送信: $text');
                        if (text.isNotEmpty) {
                          Navigator.of(dialogContext).pop(text);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    if (itemProvider.frequentLocations.isNotEmpty) ...[
                      const Text('よく使う場所', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: itemProvider.frequentLocations.map((location) {
                          return ActionChip(
                            label: Text(location),
                            onPressed: () {
                              print('よく使う場所選択: $location');
                              Navigator.of(dialogContext).pop(location);
                            },
                          );
                        }).toList(),
                      ),
                      const Divider(height: 24),
                    ],
                    
                    if (itemProvider.locations.isNotEmpty) ...[
                      const Text('すべての場所', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: itemProvider.locations.map((location) {
                          return ActionChip(
                            label: Text(location),
                            onPressed: () {
                              print('場所選択: $location');
                              Navigator.of(dialogContext).pop(location);
                            },
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      const Text('まだ収納場所がありません。上記で新しい場所を作成してください。'),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('場所ダイアログ: キャンセルボタンが押された');
                  Navigator.of(dialogContext).pop(null);
                },
                child: const Text('キャンセル'),
              ),
            ],
          ),
      );
      
      print('場所選択結果: $result');
      
      // 選択された場所をテキストフィールドに設定
      if (result != null && result.isNotEmpty) {
        setState(() {
          _locationController.text = result;
        });
        print('場所が設定されました: $result');
      }
    } catch (e) {
      print('場所選択ダイアログエラー: $e');
    } finally {
      // ダイアログが閉じた後にローディング状態をリセット
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImagePath == null) return Container();

    // Web版ではBase64形式、モバイル版ではファイルパス
    if (kIsWeb && _selectedImagePath!.startsWith('data:image')) {
      // Base64画像の場合
      try {
        final String base64String = _selectedImagePath!.split(',')[1];
        final Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 50,
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 50,
          ),
        );
      }
    } else {
      // ファイルパスの場合（モバイル版）
      // AddItemScreenでは選択直後なので、_selectedImagePathはファイル名または完全パス
      File file;
      if (_selectedImagePath!.contains('/')) {
        // 完全パスの場合
        file = File(_selectedImagePath!);
      } else {
        // ファイル名のみの場合（修正後）
        return FutureBuilder<String>(
          future: CameraService.getImagePath(_selectedImagePath!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              debugPrint('画像パス解決エラー: ${snapshot.error}');
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 50,
                ),
              );
            }
            
            if (!snapshot.hasData) {
              debugPrint('画像パスデータなし');
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 50,
                ),
              );
            }
            
            return Image.file(
              File(snapshot.data!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('画像ファイル読み込みエラー: $error');
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 50,
                  ),
                );
              },
            );
          },
        );
      }
      
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 50,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アイテム追加'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image selection section
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _buildImagePreview(),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '写真を撮影または選択',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'アイテム名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'アイテム名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category field
              TextFormField(
                controller: _categoryController,
                readOnly: true, // タイピングを無効化
                decoration: InputDecoration(
                  labelText: 'カテゴリ',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                  hintText: '例: 衣類、電子機器、書類など',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoadingCategories)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: _showCategorySelectionDialog,
                        ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'カテゴリを入力してください';
                  }
                  return null;
                },
                onTap: _showCategorySelectionDialog,
              ),
              const SizedBox(height: 16),

              // Location field
              TextFormField(
                controller: _locationController,
                readOnly: true, // タイピングを無効化
                decoration: InputDecoration(
                  labelText: '収納場所',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.place),
                  hintText: '例: クローゼット、引き出し、棚など',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoadingLocations)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: _showLocationSelectionDialog,
                        ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '収納場所を入力してください';
                  }
                  return null;
                },
                onTap: _showLocationSelectionDialog,
              ),
              const SizedBox(height: 32),

              // Add button
              ElevatedButton(
                onPressed: _isLoading ? null : _addItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '追加',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
