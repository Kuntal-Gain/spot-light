import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/chat_entity.dart';
import '../../repo/appwrite_repository.dart';
import 'package:dartz/dartz.dart';

class SendMessage implements UseCase<Unit, SendMessageParams> {
  final AppwriteRepository repository;
  SendMessage(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendMessageParams params) {
    return repository.sendMessage(
      eventId: params.eventId,
      message: params.message,
    );
  }
}

class SendMessageParams {
  final String eventId;
  final MessageEntity message;

  SendMessageParams({
    required this.eventId,
    required this.message,
  });
}
