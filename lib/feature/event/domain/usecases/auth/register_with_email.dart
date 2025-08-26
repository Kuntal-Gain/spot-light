// lib/features/auth/domain/usecases/register_with_email.dart
import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repo/firebase_repository.dart';
import 'package:dartz/dartz.dart';

class RegisterWithEmail implements UseCase<void, RegisterParams> {
  final FirebaseRepository repository;

  RegisterWithEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return repository.registerWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;

  RegisterParams({
    required this.email,
    required this.password,
  });
}
