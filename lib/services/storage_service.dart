import 'package:flutter/foundation.dart';
import '../models/item.dart';
import 'database_service.dart';
import 'web_storage_service.dart';

abstract class StorageService {
  Future<List<Item>> getAllItems();
  Future<void> insertItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
  Future<List<String>> getAllLocations();
  Future<List<String>> getAllCategories();

  static StorageService getInstance() {
    if (kIsWeb) {
      return WebStorageService();
    } else {
      return DatabaseService();
    }
  }
}
