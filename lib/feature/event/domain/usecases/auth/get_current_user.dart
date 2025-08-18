// lib/features/auth/domain/usecases/get_current_user.dart
import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repo/appwrite_repository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUser implements UseCase<UserEntity?, NoParams> {
  final AppwriteRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
