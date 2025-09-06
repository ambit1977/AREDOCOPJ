# 持ち物管理アプリ

写真を撮って収納と紐づけることが超簡単にできる、持ち物管理アプリです。

## 🎉 プロジェクト状況
**✅ 完全動作版** - 2025年9月6日時点でiOS/Android/macOS/Webで動作確認済み

### 最近の更新
- ✅ iOSコンパイルエラー修正完了
- ✅ SQLiteデータベース初期化問題解決
- ✅ アイテム編集機能追加
- ✅ 全プラットフォーム対応確認済み
- ✅ エラーハンドリング強化

## 機能

### 📸 写真撮影・選択
- カメラで直接撮影
- ギャラリーから写真選択
- 自動的にローカルストレージに保存
- クロスプラットフォーム対応（Web/Mobile）

### 📦 アイテム管理
- アイテム名、カテゴリ、収納場所を登録
- 写真と情報を紐づけて管理
- **🆕 アイテム編集機能** - 既存アイテムの情報・写真変更
- 簡単な検索機能
- アイテム削除機能

### 🗂️ 整理機能
- 収納場所別に表示
- カテゴリ別に表示
- 全体検索（名前、カテゴリ、収納場所）
- インタラクティブなUI

### 💾 データ管理
- SQLiteでローカルデータベース管理
- 安定したデータベース初期化
- アプリ内で完結（クラウド同期なし）
- エラー回復機能

## 技術スタック

- **Flutter 3.35.2** - クロスプラットフォーム開発
- **Provider** - 状態管理
- **SQLite (sqflite)** - ローカルデータベース
- **Camera/Image Picker** - 写真機能
- **Path Provider** - ファイルシステムアクセス

## 対応プラットフォーム

| プラットフォーム | 状況 | 備考 |
|---|---|---|
| 📱 **iOS** | ✅ 動作確認済み | シミュレータ・実機対応 |
| 🤖 **Android** | ✅ 動作確認済み | エミュレータ・実機対応 |
| 💻 **macOS** | ✅ 動作確認済み | ネイティブアプリとして動作 |
| 🌐 **Web** | ✅ 動作確認済み | ブラウザで動作 |

## セットアップ

### 必要環境

- Flutter SDK 3.35.2以上
- iOS 12.0以上 または Android API 21以上
- Xcode (iOS開発の場合)
- Android Studio (Android開発の場合)

### インストール手順

1. リポジトリをクローン：
   ```bash
   git clone https://github.com/ambit1977/AREDOCOPJ.git
   cd AREDOCOPJ
   ```

2. 依存関係をインストール：
   ```bash
   flutter pub get
   ```

3. アプリを実行：
   ```bash
   # macOS
   flutter run -d macos
   
   # iOS シミュレータ
   flutter run -d ios
   
   # Android エミュレータ  
   flutter run -d android
   
   # Web
   flutter run -d chrome
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

2. **アイテム編集** 🆕：
   - アイテムカードをタップ
   - 編集画面でアイテム情報を変更
   - 写真の変更も可能
   - 「保存」ボタンで更新

3. **アイテム検索**：
   - 上部の検索バーでキーワード検索
   - 「収納場所」「カテゴリ」タブで分類表示

4. **アイテム削除**：
   - アイテム詳細画面で三点メニューから削除

## プロジェクト構造

```
lib/
├── main.dart                    # アプリエントリポイント
├── models/
│   └── item.dart               # データモデル
├── providers/
│   └── item_provider.dart      # 状態管理
├── screens/
│   ├── home_screen.dart        # メイン画面
│   ├── add_item_screen.dart    # アイテム追加画面
│   └── edit_item_screen.dart   # 🆕 アイテム編集画面
├── services/
│   ├── database_service.dart   # データベース操作
│   └── camera_service.dart     # カメラ機能
└── widgets/
    └── item_card.dart          # アイテム表示ウィジェット

test/                           # 🆕 テストファイル
├── integration/                # 統合テスト
├── unit/                       # 単体テスト
└── widget/                     # ウィジェットテスト
```

## 🚀 開発者向け情報

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

# macOS アプリ
flutter build macos

# Web アプリ
flutter build web
```

### トラブルシューティング

#### iOS デバイスでの起動問題
```bash
# iOS ビルドキャッシュのクリア
flutter clean
cd ios && pod deintegrate && pod install
flutter build ios --debug
```

#### データベース問題
```bash
# macOS でデータベースファイルをリセット
rm -rf ~/Library/Containers/com.example.itemManager/Data/Documents/item_manager.db*
```

## 📝 更新履歴

### v1.1.0 (2025年9月6日)
- ✅ アイテム編集機能追加
- ✅ iOS コンパイルエラー修正
- ✅ データベース初期化問題解決
- ✅ 全プラットフォーム対応確認
- ✅ エラーハンドリング強化
- ✅ テストファイル追加

### v1.0.0 (初期リリース)
- 基本的なアイテム管理機能
- 写真撮影・選択機能
- SQLite データベース
- iOS/Android 対応

## 🤝 コントリビューション

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。
