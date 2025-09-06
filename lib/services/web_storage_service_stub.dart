import '../models/item.dart';
import 'storage_service.dart';

class WebStorageService extends StorageService {
  @override
  Future<List<Item>> getAllItems() async {
    // This should never be called on non-web platforms
    throw UnsupportedError('WebStorageService is not supported on this platform');
  }

  @override
  Future<void> insertItem(Item item) async {
    throw UnsupportedError('WebStorageService is not supported on this platform');
  }

  @override
  Future<void> updateItem(Item item) async {
    throw UnsupportedError('WebStorageService is not supported on this platform');
  }

  @override
  Future<void> deleteItem(String id) async {
    throw UnsupportedError('WebStorageService is not supported on this platform');
  }

  @override
  Future<List<String>> getAllLocations() async {
    throw UnsupportedError('WebStorageService is not supported on this platform');
  }

  @override
  Future<List<String>> getAllCategories() async {
    throw UnsupportedError('WebStorageService is not supported on this platform');
  }
  
  @override
  Future<List<String>> getFrequentLocations(int limit) async {
    throw UnsupportedError('WebStorageService is not supported on this platform');
  }
  
  @override
  Future<List<String>> getFrequentCategories(int limit) async {
    throw UnsupportedError('WebStorageService is not supported on this platform');
  }
}
