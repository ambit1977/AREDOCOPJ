import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:item_manager/providers/item_provider.dart';
import 'package:item_manager/services/storage_service.dart';
import 'package:item_manager/models/item.dart';

import 'item_provider_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  // テスト実行前にbindingを初期化
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ItemProvider Tests', () {
    late MockStorageService mockStorageService;
    late ItemProvider itemProvider;

    setUp(() {
      mockStorageService = MockStorageService();
      itemProvider = ItemProvider(mockStorageService);
    });

    test('should load items successfully', () async {
      // Arrange
      final testItems = [
        Item(
          id: '1',
          name: 'テストアイテム1',
          category: 'カテゴリ1',
          location: '場所1',
          imagePath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: '2',
          name: 'テストアイテム2',
          category: 'カテゴリ2',
          location: '場所2',
          imagePath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockStorageService.getAllItems())
          .thenAnswer((_) async => testItems);
      when(mockStorageService.getAllLocations())
          .thenAnswer((_) async => ['場所1', '場所2']);
      when(mockStorageService.getAllCategories())
          .thenAnswer((_) async => ['カテゴリ1', 'カテゴリ2']);

      // Act
      await itemProvider.loadItems();

      // Assert
      expect(itemProvider.items.length, 2);
      expect(itemProvider.items[0].name, 'テストアイテム1');
      expect(itemProvider.items[1].name, 'テストアイテム2');
      expect(itemProvider.isLoading, false);
    });

    test('should add item successfully', () async {
      // Arrange
      when(mockStorageService.insertItem(any))
          .thenAnswer((_) async => {});
      when(mockStorageService.getAllItems())
          .thenAnswer((_) async => []);
      when(mockStorageService.getAllLocations())
          .thenAnswer((_) async => []);
      when(mockStorageService.getAllCategories())
          .thenAnswer((_) async => []);

      // Act
      await itemProvider.addItem(
        name: 'New Item',
        category: 'New Category',
        location: 'New Location',
        imagePath: null,
      );

      // Assert
      verify(mockStorageService.insertItem(any)).called(1);
    });

    test('should delete item successfully', () async {
      // Arrange
      final testItem = Item(
        id: '1',
        name: 'テストアイテム',
        category: 'カテゴリ',
        location: '場所',
        imagePath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockStorageService.getAllItems())
          .thenAnswer((_) async => [testItem]);
      when(mockStorageService.getAllLocations())
          .thenAnswer((_) async => ['場所']);
      when(mockStorageService.getAllCategories())
          .thenAnswer((_) async => ['カテゴリ']);
      when(mockStorageService.deleteItem('1'))
          .thenAnswer((_) async => {});

      await itemProvider.loadItems();

      // Act
      await itemProvider.deleteItem('1');

      // Assert
      verify(mockStorageService.deleteItem('1')).called(1);
    });

    test('should get categories and locations', () async {
      // Arrange
      when(mockStorageService.getAllItems())
          .thenAnswer((_) async => []);
      when(mockStorageService.getAllLocations())
          .thenAnswer((_) async => ['場所A', '場所B']);
      when(mockStorageService.getAllCategories())
          .thenAnswer((_) async => ['カテゴリA', 'カテゴリB']);

      await itemProvider.loadItems();

      // Assert
      expect(itemProvider.locations.length, 2);
      expect(itemProvider.locations.contains('場所A'), true);
      expect(itemProvider.locations.contains('場所B'), true);
      expect(itemProvider.categories.length, 2);
      expect(itemProvider.categories.contains('カテゴリA'), true);
      expect(itemProvider.categories.contains('カテゴリB'), true);
    });

    test('should search items correctly', () async {
      // Arrange
      final testItems = [
        Item(
          id: '1',
          name: 'iPhone',
          category: 'electronics',
          location: 'desk',
          imagePath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: '2',
          name: 'notebook',
          category: 'stationery',
          location: 'shelf',
          imagePath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockStorageService.getAllItems())
          .thenAnswer((_) async => testItems);
      when(mockStorageService.getAllLocations())
          .thenAnswer((_) async => []);
      when(mockStorageService.getAllCategories())
          .thenAnswer((_) async => []);

      await itemProvider.loadItems();

      // Act
      final results = itemProvider.searchItems('phone');

      // Assert
      expect(results.length, 1);
      expect(results[0].name, 'iPhone');
    });

    test('should filter items by location', () async {
      // Arrange
      final testItems = [
        Item(
          id: '1',
          name: 'item1',
          category: 'cat1',
          location: 'desk',
          imagePath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: '2',
          name: 'item2',
          category: 'cat2',
          location: 'shelf',
          imagePath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockStorageService.getAllItems())
          .thenAnswer((_) async => testItems);
      when(mockStorageService.getAllLocations())
          .thenAnswer((_) async => []);
      when(mockStorageService.getAllCategories())
          .thenAnswer((_) async => []);

      await itemProvider.loadItems();

      // Act
      final results = itemProvider.getItemsByLocation('desk');

      // Assert
      expect(results.length, 1);
      expect(results[0].name, 'item1');
    });

    test('should filter items by category', () async {
      // Arrange
      final testItems = [
        Item(
          id: '1',
          name: 'item1',
          category: 'electronics',
          location: 'desk',
          imagePath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: '2',
          name: 'item2',
          category: 'stationery',
          location: 'shelf',
          imagePath: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockStorageService.getAllItems())
          .thenAnswer((_) async => testItems);
      when(mockStorageService.getAllLocations())
          .thenAnswer((_) async => []);
      when(mockStorageService.getAllCategories())
          .thenAnswer((_) async => []);

      await itemProvider.loadItems();

      // Act
      final results = itemProvider.getItemsByCategory('electronics');

      // Assert
      expect(results.length, 1);
      expect(results[0].name, 'item1');
    });
  });
}
