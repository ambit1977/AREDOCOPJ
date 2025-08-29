import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../services/database_service.dart';

class ItemProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  List<Item> _items = [];
  List<String> _locations = [];
  List<String> _categories = [];
  bool _isLoading = false;

  List<Item> get items => _items;
  List<String> get locations => _locations;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _databaseService.getAllItems();
      _locations = await _databaseService.getAllLocations();
      _categories = await _databaseService.getAllCategories();
    } catch (e) {
      debugPrint('Error loading items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
      await _databaseService.insertItem(item);
      await loadItems(); // Reload all data
    } catch (e) {
      debugPrint('Error adding item: $e');
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _databaseService.updateItem(item);
      await loadItems(); // Reload all data
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _databaseService.deleteItem(id);
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
