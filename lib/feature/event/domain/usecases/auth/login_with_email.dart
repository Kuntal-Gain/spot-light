// lib/features/auth/domain/usecases/login_with_email.dart
import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../repo/firebase_repository.dart';
import 'package:dartz/dartz.dart';

class LoginWithEmail implements UseCase<void, LoginParams> {
  final FirebaseRepository repository;

  LoginWithEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(LoginParams params) {
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
