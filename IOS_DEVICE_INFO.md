# iOS実機テスト用デバイス情報

## 現在のテスト対象デバイス
- **デバイスID**: `00008110-00020D013EBA201E`
- **プラットフォーム**: iOS実機
- **状況**: 
  - ミニマルアプリ: ✅ 動作確認済み
  - フルアプリ: ❌ クラッシュ発生

## テスト履歴
- ミニマルバージョン (`main_minimal.dart`): 成功
- フルバージョン (`main.dart`): クラッシュ
- シミュレータ: 動作確認済み

## 実行コマンド例
```bash
# ミニマルテスト
flutter run -t lib/main_minimal.dart -d "00008110-00020D013EBA201E"

# デバッグテスト  
flutter run -t lib/main_debug.dart -d "00008110-00020D013EBA201E"

# フルアプリテスト
flutter run -d "00008110-00020D013EBA201E"

# ビルドテスト
flutter build ios --debug --no-codesign
```

## デバッグ戦略
1. Stage 1: 基本アプリ（ミニマル相当）
2. Stage 2: Provider追加
3. Stage 3: パッケージ初期化追加  
4. Stage 4: データベース初期化追加
5. Stage 5: エラーハンドリング追加
6. Stage 6: フル機能

各ステージで段階的にテストして問題の箇所を特定する。
