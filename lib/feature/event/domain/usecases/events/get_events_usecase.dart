import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/event_entity.dart';
import '../../repo/firebase_repository.dart';

class GetEvents implements UseCase<List<EventEntity>, NoParams> {
  final FirebaseRepository repository;
  GetEvents(this.repository);

  @override
  Future<Either<Failure, List<EventEntity>>> call(NoParams params) {
    return repository.getEvents();
  }
}
