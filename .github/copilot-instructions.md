# 持ち物管理アプリ - Flutter プロジェクト

## プロジェクト概要
写真を撮って収納と紐づけることが簡単にできる持ち物管理アプリをFlutterで開発しました。

## 技術スタック
- Flutter 3.35.2
- Dart
- iOS/Android クロスプラットフォーム
- カメラ機能（camera, image_picker）
- ローカルストレージ（SQLite）
- 状態管理（Provider）

## プロジェクト進捗
- [x] プロジェクト要件の明確化
- [x] Flutterプロジェクトのスキャフォールド
- [x] プロジェクトのカスタマイズ
- [x] 必要な拡張機能のインストール（スキップ - 標準的なFlutterプロジェクト）
- [x] プロジェクトのコンパイル（静的解析完了）
- [x] タスクの作成と実行（次のステップ）
- [ ] プロジェクトの起動
- [x] ドキュメントの完成（README.md更新済み）

## 実装済み機能

### 📱 アプリケーション機能
- 写真撮影・ギャラリー選択機能
- アイテム追加・削除機能
- 収納場所・カテゴリ別表示
- 検索機能
- SQLiteによるローカルデータ管理

### 📁 プロジェクト構造
- `lib/models/item.dart` - データモデル
- `lib/providers/item_provider.dart` - 状態管理
- `lib/services/database_service.dart` - データベース操作
- `lib/services/camera_service.dart` - カメラ機能
- `lib/screens/home_screen.dart` - メイン画面
- `lib/screens/add_item_screen.dart` - アイテム追加画面
- `lib/widgets/item_card.dart` - アイテム表示ウィジェット

### ⚙️ 設定済み
- iOS/Android権限設定（カメラ、ストレージ）
- 依存関係インストール完了
- 静的解析エラー解決済み
