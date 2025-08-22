class PollEntity {
  final String id;
  final String eventId; // link poll to its event
  final String question;
  final List<PollOptionEntity> options;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? expiresAt; // optional expiration

  PollEntity({
    required this.id,
    required this.eventId,
    required this.question,
    required this.options,
    required this.createdBy,
    required this.createdAt,
    this.expiresAt,
  });
}

class PollOptionEntity {
  final String id;
  final String text;
  final List<String> votes; // store userIds who voted

  PollOptionEntity({
    required this.id,
    required this.text,
    required this.votes,
  });
}
