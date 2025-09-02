// lib/features/auth/data/datasources/remote_datasource_impl.dart
import 'package:spot_time/core/errors/failures.dart';
import 'package:spot_time/feature/event/data/models/event_model.dart';
import 'package:spot_time/feature/event/domain/entities/chat_entity.dart';
import 'package:spot_time/feature/event/domain/entities/event_entity.dart';
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/logger.dart';
import '../../../../core/utils/generators.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseDatabase db;

  RemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
    required this.db,
  });

  // ---------------- AUTH ----------------
  @override
  Future<String> getCurrentUid() async => auth.currentUser!.uid;

  @override
  Future<UserEntity> getCurrentUser() async => UserModel.fromMap(
      (await firestore.collection('users').doc(auth.currentUser!.uid).get())
          .data()!);

  @override
  Future<UserEntity?> getUserByUID(String uid) {
    final userDoc =
        firestore.collection(AppStrings.userCollection).doc(uid).get();

    return userDoc.then((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      } else {
        return null;
      }
    });
  }

  @override
  Future<bool> isUserLoggedIn() async => auth.currentUser!.uid != null;

  @override
  Future<void> loginWithEmail(
      {required String email, required String password}) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ServerFailure('Email and password are required');
      }

      await auth.signInWithEmailAndPassword(email: email, password: password);
      printLog("info", "User logged in successfully");
    } on FirebaseAuthException catch (e) {
      printLog("err", e.message!);
      throw ServerFailure(e.message!);
    } catch (e) {
      printLog("err", e.toString());
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await auth.signOut();
      printLog("info", "User logged out successfully");
    } catch (e) {
      printLog("err", e.toString());
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> registerWithEmail(
      {required String name,
      required String email,
      required String password}) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ServerFailure('Email and password are required');
      }

      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        if (value.user?.uid != null) {
          createUser(
            user: UserEntity(
              uid: value.user!.uid,
              name: name,
              email: email,
              avatar: '',
              events: const [],
              createdAt: Timestamp.now(),
            ),
          );
          printLog("info", "User registered successfully");
        }
      }).catchError((e) {
        printLog("err", e.toString());
        throw ServerFailure(e.toString());
      });
    } on FirebaseAuthException catch (e) {
      printLog("err", e.message!);
      throw ServerFailure(e.message!);
    } catch (e) {
      printLog("err", e.toString());
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> createUser({required UserEntity user}) async {
    final userCollection = firestore.collection(AppStrings.userCollection);

    final uid = await getCurrentUid();

    await userCollection.doc(uid).get().then((doc) {
      final newUser = UserModel(
        uid: uid,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
        events: user.events,
        createdAt: Timestamp.now(),
      ).toMap();

      if (!doc.exists) {
        userCollection.doc(uid).set(newUser);
      } else {
        userCollection.doc(uid).update(newUser);
      }
    }).catchError((e) {
      printLog("err", e.toString());
      throw ServerFailure(e.toString());
    });
  }

  // ---------------- EVENTS ----------------

  @override
  Future<void> addEvent(EventEntity event) async {
    final eventCollection = firestore.collection(AppStrings.eventCollection);

    try {
      printLog("debug", "Getting current UID...");
      final uid = await getCurrentUid();
      printLog("debug", "Got UID: $uid");

      // Create Firestore doc reference
      final docRef = eventCollection.doc();
      final eventId = docRef.id;
      final messageId = generateMessageId();

      printLog(
          "debug", "Generated IDs -> eventId: $eventId, messageId: $messageId");

      final newEvent = EventModel(
        eventId: eventId,
        name: event.name,
        type: event.type,
        participants: [uid],
        createdBy: uid,
        messageId: messageId,
        description: event.description,
        createdAt: Timestamp.now(),
      ).toMap();

      printLog("debug", "Prepared newEvent map: $newEvent");

      // Step 1: Save event in Firestore
      printLog("debug", "Saving event in Firestore...");
      await docRef.set(newEvent);
      printLog("debug", "Event saved in Firestore ✅");

      // Step 2: Save in Realtime DB
      printLog("debug", "Saving event in Realtime Database...");

      final initMessage = {
        'senderId': 'server',
        'content': 'Event created',
        'mediaUrl': '',
        'pollId': '',
        'type': 'text',
        'createdAt': ServerValue.timestamp,
      };

      await db.ref().child('events').child(messageId).set({
        'messages': {
          'init': initMessage, // ✅ structured properly, no more corrupted map
        },
        'participants': {
          uid: true, // ✅ store as map for faster lookups
        },
        'createdBy': uid,
        'createdAt': ServerValue.timestamp,
      });

      printLog("debug", "Event saved in Realtime DB ✅");
    } catch (e, stack) {
      printLog("err", "Error in addEvent: $e");
      printLog("err", "Stacktrace: $stack");
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<EventEntity>> getEvents() {
    final eventCollection = firestore.collection(AppStrings.eventCollection);

    return eventCollection.get().then((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return EventModel.fromSnapshot(doc);
      }).toList();
    });
  }

  @override
  Future<EventEntity> getSingleEvent(String eventId) {
    final eventCollection = firestore.collection(AppStrings.eventCollection);

    return eventCollection.doc(eventId).get().then((doc) {
      return EventModel.fromSnapshot(doc);
    });
  }

  // ---------------- CHAT ----------------

  @override
  Future<void> sendMessage(MessageEntity message, EventEntity event) async {
    try {
      printLog("info", "➡️ Sending message | eventId: ${event.eventId}");

      // Realtime DB ref (chat thread)
      final dbRef = db
          .ref()
          .child('events')
          .child(event.messageId)
          .child('messages')
          .push();
      printLog("info", "RTDB path: ${dbRef.path}");

      final msgData = MessageModel(
        id: dbRef.key!,
        senderId: message.senderId,
        content: message.content,
        type: message.type,
        createdAt: message.createdAt,
      ).toMap();

      printLog("info", "Prepared msgData: $msgData");

      // Save message in Realtime Database
      await dbRef.set(msgData);
      printLog("info", "✅ Message saved in RTDB key: ${dbRef.key}");

      // Update Firestore event with last message
      final chatRef =
          firestore.collection(AppStrings.eventCollection).doc(event.eventId);

      await chatRef.update({
        'lastMessage': message.content,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      printLog("info", "✅ Firestore event updated with lastMessage");
    } catch (e) {
      printLog("err", "Error sending message: $e");
      throw ServerFailure(e.toString());
    }
  }

  @override
  Stream<List<MessageEntity>> subscribeMessages(
      String eventId, String messageId) {
    printLog("info",
        "📡 Subscribing messages | eventId: $eventId | messageId: $messageId");

    final dbRef = db.ref().child('events').child(messageId).child('messages');
    final chatRef =
        firestore.collection(AppStrings.eventCollection).doc(eventId);

    return dbRef.onValue.asyncMap((event) async {
      try {
        final raw = event.snapshot.value;
        printLog("info", "Snapshot value: $raw");

        if (raw == null || raw is! Map) {
          printLog("warn", "⚠️ No messages found yet");
          return <MessageEntity>[];
        }

        final data = Map<String, dynamic>.from(raw as Map);
        printLog("info", "Parsed ${data.length} messages");

        final List<MessageModel> messages = [];

        for (var entry in data.entries) {
          try {
            final msgMap = Map<String, dynamic>.from(entry.value);
            final message = MessageModel(
              id: entry.key,
              senderId: msgMap['senderId'] ?? "",
              content: msgMap['content'] ?? "",
              type: msgMap['type'] ?? "text",
              createdAt:
                  msgMap['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
            );
            messages.add(message);
            printLog("info", "Message parsed: ${message.toMap()}");
          } catch (e) {
            printLog("warn", "⚠️ Skipping corrupted message: $e");
          }
        }

        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        printLog("info", "Messages sorted. Total: ${messages.length}");

        if (messages.isNotEmpty) {
          final lastMessage = messages.last;
          printLog("info", "Updating lastMessage: ${lastMessage.content}");

          await chatRef.set(
            {'lastMessage': lastMessage.content},
            SetOptions(merge: true),
          ).catchError((e) {
            printLog("warn", "⚠️ Failed to update lastMessage: $e");
          });
        }

        return messages;
      } catch (e) {
        printLog("err", "Error in subscribeMessages: $e");
        return <MessageEntity>[];
      }
    });
  }

  // ---------------- POLL ----------------

  @override
  Future<void> createPoll(PollEntity poll) {
    // TODO: implement createPoll
    throw UnimplementedError();
  }

  @override
  Future<void> votePoll({required String pollId, required String optionId}) {
    // TODO: implement votePoll
    throw UnimplementedError();
  }
}
