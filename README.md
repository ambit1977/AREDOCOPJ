# 持ち物管理アプリ

写真を撮って収納と紐づけることが超簡単にできる、持ち物管理アプリです。

## 機能

### 📸 写真撮影・選択
- カメラで直接撮影
- ギャラリーから写真選択
- 自動的にローカルストレージに保存

### 📦 アイテム管理
- アイテム名、カテゴリ、収納場所を登録
- 写真と情報を紐づけて管理
- 簡単な検索機能

### 🗂️ 整理機能
- 収納場所別に表示
- カテゴリ別に表示
- 全体検索（名前、カテゴリ、収納場所）

### 💾 データ管理
- SQLiteでローカルデータベース管理
- アプリ内で完結（クラウド同期なし）
- 削除機能

## 技術スタック

- **Flutter 3.35.2** - クロスプラットフォーム開発
- **Provider** - 状態管理
- **SQLite** - ローカルデータベース
- **Camera/Image Picker** - 写真機能
- **Path Provider** - ファイルシステムアクセス

## セットアップ

### 必要環境
- Flutter SDK 3.35.2以上
- iOS 12.0以上 または Android API 21以上

### インストール手順

1. 依存関係をインストール：
   ```bash
   flutter pub get
   ```

2. アプリを実行：
   ```bash
   flutter run
   ```

### 権限設定

#### iOS
- カメラアクセス権限
- フォトライブラリアクセス権限

#### Android
- カメラ権限
- ストレージ読み書き権限

## 使い方

1. **アイテム追加**：
   - 右下の+ボタンをタップ
   - 写真を撮影または選択
   - アイテム名、カテゴリ、収納場所を入力
   - 「追加」ボタンで保存

2. **アイテム検索**：
   - 上部の検索バーでキーワード検索
   - 「収納場所」「カテゴリ」タブで分類表示

3. **アイテム詳細**：
   - アイテムカードをタップで詳細表示
   - 三点メニューから削除可能

## プロジェクト構造

```
lib/
├── main.dart              # アプリエントリポイント
├── models/
│   └── item.dart          # データモデル
├── providers/
│   └── item_provider.dart # 状態管理
├── screens/
│   ├── home_screen.dart   # メイン画面
│   └── add_item_screen.dart # アイテム追加画面
├── services/
│   ├── database_service.dart # データベース操作
│   └── camera_service.dart   # カメラ機能
└── widgets/
    └── item_card.dart     # アイテム表示ウィジェット
```

## 開発者向け情報

### デバッグ
```bash
flutter analyze      # 静的解析
flutter test         # テスト実行
flutter doctor       # 環境チェック
```

### ビルド
```bash
# Android APK
flutter build apk

# iOS (Macでのみ)
flutter build ios
```
