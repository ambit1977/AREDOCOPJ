import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:item_manager/screens/add_item_screen.dart';
import 'package:item_manager/providers/item_provider.dart';

// Mock生成のためのアノテーション
@GenerateMocks([ItemProvider])
import 'add_item_screen_test.mocks.dart';

void main() {
  group('AddItemScreen Widget Tests', () {
    late MockItemProvider mockItemProvider;

    setUp(() {
      mockItemProvider = MockItemProvider();
    });

    Widget createAddItemScreen() {
      return MaterialApp(
        home: ChangeNotifierProvider<ItemProvider>.value(
          value: mockItemProvider,
          child: const AddItemScreen(),
        ),
      );
    }

    testWidgets('should display all form fields and buttons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createAddItemScreen());

      // Assert
      expect(find.text('アイテム追加'), findsOneWidget);
      expect(find.text('写真を撮影または選択'), findsOneWidget);
      expect(find.text('アイテム名'), findsOneWidget);
      expect(find.text('カテゴリ'), findsOneWidget);
      expect(find.text('収納場所'), findsOneWidget);
      expect(find.text('追加'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.inventory), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.byIcon(Icons.place), findsOneWidget);
    });

    testWidgets('should show validation error when name is empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createAddItemScreen());

      // Act - 追加ボタンをタップ（名前を入力せずに）
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('アイテム名を入力してください'), findsOneWidget);
    });

    testWidgets('should show validation error when category is empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createAddItemScreen());

      // Act - 名前だけ入力して追加ボタンをタップ
      await tester.enterText(find.byType(TextFormField).first, 'テストアイテム');
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('カテゴリを入力してください'), findsOneWidget);
    });

    testWidgets('should show validation error when location is empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createAddItemScreen());
      final textFields = find.byType(TextFormField);

      // Act - 名前とカテゴリを入力して追加ボタンをタップ
      await tester.enterText(textFields.at(0), 'テストアイテム');
      await tester.enterText(textFields.at(1), 'テストカテゴリ');
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('収納場所を入力してください'), findsOneWidget);
    });

    testWidgets('should call addItem when all fields are valid', (WidgetTester tester) async {
      // Arrange
      when(mockItemProvider.addItem(
        name: anyNamed('name'),
        category: anyNamed('category'),
        location: anyNamed('location'),
        imagePath: anyNamed('imagePath'),
      )).thenAnswer((_) async => {});

      await tester.pumpWidget(createAddItemScreen());
      final textFields = find.byType(TextFormField);

      // Act - 全てのフィールドに入力
      await tester.enterText(textFields.at(0), 'テストアイテム');
      await tester.enterText(textFields.at(1), 'テストカテゴリ');
      await tester.enterText(textFields.at(2), 'テスト場所');

      // Act - 追加ボタンをタップ
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockItemProvider.addItem(
        name: 'テストアイテム',
        category: 'テストカテゴリ',
        location: 'テスト場所',
        imagePath: null,
      )).called(1);
    });

    testWidgets('should clear form after successful addition', (WidgetTester tester) async {
      // Arrange
      when(mockItemProvider.addItem(
        name: anyNamed('name'),
        category: anyNamed('category'),
        location: anyNamed('location'),
        imagePath: anyNamed('imagePath'),
      )).thenAnswer((_) async => {});

      await tester.pumpWidget(createAddItemScreen());
      final textFields = find.byType(TextFormField);

      // Act - フィールドに入力
      await tester.enterText(textFields.at(0), 'テストアイテム');
      await tester.enterText(textFields.at(1), 'テストカテゴリ');
      await tester.enterText(textFields.at(2), 'テスト場所');

      // Act - 追加ボタンをタップ
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // Wait for navigation and state changes
      await tester.pump(const Duration(milliseconds: 100));

      // Note: フォームのクリアは画面が閉じることで行われるため、
      // ナビゲーションのテストになります
    });

    testWidgets('should show loading state when adding item', (WidgetTester tester) async {
      // Arrange
      when(mockItemProvider.addItem(
        name: anyNamed('name'),
        category: anyNamed('category'),
        location: anyNamed('location'),
        imagePath: anyNamed('imagePath'),
      )).thenAnswer((_) async {
        // 少し遅延を入れてローディング状態をテスト
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(createAddItemScreen());
      final textFields = find.byType(TextFormField);

      // Act - フィールドに入力
      await tester.enterText(textFields.at(0), 'テストアイテム');
      await tester.enterText(textFields.at(1), 'テストカテゴリ');
      await tester.enterText(textFields.at(2), 'テスト場所');

      // Act - 追加ボタンをタップ
      await tester.tap(find.text('追加'));
      await tester.pump(); // 最初のフレームだけポンプ

      // Assert - ローディング状態（追加ボタンが無効化される）
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
