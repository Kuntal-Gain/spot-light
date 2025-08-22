import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.name,
    required super.type,
    required super.participants,
    required super.createdBy,
    required super.messageId,
    required super.createdAt,
    super.description,
    super.coverImage,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['\$id'],
      name: map['name'],
      type: map['type'],
      participants: List<String>.from(map['participants'] ?? []),
      createdBy: map['createdBy'],
      createdAt: DateTime.parse(map['\$createdAt']),
      description: map['description'],
      messageId: map['messageId'],
      coverImage: map['coverImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'participants': participants,
      'createdBy': createdBy,
      'messageId': messageId,
      'description': description,
      'coverImage': coverImage,
    };
  }
}
