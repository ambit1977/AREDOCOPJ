import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:item_manager/widgets/item_card.dart';
import 'package:item_manager/providers/item_provider.dart';
import 'package:item_manager/models/item.dart';

// Mock生成のためのアノテーション
@GenerateMocks([ItemProvider])
import 'item_card_test.mocks.dart';

void main() {
  group('ItemCard Widget Tests', () {
    late MockItemProvider mockItemProvider;
    late Item testItem;

    setUp(() {
      mockItemProvider = MockItemProvider();
      testItem = Item(
        id: '1',
        name: 'テストアイテム',
        category: 'テストカテゴリ',
        location: 'テスト場所',
        imagePath: null,
        createdAt: DateTime.parse('2023-01-01 10:00:00'),
        updatedAt: DateTime.parse('2023-01-01 10:00:00'),
      );
    });

    Widget createItemCard() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ItemProvider>.value(
            value: mockItemProvider,
            child: ItemCard(item: testItem),
          ),
        ),
      );
    }

    testWidgets('should display item information correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createItemCard());

      // Assert
      expect(find.text('テストアイテム'), findsOneWidget);
      expect(find.text('テストカテゴリ'), findsOneWidget);
      expect(find.text('テスト場所'), findsOneWidget);
      expect(find.byIcon(Icons.inventory), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.byIcon(Icons.place), findsOneWidget);
    });

    testWidgets('should show popup menu when menu button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createItemCard());

      // Act
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('削除'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should show item details dialog when card is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createItemCard());

      // Act
      await tester.tap(find.byType(ItemCard));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('テストアイテム'), findsAtLeastNWidgets(1)); // タイトルとコンテンツに表示
      expect(find.text('カテゴリ:'), findsOneWidget);
      expect(find.text('収納場所:'), findsOneWidget);
      expect(find.text('登録日:'), findsOneWidget);
      expect(find.text('2023/01/01 10:00'), findsOneWidget);
      expect(find.text('閉じる'), findsOneWidget);
    });

    testWidgets('should show delete confirmation when delete is selected', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createItemCard());

      // Act - ポップアップメニューを開く
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Act - 削除を選択
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('削除確認'), findsOneWidget);
      expect(find.text('「テストアイテム」を削除しますか？'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('削除'), findsOneWidget);
    });

    testWidgets('should call deleteItem when delete is confirmed', (WidgetTester tester) async {
      // Arrange
      when(mockItemProvider.deleteItem('1')).thenAnswer((_) async => {});
      await tester.pumpWidget(createItemCard());

      // Act - ポップアップメニューを開く
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Act - 削除を選択
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // Act - 削除を確認
      await tester.tap(find.text('削除').last); // 確認ダイアログの削除ボタン
      await tester.pumpAndSettle();

      // Assert
      verify(mockItemProvider.deleteItem('1')).called(1);
    });

    testWidgets('should display default icon when no image path', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createItemCard());

      // Assert
      expect(find.byIcon(Icons.inventory), findsAtLeastNWidgets(1));
    });
  });
}
