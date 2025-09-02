// lib/features/auth/domain/repositories/appwrite_repository.dart
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';

import '../entities/chat_entity.dart';
import '../entities/event_entity.dart';
import '../entities/user_entity.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class FirebaseRepository {
  // * credentials
  Future<Either<Failure, void>> loginWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> createUser({
    required UserEntity user,
  });
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, UserEntity?>> getUserByUID(String uid);
  Future<Either<Failure, String>> getCurrentUid();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isUserLoggedIn();

  // * events

  Future<Either<Failure, void>> addEvent(EventEntity event);
  Future<Either<Failure, List<EventEntity>>> getEvents();
  Future<Either<Failure, EventEntity>> getSingleEvent(String eventId);

  // * chat
  Future<Either<Failure, Unit>> sendMessage({
    required EventEntity event,
    required MessageEntity message,
  });
  Stream<Either<Failure, List<MessageEntity>>> subscribeMessages(
      String eventId, String messageId);
  Future<Either<Failure, Unit>> createNewPoll({
    required PollEntity poll,
  });

  // * poll
  Future<Either<Failure, Unit>> votePoll({
    required String pollId,
    required String optionId,
  });
}
