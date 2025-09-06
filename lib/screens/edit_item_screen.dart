import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../services/camera_service.dart';

class EditItemScreen extends StatefulWidget {
  final Item item;

  const EditItemScreen({
    super.key,
    required this.item,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedCategory;
  late String _selectedLocation;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _selectedCategory = widget.item.category;
    _selectedLocation = widget.item.location;
    _imagePath = widget.item.imagePath;
    
    debugPrint('EditItemScreen: 編集画面初期化完了');
    debugPrint('アイテム名: ${widget.item.name}');
    debugPrint('カテゴリ: $_selectedCategory');
    debugPrint('場所: $_selectedLocation');
    debugPrint('画像パス: $_imagePath');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アイテム編集'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveItem,
            child: const Text(
              '保存',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildCategorySection(),
                    const SizedBox(height: 16),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildDeleteButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '画像',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FutureBuilder<String>(
                    future: CameraService.getImagePath(_imagePath!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.file(
                          File(snapshot.data!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  Text('画像の読み込みに失敗しました'),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '画像が設定されていません',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('カメラで撮影'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('ギャラリーから選択'),
              ),
            ),
          ],
        ),
        if (_imagePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _imagePath = null;
                });
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                '画像を削除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'アイテム名',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'アイテム名を入力してください',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'アイテム名を入力してください';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カテゴリ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<ItemProvider>(
          builder: (context, provider, child) {
            return InkWell(
              onTap: () => _showCategoryDialog(provider),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory.isEmpty ? 'カテゴリを選択' : _selectedCategory,
                      style: TextStyle(
                        color: _selectedCategory.isEmpty ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '場所',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<ItemProvider>(
          builder: (context, provider, child) {
            return InkWell(
              onTap: () => _showLocationDialog(provider),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedLocation.isEmpty ? '場所を選択' : _selectedLocation,
                      style: TextStyle(
                        color: _selectedLocation.isEmpty ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton.icon(
        onPressed: _showDeleteConfirmation,
        icon: const Icon(Icons.delete),
        label: const Text('アイテムを削除'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      debugPrint('EditItemScreen: 画像選択開始 - ソース: ${source.name}');
      final CameraService cameraService = CameraService();
      String? imagePath;
      
      if (source == ImageSource.camera) {
        imagePath = await cameraService.takePicture();
      } else {
        imagePath = await cameraService.pickImageFromGallery();
      }
      
      if (imagePath != null) {
        debugPrint('EditItemScreen: 画像選択成功 - パス: $imagePath');
        setState(() {
          _imagePath = imagePath;
        });
      } else {
        debugPrint('EditItemScreen: 画像選択がキャンセルされました');
      }
    } catch (e, stackTrace) {
      debugPrint('EditItemScreen: 画像選択エラー - $e');
      debugPrint('スタックトレース: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像の選択に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCategoryDialog(ItemProvider provider) async {
    try {
      debugPrint('EditItemScreen: カテゴリ選択ダイアログ表示');
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _CategorySelectionDialog(
          categories: provider.categories,
          frequentCategories: provider.frequentCategories,
          selectedCategory: _selectedCategory,
        ),
      );

      if (result != null) {
        debugPrint('EditItemScreen: カテゴリ選択完了 - $result');
        setState(() {
          _selectedCategory = result;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('EditItemScreen: カテゴリ選択エラー - $e');
      debugPrint('スタックトレース: $stackTrace');
    }
  }

  Future<void> _showLocationDialog(ItemProvider provider) async {
    try {
      debugPrint('EditItemScreen: 場所選択ダイアログ表示');
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _LocationSelectionDialog(
          locations: provider.locations,
          frequentLocations: provider.frequentLocations,
          selectedLocation: _selectedLocation,
        ),
      );

      if (result != null) {
        debugPrint('EditItemScreen: 場所選択完了 - $result');
        setState(() {
          _selectedLocation = result;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('EditItemScreen: 場所選択エラー - $e');
      debugPrint('スタックトレース: $stackTrace');
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('カテゴリを選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('場所を選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('EditItemScreen: アイテム更新開始');
      debugPrint('更新内容:');
      debugPrint('  名前: ${_nameController.text}');
      debugPrint('  カテゴリ: $_selectedCategory');
      debugPrint('  場所: $_selectedLocation');
      debugPrint('  画像: $_imagePath');

      final updatedItem = widget.item.copyWith(
        name: _nameController.text,
        category: _selectedCategory,
        location: _selectedLocation,
        imagePath: _imagePath,
        updatedAt: DateTime.now(),
      );

      final provider = context.read<ItemProvider>();
      await provider.updateItem(updatedItem);

      debugPrint('EditItemScreen: アイテム更新成功');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('アイテムを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      debugPrint('EditItemScreen: アイテム更新エラー - $e');
      debugPrint('スタックトレース: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('アイテムの更新に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
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

  Future<void> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: Text('「${widget.item.name}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteItem();
    }
  }

  Future<void> _deleteItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('EditItemScreen: アイテム削除開始 - ID: ${widget.item.id}');
      
      final provider = context.read<ItemProvider>();
      await provider.deleteItem(widget.item.id);

      debugPrint('EditItemScreen: アイテム削除成功');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('アイテムを削除しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      debugPrint('EditItemScreen: アイテム削除エラー - $e');
      debugPrint('スタックトレース: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('アイテムの削除に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
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
}

// カテゴリ選択ダイアログ
class _CategorySelectionDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> frequentCategories;
  final String selectedCategory;

  const _CategorySelectionDialog({
    required this.categories,
    required this.frequentCategories,
    required this.selectedCategory,
  });

  @override
  State<_CategorySelectionDialog> createState() => _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<_CategorySelectionDialog> {
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('カテゴリを選択'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 新しいカテゴリ追加
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    decoration: const InputDecoration(
                      hintText: '新しいカテゴリ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final newCategory = _newCategoryController.text.trim();
                    if (newCategory.isNotEmpty) {
                      Navigator.of(context).pop(newCategory);
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 頻度の高いカテゴリ
            if (widget.frequentCategories.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'よく使うカテゴリ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...widget.frequentCategories.map((category) => 
                ListTile(
                  title: Text(category),
                  trailing: widget.selectedCategory == category 
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () => Navigator.of(context).pop(category),
                ),
              ),
              const Divider(),
            ],
            
            // 全カテゴリ
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '全てのカテゴリ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.categories.map((category) => 
                  ListTile(
                    title: Text(category),
                    trailing: widget.selectedCategory == category 
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () => Navigator.of(context).pop(category),
                  ),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}

// 場所選択ダイアログ
class _LocationSelectionDialog extends StatefulWidget {
  final List<String> locations;
  final List<String> frequentLocations;
  final String selectedLocation;

  const _LocationSelectionDialog({
    required this.locations,
    required this.frequentLocations,
    required this.selectedLocation,
  });

  @override
  State<_LocationSelectionDialog> createState() => _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends State<_LocationSelectionDialog> {
  final TextEditingController _newLocationController = TextEditingController();

  @override
  void dispose() {
    _newLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('場所を選択'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 新しい場所追加
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newLocationController,
                    decoration: const InputDecoration(
                      hintText: '新しい場所',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final newLocation = _newLocationController.text.trim();
                    if (newLocation.isNotEmpty) {
                      Navigator.of(context).pop(newLocation);
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 頻度の高い場所
            if (widget.frequentLocations.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'よく使う場所',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...widget.frequentLocations.map((location) => 
                ListTile(
                  title: Text(location),
                  trailing: widget.selectedLocation == location 
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () => Navigator.of(context).pop(location),
                ),
              ),
              const Divider(),
            ],
            
            // 全場所
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '全ての場所',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.locations.map((location) => 
                  ListTile(
                    title: Text(location),
                    trailing: widget.selectedLocation == location 
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () => Navigator.of(context).pop(location),
                  ),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
