import 'package:spot_time/core/usecase/usecase.dart';
import 'package:spot_time/feature/event/domain/entities/chat_entity.dart';
import 'package:spot_time/feature/event/domain/repo/firebase_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';

class FetchMessagesUsecase
    implements StreamUseCase<List<MessageEntity>, FetchMessageParams> {
  final FirebaseRepository repository;
  FetchMessagesUsecase(this.repository);

  @override
  Stream<Either<Failure, List<MessageEntity>>> call(FetchMessageParams params) {
    return repository.subscribeMessages(params.eventId, params.messageId);
  }
}

class FetchMessageParams {
  final String eventId;
  final String messageId;

  FetchMessageParams({required this.eventId, required this.messageId});
}
