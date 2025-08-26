import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.eventId,
    required super.name,
    required super.type,
    required super.participants,
    required super.createdBy,
    required super.messageId,
    required super.createdAt,
    super.description,
    super.coverImage,
    super.lastMessage,
  });

  factory EventModel.fromSnapshot(DocumentSnapshot snap) {
    var ss = snap.data() as Map<String, dynamic>;

    return EventModel(
      eventId: ss['eventId'],
      name: ss['name'] ?? '',
      type: ss['type'] ?? '',
      participants: List<String>.from(ss['participants'] ?? []),
      createdBy: ss['createdBy'] ?? '',
      createdAt: ss['createdAt'] as Timestamp,
      description: ss['description'],
      messageId: ss['messageId'] ?? '',
      coverImage: ss['coverImage'] ?? '',
      lastMessage: ss['lastMessage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'name': name,
      'type': type,
      'participants': participants,
      'createdBy': createdBy,
      'messageId': messageId,
      'description': description,
      'coverImage': coverImage,
      'createdAt': createdAt,
      'lastMessage': lastMessage,
    };
  }
}
