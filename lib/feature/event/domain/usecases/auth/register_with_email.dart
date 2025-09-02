// lib/features/auth/domain/usecases/register_with_email.dart
import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../repo/firebase_repository.dart';
import 'package:dartz/dartz.dart';

class RegisterWithEmail implements UseCase<void, RegisterParams> {
  final FirebaseRepository repository;

  RegisterWithEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return repository.registerWithEmail(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
