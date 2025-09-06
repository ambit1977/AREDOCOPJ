import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../models/item.dart';
import '../services/storage_service.dart';

class ItemProvider with ChangeNotifier {
  late final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  List<Item> _items = [];
  List<String> _locations = [];
  List<String> _categories = [];
  List<String> _frequentLocations = [];
  List<String> _frequentCategories = [];
  bool _isLoading = false;

  List<Item> get items => _items;
  List<String> get locations => _locations;
  List<String> get categories => _categories;
  List<String> get frequentLocations => _frequentLocations;
  List<String> get frequentCategories => _frequentCategories;
  bool get isLoading => _isLoading;

  // デフォルトコンストラクタ
  ItemProvider([StorageService? storageService]) {
    _storageService = storageService ?? StorageService.getInstance();
    // 初期化時にすぐにデータを読み込み
    _initializeData();
  }
  
  // 初期化メソッド - エラーハンドリングを強化
  Future<void> _initializeData() async {
    try {
      await loadItems();
    } catch (e) {
      debugPrint('初期データ読み込みエラー: $e');
      // エラーがあっても続行できるように空のリストで初期化
      _items = [];
      _locations = [];
      _categories = [];
      _frequentLocations = [];
      _frequentCategories = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadItems() async {
    debugPrint('ItemProvider: loadItems開始');
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('ItemProvider: アイテム読み込み開始');
      _items = await _storageService.getAllItems();
      debugPrint('ItemProvider: アイテム数: ${_items.length}');
      
      // 画像パスを修正（ファイル名のみに変換）
      bool hasUpdates = false;
      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        if (item.imagePath != null && item.imagePath!.contains('/')) {
          // フルパスの場合、ファイル名のみに変換
          final fileName = path.basename(item.imagePath!);
          final updatedItem = Item(
            id: item.id,
            name: item.name,
            category: item.category,
            location: item.location,
            imagePath: fileName,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          );
          _items[i] = updatedItem;
          
          // データベースを更新
          await _storageService.updateItem(updatedItem);
          hasUpdates = true;
          debugPrint('画像パス修正: ${item.imagePath} -> $fileName');
        }
      }
      
      debugPrint('ItemProvider: 場所とカテゴリの読み込み開始');
      _locations = await _storageService.getAllLocations();
      debugPrint('ItemProvider: 場所数: ${_locations.length}');
      _categories = await _storageService.getAllCategories();
      debugPrint('ItemProvider: カテゴリ数: ${_categories.length}');
      
      // 頻度の高い場所とカテゴリを取得（上位5件）
      debugPrint('ItemProvider: 頻度の高い場所とカテゴリの取得開始');
      _frequentLocations = await _storageService.getFrequentLocations(5);
      _frequentCategories = await _storageService.getFrequentCategories(5);
      debugPrint('ItemProvider: 頻度の高い場所数: ${_frequentLocations.length}');
      debugPrint('ItemProvider: 頻度の高いカテゴリ数: ${_frequentCategories.length}');
      
      if (hasUpdates) {
        debugPrint('画像パスの一括修正が完了しました');
      }
      debugPrint('ItemProvider: loadItems完了');
    } catch (e, stackTrace) {
      debugPrint('ItemProvider loadItems エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('ItemProvider: loadItems finally ブロック完了');
    }
  }

  Future<void> addItem({
    required String name,
    required String category,
    required String location,
    String? imagePath,
  }) async {
    final now = DateTime.now();
    final item = Item(
      id: _uuid.v4(),
      name: name,
      category: category,
      location: location,
      imagePath: imagePath,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _storageService.insertItem(item);
      await loadItems(); // Reload all data
    } catch (e) {
      debugPrint('Error adding item: $e');
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _storageService.updateItem(item);
      await loadItems(); // Reload all data
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _storageService.deleteItem(id);
      await loadItems(); // Reload all data
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  List<Item> getItemsByLocation(String location) {
    return _items.where((item) => item.location == location).toList();
  }

  List<Item> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  List<Item> searchItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
          item.category.toLowerCase().contains(lowercaseQuery) ||
          item.location.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
