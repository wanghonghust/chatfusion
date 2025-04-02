import 'package:chatfusion/database/index.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Conversation {
  final int? id;
  final String title;
  final int? createAt;

  Conversation({
    this.id,
    required this.title,
    int? createAt,
  }) : createAt = createAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Map<String, Object?> toMap() {
    return {'title': title, 'createAt': createAt};
  }

  @override
  String toString() {
    return 'Conversation{id: $id, title: $title, createAt: $createAt}';
  }

  DateTime? get createAtDateTime => createAt != null
      ? DateTime.fromMillisecondsSinceEpoch(createAt! * 1000)
      : null;
  static Future<int> insertConversation(Conversation conversation) async {
    final db = await database;

    return db.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> save() async {
    final db = await database;
    return db.insert(
      'conversations',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> changeTitle(int id, String title) async {
    final db = await database;
    await db.update('conversations', {'title': title},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Conversation>> getConversations({bool asc = true}) async {
    // Get a reference to the database.
    final db = await database;

    final List<Map<String, Object?>> conversationMaps =
        await db.query('conversations', orderBy: 'id ${asc ? 'ASC' : 'DESC'}');

    return [
      for (final {
            'id': id as int,
            'title': title as String,
            'createAt': createAt as int?,
          } in conversationMaps)
        Conversation(id: id, title: title, createAt: createAt),
    ];
  }

  static Future<void> deleteConversation(int id) async {
    final db = await database;
    await db.delete('messages',
        where: 'conversationId = ?', whereArgs: [id]).then((res) async {
      await db.delete('conversations',
          where: 'id = ?', whereArgs: [id]).then((res1) {});
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Conversation) return false;
    return id == other.id;
  }
}
