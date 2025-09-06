# 実機クラッシュ問題 - 解決済み

## 問題の概要
- 実機でのアプリ起動時にクラッシュが発生
- シミュレータでは正常動作
- Xcode経由では起動可能、スタンドアロン起動で失敗

## 根本原因
1. **数値計算エラー**: `Infinity`や`NaN`値での`toInt()`操作
2. **初期化順序の問題**: 非同期処理の競合状態
3. **メモリ制限**: 実機での厳しいメモリ制約
4. **ファイルパスの問題**: 絶対パスと相対パスの混在

## 解決策

### 1. 安全な数値変換の実装
```dart
// 修正前
cacheWidth: (width * 2).toInt()

// 修正後
cacheWidth: width.isFinite && width > 0 ? (width * 2).toInt() : null
```

### 2. 強化されたエラーハンドリング
- `CrashReporter`クラスによる詳細ログ
- `FlutterError.onError`での包括的エラーキャッチ
- `PlatformDispatcher.instance.onError`でのアプリレベル例外処理

### 3. 段階的初期化
- データベース初期化の分離
- UI描画と重い処理の分離
- 適切な非同期処理の順序制御

### 4. ファイルパス正規化
- 絶対パスをファイル名のみに統一
- 動的パス解決の実装

## 修正されたファイル
- `lib/main.dart`: エラーハンドリングとログ機能追加
- `lib/providers/item_provider.dart`: 安全な初期化処理
- `lib/widgets/item_card.dart`: 安全な数値計算
- `lib/services/camera_service.dart`: パス正規化
- `lib/services/database_service.dart`: 堅牢なDB初期化
- `lib/utils/crash_reporter.dart`: クラッシュレポート機能（新規）
- `lib/screens/error_fallback_screen.dart`: エラー表示画面（新規）

## 検証結果
✅ シミュレータでの動作確認
✅ 実機でのXcode経由起動確認
✅ 実機でのスタンドアロン起動確認
✅ アイテム表示機能の動作確認
✅ 画像表示機能の動作確認

## 今後の保守点
1. 定期的なクラッシュログの確認
2. 新機能追加時の実機テスト
3. メモリ使用量の監視
4. エラーハンドリングの継続改善
