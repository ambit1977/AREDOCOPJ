import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/item.dart';
import 'storage_service.dart';

class DatabaseService extends StorageService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    try {
      debugPrint('DatabaseService: データベース取得開始');
      if (_database != null) {
        debugPrint('DatabaseService: 既存データベース使用');
        return _database!;
      }
      debugPrint('DatabaseService: 新しいデータベース初期化開始');
      _database = await _initDatabase();
      debugPrint('DatabaseService: データベース初期化完了');
      return _database!;
    } catch (e, stackTrace) {
      debugPrint('DatabaseService database getter エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      debugPrint('DatabaseService: _initDatabase開始');
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'item_manager.db');
      debugPrint('DatabaseService: データベースパス: $path');
      
      // データベースファイルが存在するかチェック
      bool exists = await File(path).exists();
      debugPrint('DatabaseService: データベースファイル存在: $exists');
      
      // データベース接続を開く
      debugPrint('DatabaseService: データベース接続開始');
      final db = await openDatabase(
        path,
        version: 2, // バージョンを2に更新
        onCreate: _onCreate,
        onUpgrade: _onUpgrade, // アップグレード処理を追加
        // データベース接続のパフォーマンスを向上
        singleInstance: true,
      );
      
      debugPrint('DatabaseService: データベース接続成功');
      
      // 接続が成功したが、テーブルが存在しない場合の対策
      if (!exists) {
        debugPrint('DatabaseService: 新規データベース - テーブル存在確認');
        // 明示的にテーブル作成を確認
        final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        if (tables.isEmpty || !tables.any((table) => table['name'] == 'items')) {
          await _onCreate(db, 1);
        }
      }
      
      return db;
    } catch (e) {
      print('データベース初期化エラー: $e');
      // 致命的なエラーの場合は再スロー
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT NOT NULL,
        imagePath TEXT,
        description TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('DatabaseService: データベースアップグレード $oldVersion -> $newVersion');
    
    if (oldVersion < 2) {
      // descriptionカラムを追加
      await db.execute('ALTER TABLE items ADD COLUMN description TEXT');
      debugPrint('DatabaseService: descriptionカラムを追加しました');
    }
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  Future<List<Item>> getItemsByLocation(String location) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'location = ?',
      whereArgs: [location],
    );
    
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  Future<List<Item>> getItemsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'category = ?',
      whereArgs: [category],
    );
    
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(String id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getAllLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT location FROM items ORDER BY location',
    );
    
    return maps.map((map) => map['location'] as String).toList();
  }

  Future<List<String>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM items ORDER BY category',
    );
    
    return maps.map((map) => map['category'] as String).toList();
  }
  
  // 使用頻度の高い場所を取得（新しく追加）
  Future<List<String>> getFrequentLocations(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT location, COUNT(*) as count 
      FROM items 
      GROUP BY location 
      ORDER BY count DESC, updatedAt DESC
      LIMIT ?
    ''', [limit]);
    
    return maps.map((map) => map['location'] as String).toList();
  }
  
  // 使用頻度の高いカテゴリを取得（新しく追加）
  Future<List<String>> getFrequentCategories(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM items 
      GROUP BY category 
      ORDER BY count DESC, updatedAt DESC
      LIMIT ?
    ''', [limit]);
    
    return maps.map((map) => map['category'] as String).toList();
  }
}
