import 'package:dartz/dartz.dart';
import 'package:spot_time/feature/event/domain/repo/firebase_repository.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/poll_entity.dart';

class GetSinglePoll implements UseCase<PollEntity, String> {
  final FirebaseRepository repository;
  GetSinglePoll(this.repository);

  @override
  Future<Either<Failure, PollEntity>> call(String pollId) async {
    return await repository.getSinglePoll(pollId);
  }
}
