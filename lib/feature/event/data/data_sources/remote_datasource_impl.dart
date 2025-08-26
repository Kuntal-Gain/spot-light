// lib/features/auth/data/datasources/remote_datasource_impl.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spot_time/core/errors/failures.dart';
import 'package:spot_time/feature/event/data/models/event_model.dart';
import 'package:spot_time/feature/event/data/models/poll_model.dart';
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
      {required String email, required String password}) async {
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
              name: '',
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
      final uid = await getCurrentUid();

      // Create a new empty doc → Firestore generates a unique ID
      final docRef = eventCollection.doc();

      // Generate a unique messageId for RTDB
      final msgId = generateMessageId();

      final newEvent = EventModel(
        eventId: docRef.id, // Firestore generated ID
        name: event.name,
        type: event.type,
        participants: [uid],
        createdBy: uid,
        messageId: msgId,
        description: event.description,
        createdAt: event.createdAt,
        lastMessage: 'Start Discussion',
      ).toMap();

      // Save the event in Firestore
      await docRef.set(newEvent);

      // 🔥 Create the root node for messages in RTDB
      final dbRef = db.ref().child('events').child(msgId);
      await dbRef.set({
        'messages': {}, // initialize empty messages node
        'createdBy': uid,
        'createdAt': ServerValue.timestamp,
      });
    } catch (e) {
      printLog("err", e.toString());
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
  Future<void> sendMessage(MessageEntity message, String eventId) async {
    try {
      // Realtime DB ref
      final dbRef = db
          .ref()
          .child('events')
          .child(eventId)
          .child('messages')
          .push(); // push() auto-generates unique msg id

      final msgData = MessageModel(
        id: dbRef.key!,
        senderId: message.senderId,
        content: message.content,
        type: message.type,
        createdAt: message.createdAt,
      ).toMap();

      // Save message in Realtime Database
      await dbRef.set(msgData);

      // Update Firestore with last message
      final chatRef =
          firestore.collection(AppStrings.eventCollection).doc(eventId);
      await chatRef.update({
        'lastMessage': message.content,
      });
    } catch (e) {
      printLog("err", "Error sending message: $e");
      throw ServerFailure(e.toString());
    }
  }

  @override
  Stream<List<MessageEntity>> subscribeMessages(String messageId) {
    final dbRef = db.ref().child('events').child(messageId).child('messages');
    final chatRef =
        firestore.collection(AppStrings.eventCollection).doc(messageId);

    return dbRef.onValue.asyncMap((event) async {
      try {
        // If no messages exist yet
        if (event.snapshot.value == null) {
          return <MessageEntity>[];
        }

        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

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
          } catch (e) {
            printLog("warn", "Skipping corrupted message: $e");
          }
        }

        // Sort messages by createdAt
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // Update last message in Firestore (safe check)
        if (messages.isNotEmpty) {
          final lastMessage = messages.last;
          await chatRef
              .update({'lastMessage': lastMessage.content}).catchError((e) {
            printLog("warn", "Failed to update lastMessage: $e");
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
