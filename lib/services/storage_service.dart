import 'package:flutter/foundation.dart';
import '../models/item.dart';
import 'database_service.dart';

// Conditional imports
import 'web_storage_service.dart' if (dart.library.io) 'web_storage_service_stub.dart';

abstract class StorageService {
  Future<List<Item>> getAllItems();
  Future<void> insertItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
  Future<List<String>> getAllLocations();
  Future<List<String>> getAllCategories();
  Future<List<String>> getFrequentLocations(int limit);
  Future<List<String>> getFrequentCategories(int limit);

  static StorageService getInstance() {
    if (kIsWeb) {
      return WebStorageService();
    } else {
      return DatabaseService();
    }
  }
}
