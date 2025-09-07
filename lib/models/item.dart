class Item {
  final String id;
  final String name;
  final String category;
  final String location;
  final String? imagePath;
  final String? description; // アイテムの説明フィールドを追加
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    this.imagePath,
    this.description, // 説明フィールドを追加
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'location': location,
      'imagePath': imagePath,
      'description': description, // 説明フィールドをマップに追加
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      location: map['location'],
      imagePath: map['imagePath'],
      description: map['description'], // 説明フィールドをマップから読み取り
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Item copyWith({
    String? id,
    String? name,
    String? category,
    String? location,
    String? imagePath,
    String? description, // 説明フィールドをcopyWithに追加
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description, // 説明フィールドのcopyWith対応
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
