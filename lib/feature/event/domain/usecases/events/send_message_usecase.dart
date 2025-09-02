import 'package:spot_time/feature/event/domain/entities/event_entity.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/chat_entity.dart';
import '../../repo/firebase_repository.dart';
import 'package:dartz/dartz.dart';

class SendMessage implements UseCase<Unit, SendMessageParams> {
  final FirebaseRepository repository;
  SendMessage(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendMessageParams params) {
    return repository.sendMessage(
      event: params.event,
      message: params.message,
    );
  }
}

class SendMessageParams {
  final EventEntity event;
  final MessageEntity message;

  SendMessageParams({
    required this.event,
    required this.message,
  });
}
