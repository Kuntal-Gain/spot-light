// lib/features/auth/domain/usecases/login_with_email.dart
import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repo/appwrite_repository.dart';
import 'package:dartz/dartz.dart';

class LoginWithEmail implements UseCase<UserEntity, LoginParams> {
  final AppwriteRepository repository;

  LoginWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.loginWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}
