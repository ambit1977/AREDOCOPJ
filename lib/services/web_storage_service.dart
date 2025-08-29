import 'dart:convert';
import '../models/item.dart';
import 'storage_service.dart';

// Web platform specific import
import 'dart:html' as html;

class WebStorageService extends StorageService {
  static const String _itemsKey = 'items';

  Future<List<Item>> getAllItems() async {
    final itemsJson = html.window.localStorage[_itemsKey];
    if (itemsJson == null) return [];
    
    final List<dynamic> itemsList = json.decode(itemsJson);
    return itemsList.map((json) => Item.fromMap(json)).toList();
  }

  Future<void> saveItems(List<Item> items) async {
    final itemsJson = json.encode(items.map((item) => item.toMap()).toList());
    html.window.localStorage[_itemsKey] = itemsJson;
  }

  Future<void> insertItem(Item item) async {
    final items = await getAllItems();
    items.add(item);
    await saveItems(items);
  }

  Future<void> updateItem(Item updatedItem) async {
    final items = await getAllItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      await saveItems(items);
    }
  }

  Future<void> deleteItem(String id) async {
    final items = await getAllItems();
    items.removeWhere((item) => item.id == id);
    await saveItems(items);
  }

  Future<List<String>> getAllLocations() async {
    final items = await getAllItems();
    return items.map((item) => item.location).toSet().toList()..sort();
  }

  Future<List<String>> getAllCategories() async {
    final items = await getAllItems();
    return items.map((item) => item.category).toSet().toList()..sort();
  }
}
