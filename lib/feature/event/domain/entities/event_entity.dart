import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String name;
  final String type; // e.g., "chat", "poll", "video"
  final List<String> participants; // userIds
  final String createdBy;
  final String messageId;
  final DateTime createdAt;
  final String? description; // optional
  final String? coverImage; // optional

  const EventEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
    required this.createdBy,
    required this.messageId,
    required this.createdAt,
    this.description,
    this.coverImage,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        participants,
        createdBy,
        messageId,
        createdAt,
        description,
        coverImage,
      ];
}
