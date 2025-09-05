import '../../domain/entities/poll_entity.dart';
import 'package:firebase_database/firebase_database.dart';

class PollModel extends PollEntity {
  PollModel({
    required String id,
    required String eventId,
    required String question,
    required List<PollOptionEntity> options,
    required String createdBy,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) : super(
          id: id,
          eventId: eventId,
          question: question,
          options: options,
          createdBy: createdBy,
          createdAt: createdAt,
          expiresAt: expiresAt,
        );

  Map<String, dynamic> toMap() {
    final optionsMap = {
      for (var opt in options)
        opt.id: {
          'id': opt.id,
          'text': opt.text,
          'votes': opt.votes,
        }
    };

    return {
      'id': id,
      'eventId': eventId,
      'question': question,
      'options': optionsMap, // ✅ store as map instead of list
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
    };
  }

  factory PollModel.fromSnapshot(DataSnapshot snapshot) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    // 🔎 Handle options as Map
    final optionsData = data['options'];
    List<PollOptionEntity> optionsList = [];

    if (optionsData is Map) {
      // case 1: options stored as {op1: {...}, op0: {...}}
      optionsList = optionsData.values.map((opt) {
        final optMap = Map<String, dynamic>.from(opt as Map);
        return PollOptionEntity(
          id: optMap['id'] as String,
          text: optMap['text'] as String,
          votes: optMap['votes'] != null
              ? Map<String, dynamic>.from(optMap['votes'])
              : {},
        );
      }).toList();
    } else if (optionsData is List) {
      // case 2: options stored as [ {...}, {...} ]
      optionsList = optionsData.map((opt) {
        final optMap = Map<String, dynamic>.from(opt as Map);
        return PollOptionEntity(
          id: optMap['id'] as String,
          text: optMap['text'] as String,
          votes: optMap['votes'] != null
              ? Map<String, dynamic>.from(optMap['votes'])
              : {},
        );
      }).toList();
    }

    return PollModel(
      id: data['id'] as String,
      eventId: data['eventId'] as String,
      question: data['question'] as String,
      options: optionsList,
      createdBy: data['createdBy'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
      expiresAt: data['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['expiresAt'])
          : null,
    );
  }

  PollEntity toEntity() => this;
}
