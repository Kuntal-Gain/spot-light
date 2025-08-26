import 'package:dartz/dartz.dart';
import 'package:spot_time/core/errors/failures.dart';
import 'package:spot_time/core/usecase/usecase.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';
import 'package:spot_time/feature/event/domain/repo/firebase_repository.dart';

class CreateUserUseCase implements UseCase<void, UserEntity> {
  final FirebaseRepository repository;

  CreateUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UserEntity user) {
    return repository.createUser(user: user);
  }
}
