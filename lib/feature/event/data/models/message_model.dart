import 'package:spot_time/feature/event/domain/entities/chat_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    super.mediaUrl,
    super.pollId,
    required super.type,
    required super.createdAt,
  });

  /// Convert to Map for RTDB
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'mediaUrl': mediaUrl,
      'pollId': pollId,
      'type': type,
      'createdAt': createdAt, // normally set via ServerValue.timestamp
    };
  }

  /// Build from Map (RTDB snapshot)
  factory MessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'],
      pollId: map['pollId'],
      type: map['type'] ?? 'text',
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
