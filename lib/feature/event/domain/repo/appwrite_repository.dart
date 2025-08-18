// lib/features/auth/domain/repositories/appwrite_repository.dart
import '../entities/user_entity.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AppwriteRepository {
  // * credentials
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> isUserLoggedIn();
}
