import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/event_entity.dart';
import '../../repo/firebase_repository.dart';

class AddEvent implements UseCase<void, EventEntity> {
  final FirebaseRepository repository;
  AddEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(EventEntity event) async {
    return repository.addEvent(event);
  }
}
