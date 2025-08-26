import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/event_entity.dart';
import '../../repo/firebase_repository.dart';
import 'package:dartz/dartz.dart';

class GetSingleEvent implements UseCase<EventEntity, String> {
  final FirebaseRepository repository;
  GetSingleEvent(this.repository);

  @override
  Future<Either<Failure, EventEntity>> call(String eventId) {
    return repository.getSingleEvent(eventId);
  }
}
