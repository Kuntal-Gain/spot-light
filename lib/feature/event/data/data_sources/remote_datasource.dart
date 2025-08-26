// lib/features/auth/data/datasources/remote_datasource.dart

import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';

import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/event_entity.dart';

abstract class RemoteDataSource {
  Future<void> loginWithEmail(
      {required String email, required String password});
  Future<void> registerWithEmail(
      {required String email, required String password});
  Future<UserEntity> getCurrentUser();
  Future<String> getCurrentUid();
  Future<void> logout();
  Future<bool> isUserLoggedIn();
  Future<void> createUser({required UserEntity user});

  // * events
  Future<void> addEvent(EventEntity event);
  Future<List<EventEntity>> getEvents();
  Future<EventEntity> getSingleEvent(String eventId);

  // * messages
  Future<void> sendMessage(MessageEntity message, String eventId);
  Stream<List<MessageEntity>> subscribeMessages(String eventId);

  // * polls
  Future<void> createPoll(PollEntity poll);
  Future<void> votePoll({required String pollId, required String optionId});
}
