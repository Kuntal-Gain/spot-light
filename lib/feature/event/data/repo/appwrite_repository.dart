// lib/features/auth/data/repositories/appwrite_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:spot_time/feature/event/domain/repo/appwrite_repository.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../data_sources/remote_datasource.dart';

class AppwriteRepositoryImpl implements AppwriteRepository {
  final RemoteDataSource remoteDataSource;

  AppwriteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(
      {required String email, required String password}) async {
    try {
      final user = await remoteDataSource.loginWithEmail(
          email: email, password: password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final user = await remoteDataSource.registerWithEmail(
          name: name, email: email, password: password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      final isLoggedIn = await remoteDataSource.isUserLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
