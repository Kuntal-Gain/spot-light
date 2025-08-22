class MessageEntity {
  final String id;
  final String senderId;
  final String content; // could be text / file url
  final String? mediaUrl;
  final String? pollId;
  final String type; // "text", "image", "video", "poll"
  final DateTime createdAt;

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
