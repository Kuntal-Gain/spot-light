import 'dart:convert';
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';

class PollModel extends PollEntity {
  PollModel({
    required super.id,
    required super.eventId,
    required super.question,
    required super.options,
    required super.createdAt,
    required super.createdBy,
    super.expiresAt,
  });

  factory PollModel.fromMap(Map<String, dynamic> map) {
    return PollModel(
      id: map['\$id'],
      eventId: map['eventId'],
      question: map['question'],
      options: map['options'] != null
          ? (jsonDecode(map['options']) as List<dynamic>)
              .map((e) => PollOptionModel.fromMap(e))
              .toList()
          : [],
      createdAt: DateTime.parse(map['\$createdAt']),
      createdBy: map['createdBy'],
      expiresAt:
          map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'question': question,
      // Encode options list as JSON string
      'options': jsonEncode(
        options.map((op) => (op as PollOptionModel).toMap()).toList(),
      ),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

class PollOptionModel extends PollOptionEntity {
  PollOptionModel({
    required super.id,
    required super.text,
    required super.votes,
  });

  factory PollOptionModel.fromMap(Map<String, dynamic> map) {
    return PollOptionModel(
      id: map['id'],
      text: map['text'],
      votes: map['votes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
    };
  }
}
