// lib/features/auth/data/datasources/remote_datasource_impl.dart
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spot_time/feature/event/data/models/event_model.dart';
import 'package:spot_time/feature/event/data/models/poll_model.dart';
import 'package:spot_time/feature/event/domain/entities/chat_entity.dart';
import 'package:spot_time/feature/event/domain/entities/event_entity.dart';
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'remote_datasource.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final Account account;
  final Databases database;
  final Realtime realtime;
  final FlutterSecureStorage storage;

  RemoteDataSourceImpl({
    required this.account,
    required this.database,
    required this.realtime,
    required this.storage,
  });

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // * Directly create a new session
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final doc = await database.getDocument(
        databaseId: AppStrings.databaseId,
        collectionId: AppStrings.userCollection,
        documentId: session.userId,
      );

      await storage.write(key: AppStrings.sessionId, value: session.$id);

      return UserModel.fromMap(doc.data);
    } on AppwriteException catch (e) {
      if (e.code == 401 && e.type == 'user_session_already_exists') {
        throw Exception("Session Already Exists");
      } else if (e.code == 401) {
        throw Exception("Invalid email or password");
      } else {
        throw Exception(e.message ?? "Something went wrong, please try again");
      }
    } catch (e) {
      // ! fallback
      rethrow;
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userAcc = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      await storage.write(key: AppStrings.sessionId, value: session.$id);

      final user = UserModel(
        id: userAcc.$id,
        name: name,
        email: email,
        avatar:
            'https://static.vecteezy.com/system/resources/previews/004/607/791/non_2x/man-face-emotive-icon-smiling-male-character-in-blue-shirt-flat-illustration-isolated-on-white-happy-human-psychological-portrait-positive-emotions-user-avatar-for-app-web-design-vector.jpg',
        events: const [],
        createdAt: userAcc.$createdAt,
      ).toMap();

      await database.createDocument(
        databaseId: AppStrings.databaseId,
        collectionId: AppStrings.userCollection,
        documentId: userAcc.$id,
        data: user,
      );

      return UserModel.fromMap(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = await account.get();

      final doc = await database.getDocument(
        databaseId: AppStrings.databaseId,
        collectionId: AppStrings.userCollection,
        documentId: user.$id,
      );

      return UserModel.fromMap(doc.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final sessionId = await storage.read(key: AppStrings.sessionId);

      if (sessionId != null) {
        await account.deleteSession(sessionId: sessionId);
        await storage.delete(key: AppStrings.sessionId);
      } else {
        await account.deleteSession(sessionId: 'current');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final sessionId = await storage.read(key: AppStrings.sessionId);
    return sessionId != null;
  }

  // * events
  @override
  Future<void> addEvent(EventEntity event) async {
    final newEvent = EventModel(
      id: event.id,
      name: event.name,
      type: event.type,
      participants: event.participants,
      createdBy: event.createdBy,
      messageId: event.messageId,
      createdAt: event.createdAt,
    ).toMap();

    final createdEvent = await database.createDocument(
      databaseId: AppStrings.databaseId,
      collectionId: AppStrings.eventCollection,
      documentId: event.id,
      data: newEvent,
    );
  }

  @override
  Future<List<EventEntity>> getEvents() async {
    final events = await database.listDocuments(
      databaseId: AppStrings.databaseId,
      collectionId: AppStrings.eventCollection,
    );

    return events.documents.map((e) => EventModel.fromMap(e.data)).toList();
  }

  @override
  Future<EventEntity> getSingleEvent(String eventId) async {
    final event = await database.getDocument(
      databaseId: AppStrings.databaseId,
      collectionId: AppStrings.eventCollection,
      documentId: eventId,
    );

    return EventModel.fromMap(event.data);
  }

  // * message module

  @override
  Future<void> sendMessage(MessageEntity message, String eventId) async {
    final messageModel = MessageModel(
      id: message.id,
      senderId: message.senderId,
      content: message.content,
      mediaUrl: message.mediaUrl,
      pollId: message.pollId,
      type: message.type,
      createdAt: message.createdAt,
    );

    final createdDoc = await database.createDocument(
      databaseId: AppStrings.databaseId,
      collectionId: AppStrings.messageCollection,
      documentId: 'unique()',
      data: {
        ...messageModel.toMap(),
        'eventId': eventId, // link message with event
      },
    );
  }

  @override
  Stream<List<MessageEntity>> subscribeMessages(String eventId) async* {
    final messagesCollection = database.listDocuments(
      databaseId: AppStrings.databaseId,
      collectionId: AppStrings.messageCollection,
      queries: [
        Query.equal('eventId', eventId),
        Query.orderDesc('\$createdAt'),
      ],
    );

    // Step 1: Yield initial messages (history)
    final snapshot = await messagesCollection;
    yield snapshot.documents
        .map((doc) => MessageModel.fromMap(doc.data))
        .toList();

    // Step 2: Listen for realtime updates
    yield* realtime
        .subscribe([
          'databases.${AppStrings.databaseId}.collections.${AppStrings.messageCollection}.documents'
        ])
        .stream
        .where((event) =>
            event.payload['eventId'] != null &&
            event.payload['eventId'] == eventId)
        .asyncMap((event) async {
          // Refetch the full updated list whenever something changes
          final updatedSnapshot = await database.listDocuments(
            databaseId: AppStrings.databaseId,
            collectionId: AppStrings.messageCollection,
            queries: [
              Query.equal('eventId', eventId),
              Query.orderDesc('\$createdAt'),
            ],
          );

          return updatedSnapshot.documents
              .map((doc) => MessageModel.fromMap(doc.data))
              .toList();
        });
  }

  // * poll module

  @override
  Future<void> createPoll(PollEntity poll) async {
    final newPoll = PollModel(
      id: poll.id,
      eventId: poll.eventId,
      createdBy: poll.createdBy,
      question: poll.question,
      options: poll.options,
      createdAt: poll.createdAt,
    ).toMap();

    await database.createDocument(
      databaseId: AppStrings.databaseId,
      collectionId: AppStrings.pollCollection,
      documentId: 'unique()',
      data: newPoll,
    );
  }

  @override
  Future<void> votePoll({
    required String pollId,
    required String optionId, // better pass optionId, not text
  }) async {
    final pollDoc = await database.getDocument(
      databaseId: AppStrings.databaseId,
      collectionId: AppStrings.pollCollection,
      documentId: pollId,
    );

    // Convert document data to PollModel
    final poll = PollModel.fromMap(pollDoc.data);

    // Get current userId
    final user = await account.get();
    final userId = user.$id;

    // Find the option and add vote
    final updatedOptions = poll.options.map((opt) {
      if (opt.id == optionId) {
        final votes = List<String>.from(opt.votes);
        if (!votes.contains(userId)) {
          votes.add(userId);
        }
        return PollOptionModel(id: opt.id, text: opt.text, votes: votes);
      }
      return opt;
    }).toList();

    // Update document in Appwrite
    await database.updateDocument(
      databaseId: AppStrings.databaseId,
      collectionId: AppStrings.pollCollection,
      documentId: pollId,
      data: {
        'options':
            updatedOptions.map((o) => (o as PollOptionModel).toMap()).toList(),
      },
    );
  }
}
