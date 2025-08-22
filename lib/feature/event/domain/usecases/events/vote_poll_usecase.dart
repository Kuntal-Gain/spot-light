import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repo/appwrite_repository.dart';

class VotePollUsecase implements UseCase<Unit, VotePollParams> {
  final AppwriteRepository repository;
  VotePollUsecase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(VotePollParams params) async {
    return await repository.votePoll(
      pollId: params.pollId,
      optionId: params.optionId,
    );
  }
}

class VotePollParams {
  final String pollId;
  final String optionId;

  VotePollParams({
    required this.pollId,
    required this.optionId,
  });
}
