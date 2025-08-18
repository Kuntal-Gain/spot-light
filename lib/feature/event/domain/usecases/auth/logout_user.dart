// lib/features/auth/domain/usecases/logout_user.dart
import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../repo/appwrite_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AppwriteRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
