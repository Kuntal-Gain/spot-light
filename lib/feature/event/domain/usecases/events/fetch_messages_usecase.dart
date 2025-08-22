import 'package:spot_time/core/usecase/usecase.dart';
import 'package:spot_time/feature/event/domain/entities/chat_entity.dart';
import 'package:spot_time/feature/event/domain/repo/appwrite_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';

class FetchMessagesUsecase
    implements StreamUseCase<List<MessageEntity>, String> {
  final AppwriteRepository repository;
  FetchMessagesUsecase(this.repository);

  @override
  Stream<Either<Failure, List<MessageEntity>>> call(String eventId) {
    return repository.subscribeMessages(eventId);
  }
}
