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
import '../models/poll_model.dart';
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
        pollId: message.pollId,
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
              pollId: msgMap['pollId'] ?? "",
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
    try {
      final pollRef = db.ref().child('polls').child(poll.id);
      final newPoll = PollModel(
        id: poll.id,
        eventId: poll.eventId,
        question: poll.question,
        options: poll.options,
        createdBy: poll.createdBy,
        createdAt: poll.createdAt,
        expiresAt: poll.expiresAt,
      ).toMap();

      return pollRef.set(newPoll).then((_) {
        printLog("info", "Poll created successfully");
      });
    } catch (e) {
      printLog("err", e.toString());
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> votePoll({
    required String pollId,
    required String optionId,
  }) async {
    final db = FirebaseDatabase.instance.ref();

    try {
      final uid = await getCurrentUid(); // ✅ fetch user inside
      printLog("info", "🔎 [DEBUG] Current UID => $uid");

      final pollRef = db.child("polls/$pollId/options");
      final snapshot = await pollRef.get();

      if (!snapshot.exists) {
        printLog("err", "⚠️ [DEBUG] Poll $pollId has no options");
        return;
      }

      final rawData = snapshot.value;
      printLog("info",
          "🔎 [DEBUG] snapshot.value.runtimeType => ${rawData.runtimeType}");
      printLog("info", "🔎 [DEBUG] snapshot.value => $rawData");

      // Case 1: options are stored as a Map ( { "op-1": {...}, "op-2": {...} } )
      if (rawData is Map) {
        printLog("info", "✅ [DEBUG] Detected Map structure for options");

        final options = Map<String, dynamic>.from(rawData);
        printLog("info", "🔎 [DEBUG] Parsed options => $options");

        // rebuild votes for each option
        options.updateAll((key, value) {
          final optMap = Map<String, dynamic>.from(value);
          final votes = Map<String, dynamic>.from(optMap['votes'] ?? {});
          printLog("info", "🔎 [DEBUG] Processing option $key => $optMap");
          printLog("info", "🔎 [DEBUG] Before votes => $votes");

          votes.remove(uid); // remove old vote
          if (optMap['id'] == optionId) {
            votes[uid] = true; // add new vote
          }

          printLog("info", "🔎 [DEBUG] After votes => $votes");

          return {
            ...optMap,
            'votes': votes,
          };
        });

        printLog("info", "✅ [DEBUG] Final updated options (Map) => $options");
        await pollRef.set(options);
      }

      // Case 2: options are stored as a List ([{id: op-1, ...}, {id: op-2, ...}])
      else if (rawData is List) {
        printLog("info", "✅ [DEBUG] Detected List structure for options");

        final options =
            rawData.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        printLog("info", "🔎 [DEBUG] Parsed options (List) => $options");

        final updatedOptions = options.map((optMap) {
          final votes = Map<String, dynamic>.from(optMap['votes'] ?? {});
          printLog("info",
              "🔎 [DEBUG] Processing option ${optMap['id']} => $optMap");
          printLog("info", "🔎 [DEBUG] Before votes => $votes");

          votes.remove(uid);
          if (optMap['id'] == optionId) {
            votes[uid] = true;
          }

          printLog("info", "🔎 [DEBUG] After votes => $votes");

          return {
            ...optMap,
            'votes': votes,
          };
        }).toList(); // ✅ force conversion from MappedListIterable to List

        printLog("info",
            "✅ [DEBUG] Final updated options (List) => $updatedOptions");
        await pollRef.set(updatedOptions);
      } else {
        throw Exception(
            "Unknown options structure in DB: ${rawData.runtimeType}");
      }
    } catch (e, st) {
      printLog("err", "❌ [DEBUG] Exception during votePoll: $e");
      printLog("err", "❌ [DEBUG] Stacktrace:\n$st");
      throw Exception("Failed to vote: $e");
    }
  }

  @override
  Future<PollEntity> getSinglePoll(String pollId) async {
    try {
      final snapshot = await db.ref().child("polls").child(pollId).get();

      if (!snapshot.exists) {
        throw Exception("Poll with id $pollId not found");
      }

      printLog("err",
          "🔎 [DEBUG] Raw snapshot.value for poll $pollId => ${snapshot.value.runtimeType}");
      printLog("err", "🔎 [DEBUG] snapshot.value content => ${snapshot.value}");

      // Convert snapshot.value (Map) -> PollModel -> PollEntity
      final pollModel = PollModel.fromSnapshot(snapshot);
      return pollModel;
    } catch (e, st) {
      printLog("err", "❌ [ERROR] getSinglePoll failed: $e");
      print("📌 [STACK] $st");
      throw Exception("Failed to fetch poll: $e");
    }
  }
}
