class MessageEntity {
  final String id;
  final String senderId;
  final String content; // can be text / url / poll question
  final String? mediaUrl;
  final String? pollId;
  final String type; // "text", "image", "video", "poll"
  final int createdAt; // store as millisecondsSinceEpoch from RTDB

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.content,
    this.mediaUrl,
    this.pollId,
    required this.type,
    required this.createdAt,
  });
}
