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

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['\$id'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      pollId: map['pollId'] ?? '',
      type: map['type'] ?? '',
      createdAt: DateTime.parse(map['\$createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'mediaUrl': mediaUrl,
      'pollId': pollId,
      'type': type,
    };
  }
}
