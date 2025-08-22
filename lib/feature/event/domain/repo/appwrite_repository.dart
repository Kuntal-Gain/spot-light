// lib/features/auth/domain/repositories/appwrite_repository.dart
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';

import '../entities/chat_entity.dart';
import '../entities/event_entity.dart';
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

  // * events

  Future<Either<Failure, void>> addEvent(EventEntity event);
  Future<Either<Failure, List<EventEntity>>> getEvents();
  Future<Either<Failure, EventEntity>> getSingleEvent(String eventId);
  Future<Either<Failure, Unit>> sendMessage({
    required String eventId,
    required MessageEntity message,
  });
  Stream<Either<Failure, List<MessageEntity>>> subscribeMessages(
      String eventId);
  Future<Either<Failure, Unit>> createNewPoll({
    required PollEntity poll,
  });
  Future<Either<Failure, Unit>> votePoll({
    required String pollId,
    required String optionId,
  });
}
