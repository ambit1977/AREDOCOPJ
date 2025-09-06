import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:item_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('アイテム追加統合テスト', () {
    testWidgets('完全なアイテム追加フロー', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // アイテム追加画面に移動
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // アイテム名を入力
      final nameField = find.byType(TextFormField).where(
        (finder) => tester.widget<TextFormField>(finder).decoration?.labelText == 'アイテム名',
      );
      await tester.enterText(nameField.first, 'テストアイテム');
      await tester.pumpAndSettle();

      // カテゴリを選択
      final categoryButton = find.byIcon(Icons.category_outlined);
      await tester.tap(categoryButton);
      await tester.pumpAndSettle();

      // 新しいカテゴリを入力
      final categoryTextField = find.byType(TextField).first;
      await tester.enterText(categoryTextField, 'テストカテゴリ');
      await tester.pumpAndSettle();

      // 追加ボタンをタップ
      final addCategoryButton = find.byIcon(Icons.add);
      await tester.tap(addCategoryButton);
      await tester.pumpAndSettle();

      // 場所を選択
      final locationButton = find.byIcon(Icons.location_on_outlined);
      await tester.tap(locationButton);
      await tester.pumpAndSettle();

      // 新しい場所を入力
      final locationTextField = find.byType(TextField).first;
      await tester.enterText(locationTextField, 'テスト場所');
      await tester.pumpAndSettle();

      // 追加ボタンをタップ
      final addLocationButton = find.byIcon(Icons.add);
      await tester.tap(addLocationButton);
      await tester.pumpAndSettle();

      // 説明を入力
      final descriptionField = find.byType(TextFormField).where(
        (finder) => tester.widget<TextFormField>(finder).decoration?.labelText == '説明（任意）',
      );
      await tester.enterText(descriptionField.first, 'テスト説明');
      await tester.pumpAndSettle();

      // 保存ボタンをタップ
      final saveButton = find.byIcon(Icons.save);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // ホーム画面に戻ることを確認
      expect(find.text('持ち物管理'), findsOneWidget);

      // 追加したアイテムが表示されることを確認
      expect(find.text('テストアイテム'), findsOneWidget);
    });

    testWidgets('ダイアログキャンセル操作', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // アイテム追加画面に移動
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // カテゴリダイアログを開く
      final categoryButton = find.byIcon(Icons.category_outlined);
      await tester.tap(categoryButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認
      expect(find.text('カテゴリを選択'), findsOneWidget);

      // キャンセルボタンでダイアログを閉じる
      final cancelButton = find.text('キャンセル');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // ダイアログが閉じることを確認
      expect(find.text('カテゴリを選択'), findsNothing);

      // 場所ダイアログを開く
      final locationButton = find.byIcon(Icons.location_on_outlined);
      await tester.tap(locationButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認
      expect(find.text('収納場所を選択'), findsOneWidget);

      // 背景タップでダイアログを閉じる
      await tester.tapAt(const Offset(50, 50));
      await tester.pumpAndSettle();

      // ダイアログが閉じることを確認
      expect(find.text('収納場所を選択'), findsNothing);
    });

    testWidgets('バリデーションテスト', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // アイテム追加画面に移動
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // アイテム名を空のまま保存を試行
      final saveButton = find.byIcon(Icons.save);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // エラーメッセージが表示されることを確認
      expect(find.text('アイテム名を入力してください'), findsOneWidget);
    });
  });
}
