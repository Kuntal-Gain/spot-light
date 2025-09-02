import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String eventId;
  final String name;
  final String type; // e.g., "chat", "poll", "video"
  final List<String> participants; // userIds
  final String createdBy;
  final String messageId;
  final Timestamp createdAt;
  final String? description; // optional
  final String? coverImage; // optional
  final String? lastMessage;
  final Timestamp? lastMessageTime;

  const EventEntity({
    required this.eventId,
    required this.name,
    required this.type,
    required this.participants,
    required this.createdBy,
    required this.messageId,
    required this.createdAt,
    this.description,
    this.coverImage,
    this.lastMessage,
    this.lastMessageTime,
  });

  @override
  List<Object?> get props => [
        eventId,
        name,
        type,
        participants,
        createdBy,
        messageId,
        createdAt,
        description,
        coverImage,
        lastMessage,
        lastMessageTime,
      ];
}
