import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:item_manager/screens/add_item_screen.dart';
import 'package:item_manager/providers/item_provider.dart';
import 'package:item_manager/services/database_service.dart';

void main() {
  group('ダイアログテスト', () {
    late ItemProvider itemProvider;
    late DatabaseService databaseService;

    setUp(() async {
      // テスト用のデータベースサービスとプロバイダーを初期化
      databaseService = DatabaseService();
      itemProvider = ItemProvider(databaseService);
      
      // テスト用のデータを追加
      await itemProvider.loadItems();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<ItemProvider>.value(
          value: itemProvider,
          child: AddItemScreen(),
        ),
      );
    }

    testWidgets('カテゴリダイアログが開く', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // カテゴリ選択ボタンを探す
      final categoryButton = find.byIcon(Icons.category_outlined);
      expect(categoryButton, findsOneWidget);

      // ボタンをタップ
      await tester.tap(categoryButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認
      expect(find.text('カテゴリを選択'), findsOneWidget);
      expect(find.text('新しいカテゴリを追加'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
    });

    testWidgets('カテゴリダイアログ - キャンセルボタンで閉じる', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // カテゴリ選択ボタンをタップしてダイアログを開く
      final categoryButton = find.byIcon(Icons.category_outlined);
      await tester.tap(categoryButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認
      expect(find.text('カテゴリを選択'), findsOneWidget);

      // キャンセルボタンをタップ
      final cancelButton = find.text('キャンセル');
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // ダイアログが閉じることを確認
      expect(find.text('カテゴリを選択'), findsNothing);
    });

    testWidgets('カテゴリダイアログ - 新規カテゴリ入力', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // カテゴリ選択ボタンをタップしてダイアログを開く
      final categoryButton = find.byIcon(Icons.category_outlined);
      await tester.tap(categoryButton);
      await tester.pumpAndSettle();

      // 新規カテゴリ入力フィールドに文字を入力
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, 'テストカテゴリ');
      await tester.pumpAndSettle();

      // 追加ボタンをタップ
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // ダイアログが閉じることを確認
      expect(find.text('カテゴリを選択'), findsNothing);
    });

    testWidgets('場所ダイアログが開く', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 場所選択ボタンを探す
      final locationButton = find.byIcon(Icons.location_on_outlined);
      expect(locationButton, findsOneWidget);

      // ボタンをタップ
      await tester.tap(locationButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認
      expect(find.text('収納場所を選択'), findsOneWidget);
      expect(find.text('新しい収納場所を追加'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
    });

    testWidgets('場所ダイアログ - キャンセルボタンで閉じる', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 場所選択ボタンをタップしてダイアログを開く
      final locationButton = find.byIcon(Icons.location_on_outlined);
      await tester.tap(locationButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認
      expect(find.text('収納場所を選択'), findsOneWidget);

      // キャンセルボタンをタップ
      final cancelButton = find.text('キャンセル');
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // ダイアログが閉じることを確認
      expect(find.text('収納場所を選択'), findsNothing);
    });

    testWidgets('場所ダイアログ - 新規場所入力', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 場所選択ボタンをタップしてダイアログを開く
      final locationButton = find.byIcon(Icons.location_on_outlined);
      await tester.tap(locationButton);
      await tester.pumpAndSettle();

      // 新規場所入力フィールドに文字を入力
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, 'テスト場所');
      await tester.pumpAndSettle();

      // 追加ボタンをタップ
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // ダイアログが閉じることを確認
      expect(find.text('収納場所を選択'), findsNothing);
    });

    testWidgets('ダイアログ - 背景タップで閉じる', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // カテゴリ選択ボタンをタップしてダイアログを開く
      final categoryButton = find.byIcon(Icons.category_outlined);
      await tester.tap(categoryButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認
      expect(find.text('カテゴリを選択'), findsOneWidget);

      // ダイアログの外側（バリア）をタップ
      await tester.tapAt(const Offset(50, 50)); // 画面の左上をタップ
      await tester.pumpAndSettle();

      // ダイアログが閉じることを確認
      expect(find.text('カテゴリを選択'), findsNothing);
    });
  });
}
