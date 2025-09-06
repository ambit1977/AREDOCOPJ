import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:item_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Item Manager App Integration Tests', () {
    testWidgets('complete item management flow', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // ホーム画面が表示されることを確認
      expect(find.text('持ち物管理'), findsOneWidget);
      expect(find.text('全て'), findsOneWidget);
      expect(find.text('カテゴリ'), findsOneWidget);
      expect(find.text('場所'), findsOneWidget);

      // アイテム追加画面に移動
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // アイテム追加画面が表示されることを確認
      expect(find.text('アイテム追加'), findsOneWidget);

      // フォームにデータを入力
      await tester.enterText(
        find.widgetWithText(TextFormField, 'アイテム名'),
        'テスト統合アイテム',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'カテゴリ'),
        'テストカテゴリ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '収納場所'),
        'テスト場所',
      );

      // アイテムを追加
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // ホーム画面に戻ることを確認
      expect(find.text('持ち物管理'), findsOneWidget);

      // 追加されたアイテムが表示されることを確認
      expect(find.text('テスト統合アイテム'), findsOneWidget);
      expect(find.text('テストカテゴリ'), findsOneWidget);
      expect(find.text('テスト場所'), findsOneWidget);

      // 検索機能をテスト
      await tester.enterText(find.byType(TextField), 'テスト統合');
      await tester.pumpAndSettle();

      // 検索結果に該当アイテムが表示されることを確認
      expect(find.text('テスト統合アイテム'), findsOneWidget);

      // 検索をクリア
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // アイテムの詳細表示をテスト
      await tester.tap(find.text('テスト統合アイテム'));
      await tester.pumpAndSettle();

      // 詳細ダイアログが表示されることを確認
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('カテゴリ:'), findsOneWidget);
      expect(find.text('収納場所:'), findsOneWidget);

      // ダイアログを閉じる
      await tester.tap(find.text('閉じる'));
      await tester.pumpAndSettle();

      // アイテムの削除をテスト
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // 削除確認ダイアログが表示されることを確認
      expect(find.text('削除確認'), findsOneWidget);

      // 削除を確認
      await tester.tap(find.text('削除').last);
      await tester.pumpAndSettle();

      // アイテムが削除されたことを確認
      expect(find.text('テスト統合アイテム'), findsNothing);
    });

    testWidgets('category filter functionality', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 複数のアイテムを追加
      for (int i = 1; i <= 3; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'アイテム名'),
          'アイテム$i',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'カテゴリ'),
          i <= 2 ? 'カテゴリA' : 'カテゴリB',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, '収納場所'),
          '場所$i',
        );

        await tester.tap(find.text('追加'));
        await tester.pumpAndSettle();
      }

      // カテゴリタブに移動
      await tester.tap(find.text('カテゴリ'));
      await tester.pumpAndSettle();

      // カテゴリAを選択
      await tester.tap(find.text('カテゴリA'));
      await tester.pumpAndSettle();

      // カテゴリAのアイテムのみ表示されることを確認
      expect(find.text('アイテム1'), findsOneWidget);
      expect(find.text('アイテム2'), findsOneWidget);
      expect(find.text('アイテム3'), findsNothing);

      // 全てタブに戻る
      await tester.tap(find.text('全て'));
      await tester.pumpAndSettle();

      // 全てのアイテムが表示されることを確認
      expect(find.text('アイテム1'), findsOneWidget);
      expect(find.text('アイテム2'), findsOneWidget);
      expect(find.text('アイテム3'), findsOneWidget);
    });

    testWidgets('location filter functionality', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 場所タブに移動
      await tester.tap(find.text('場所'));
      await tester.pumpAndSettle();

      // 場所が表示されることを確認（前のテストで追加されたアイテムの場所）
      expect(find.text('場所1'), findsOneWidget);
      expect(find.text('場所2'), findsOneWidget);
      expect(find.text('場所3'), findsOneWidget);

      // 場所1を選択
      await tester.tap(find.text('場所1'));
      await tester.pumpAndSettle();

      // 場所1のアイテムのみ表示されることを確認
      expect(find.text('アイテム1'), findsOneWidget);
      expect(find.text('アイテム2'), findsNothing);
      expect(find.text('アイテム3'), findsNothing);
    });
  });
}
