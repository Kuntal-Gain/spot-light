import 'package:dartz/dartz.dart';
import 'package:spot_time/feature/event/domain/repo/firebase_repository.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/poll_entity.dart';

class CreateNewPoll implements UseCase<Unit, PollEntity> {
  final FirebaseRepository repository;
  CreateNewPoll(this.repository);

  @override
  Future<Either<Failure, Unit>> call(PollEntity poll) async {
    return await repository.createNewPoll(
      poll: poll,
    );
  }
}
