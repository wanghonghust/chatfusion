import 'package:chatfusion/database/index.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Message {
  final int? id;
  final int conversationId;
  final int role; // 0 for user, 1 for bot
  final String model;
  final String? thinkContent;
  final String content;
  int? createAt;

  Message({
    this.id,
    required this.conversationId,
    required this.role,
    required this.model,
    required this.content,
    this.thinkContent,
    int? createAt,
  }) : createAt = createAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Map<String, Object?> toMap() {
    return {
      'conversationId': conversationId,
      'role': role,
      'model': model,
      'content': content,
      'thinkContent': thinkContent,
      'createAt': createAt
    };
  }

  @override
  String toString() {
    return 'Message{id: $id, conversationId: $conversationId, role: $role, model: $model, content: $content, thinkContent: $thinkContent, createAt: $createAt}';
  }

  DateTime? get createAtDateTime => createAt != null
      ? DateTime.fromMillisecondsSinceEpoch(createAt! * 1000)
      : null;

  static Future<void> insertMessage(Message conversation) async {
    final db = await database;

    await db.insert(
      'messages',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Message>> getConversationMessage(
      int conversationId) async {
    // Get a reference to the database.
    final db = await database;

    final List<Map<String, Object?>> dogMaps = await db.query('messages',
        where: 'conversationId = ?', whereArgs: [conversationId]);

    return [
      for (final {
            'id': id as int,
            'conversationId': conversationId as int,
            'role': role as int,
            'model': model as String,
            'content': content as String,
            'thinkContent': thinkContent as String?,
            'createAt': createAt as int?,
          } in dogMaps)
        Message(
          id: id,
          conversationId: conversationId,
          role: role,
          model: model,
          content: content,
          thinkContent: thinkContent == null || thinkContent.isEmpty
              ? null
              : thinkContent,
          createAt: createAt,
        ),
    ];
  }

  static Future<List<Message>> getModelConversationMessage(
      int conversationId, String model) async {
    // Get a reference to the database.
    final db = await database;

    final List<Map<String, Object?>> dogMaps = await db.query('messages',
        where: 'conversationId = ? and model = ? ',
        whereArgs: [conversationId, model]);

    return [
      for (final {
            'id': id as int,
            'conversationId': conversationId as int,
            'role': role as int,
            'model': model as String,
            'content': content as String,
            'thinkContent': thinkContent as String,
            'createAt': createAt as int?,
          } in dogMaps)
        Message(
          id: id,
          conversationId: conversationId,
          role: role,
          model: model,
          content: content,
          thinkContent: thinkContent,
          createAt: createAt,
        ),
    ];
  }
}
