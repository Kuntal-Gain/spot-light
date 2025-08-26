import 'package:dartz/dartz.dart';
import 'package:spot_time/core/usecase/usecase.dart';

import '../../../../../core/errors/failures.dart';
import '../../repo/firebase_repository.dart';

class GetCurrentUid implements UseCase<String, NoParams> {
  final FirebaseRepository repository;

  GetCurrentUid(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.getCurrentUid();
  }
}
