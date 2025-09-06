# 画像表示問題の修正内容

## 問題の根本原因

### 1. シミュレーター環境でのアプリケーションID変更
- アプリ再起動時にアプリケーションIDが変更される
- 保存された画像の絶対パスが無効になる
- 例：`/data/Containers/Data/Application/[変動するID]/Documents/images/file.jpg`

### 2. 絶対パス保存方式の問題
- CameraServiceで絶対パスを返していた
- データベースに絶対パスを保存
- パスの解決に失敗すると画像が表示されない

## 解決策の実装

### 1. ファイル名のみ保存方式に変更
```dart
// 修正前
return localPath; // フルパス

// 修正後  
return fileName; // ファイル名のみ
```

### 2. 動的パス解決機能の追加
```dart
/// ファイル名から現在のアプリディレクトリでの完全パスを取得
static Future<String> getImagePath(String fileName) async {
  if (kIsWeb || fileName.startsWith('data:image')) {
    return fileName;
  }
  
  if (fileName.contains('/')) {
    fileName = path.basename(fileName);
  }
  
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String imagesDir = path.join(appDocDir.path, 'images');
  return path.join(imagesDir, fileName);
}
```

### 3. FutureBuilder による画像表示
```dart
return FutureBuilder<String>(
  future: CameraService.getImagePath(item.imagePath!),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (snapshot.hasError || !snapshot.hasData) {
      return errorContainer;
    }
    
    final String fullPath = snapshot.data!;
    return Image.file(File(fullPath), ...);
  },
);
```

### 4. 既存データの一括修正
```dart
// 画像パスを修正（ファイル名のみに変換）
bool hasUpdates = false;
for (int i = 0; i < _items.length; i++) {
  final item = _items[i];
  if (item.imagePath != null && item.imagePath!.contains('/')) {
    // フルパスの場合、ファイル名のみに変換
    final fileName = path.basename(item.imagePath!);
    const updatedItem = Item(
      id: item.id,
      // ... other fields
      imagePath: fileName,
    );
    _items[i] = updatedItem;
    await _storageService.updateItem(updatedItem);
    hasUpdates = true;
  }
}
```

## 修正されたファイル

1. **lib/services/camera_service.dart**
   - ファイル名のみ返すように変更
   - getImagePath() 静的メソッド追加
   - imageExists() 静的メソッド追加

2. **lib/widgets/item_card.dart**
   - FutureBuilder による動的パス解決
   - CameraService import 追加
   - 画像検証ロジック削除

3. **lib/screens/add_item_screen.dart**
   - 画像プレビューの動的パス解決
   - ファイル名とフルパス両方に対応

4. **lib/providers/item_provider.dart**
   - 既存データの一括パス修正
   - path package import 追加

## 期待される改善

1. **アプリ再起動後も画像表示が維持される**
2. **シミュレーター環境での安定した動作**
3. **既存のアイテムの画像も自動修正される**
4. **新規アイテムは最初から正しい形式で保存される**

## テスト手順

1. アプリを起動して既存アイテムを確認
2. 新しいアイテムに画像を追加
3. アプリを完全に終了
4. アプリを再起動
5. 既存・新規両方のアイテムの画像が表示されることを確認

この修正により、シミュレーター環境でも実機環境でも安定して画像が表示されるようになります。
