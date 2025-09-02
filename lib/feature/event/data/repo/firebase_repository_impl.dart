// lib/features/auth/data/repositories/appwrite_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:spot_time/core/errors/failures.dart';
import 'package:spot_time/feature/event/domain/entities/chat_entity.dart';
import 'package:spot_time/feature/event/domain/entities/event_entity.dart';
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';
import 'package:spot_time/feature/event/domain/repo/firebase_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../data_sources/remote_datasource.dart';

class FirebaseRepositoryImpl implements FirebaseRepository {
  final RemoteDataSource remoteDataSource;

  FirebaseRepositoryImpl({required this.remoteDataSource});

  // ---------------- AUTH ----------------
  @override
  Future<Either<Failure, void>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.loginWithEmail(email: email, password: password);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );
      return const Right(null);
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

  @override
  Future<Either<Failure, String>> getCurrentUid() async {
    try {
      final uid = await remoteDataSource.getCurrentUid();
      return Right(uid);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ---------------- EVENTS ----------------
  @override
  Future<Either<Failure, void>> addEvent(EventEntity event) async {
    try {
      await remoteDataSource.addEvent(event);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents() async {
    try {
      final events = await remoteDataSource.getEvents();
      return Right(events);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getSingleEvent(String eventId) async {
    try {
      final event = await remoteDataSource.getSingleEvent(eventId);
      return Right(event);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ---------------- CHAT ----------------
  @override
  Future<Either<Failure, Unit>> sendMessage({
    required EventEntity event,
    required MessageEntity message,
  }) async {
    try {
      await remoteDataSource.sendMessage(message, event);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> subscribeMessages(
      String eventId, String messageId) {
    try {
      return remoteDataSource.subscribeMessages(eventId, messageId).map(
            (messages) => Right(messages),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  // ---------------- POLLS ----------------
  @override
  Future<Either<Failure, Unit>> createNewPoll(
      {required PollEntity poll}) async {
    try {
      await remoteDataSource.createPoll(poll);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> votePoll({
    required String pollId,
    required String optionId,
  }) async {
    try {
      await remoteDataSource.votePoll(pollId: pollId, optionId: optionId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser({required UserEntity user}) async {
    try {
      await remoteDataSource.createUser(user: user);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserByUID(String uid) async {
    try {
      final user = await remoteDataSource.getUserByUID(uid);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
