import 'package:dartz/dartz.dart';
import 'package:spot_time/core/usecase/usecase.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';
import 'package:spot_time/feature/event/domain/repo/firebase_repository.dart';

import '../../../../../core/errors/failures.dart';

class GetUserUseCase implements UseCase<UserEntity?, String> {
  final FirebaseRepository repository;

  GetUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(String uid) async {
    return repository.getUserByUID(uid);
  }
}
