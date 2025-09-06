import 'package:flutter_test/flutter_test.dart';
import 'package:item_manager/models/item.dart';

void main() {
  group('Item Model Tests', () {
    test('should create an item with all properties', () {
      // Arrange
      final now = DateTime.now();
      
      // Act
      final item = Item(
        id: '1',
        name: 'テストアイテム',
        category: 'テストカテゴリ',
        location: 'テスト場所',
        imagePath: '/path/to/image.jpg',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(item.id, '1');
      expect(item.name, 'テストアイテム');
      expect(item.category, 'テストカテゴリ');
      expect(item.location, 'テスト場所');
      expect(item.imagePath, '/path/to/image.jpg');
      expect(item.createdAt, now);
      expect(item.updatedAt, now);
    });

    test('should create an item without image path', () {
      // Arrange & Act
      final item = Item(
        id: '2',
        name: 'テストアイテム2',
        category: 'テストカテゴリ2',
        location: 'テスト場所2',
        imagePath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(item.imagePath, isNull);
    });

    test('should convert item to map correctly', () {
      // Arrange
      final now = DateTime.parse('2023-01-01 10:00:00');
      final item = Item(
        id: '1',
        name: 'テストアイテム',
        category: 'テストカテゴリ',
        location: 'テスト場所',
        imagePath: '/path/to/image.jpg',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final map = item.toMap();

      // Assert
      expect(map['id'], '1');
      expect(map['name'], 'テストアイテム');
      expect(map['category'], 'テストカテゴリ');
      expect(map['location'], 'テスト場所');
      expect(map['imagePath'], '/path/to/image.jpg');
      expect(map['createdAt'], now.millisecondsSinceEpoch);
      expect(map['updatedAt'], now.millisecondsSinceEpoch);
    });

    test('should create item from map correctly', () {
      // Arrange
      final now = DateTime.parse('2023-01-01 10:00:00');
      final map = {
        'id': '1',
        'name': 'テストアイテム',
        'category': 'テストカテゴリ',
        'location': 'テスト場所',
        'imagePath': '/path/to/image.jpg',
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      };

      // Act
      final item = Item.fromMap(map);

      // Assert
      expect(item.id, '1');
      expect(item.name, 'テストアイテム');
      expect(item.category, 'テストカテゴリ');
      expect(item.location, 'テスト場所');
      expect(item.imagePath, '/path/to/image.jpg');
      expect(item.createdAt, now);
      expect(item.updatedAt, now);
    });

    test('should handle null imagePath in map conversion', () {
      // Arrange
      final now = DateTime.parse('2023-01-01 10:00:00');
      final map = {
        'id': '1',
        'name': 'テストアイテム',
        'category': 'テストカテゴリ',
        'location': 'テスト場所',
        'imagePath': null,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      };

      // Act
      final item = Item.fromMap(map);

      // Assert
      expect(item.imagePath, isNull);
    });
  });
}
