// lib/features/auth/data/datasources/remote_datasource_impl.dart
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/user_model.dart';
import 'remote_datasource.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final Account account;
  final Databases database;
  final FlutterSecureStorage storage;

  RemoteDataSourceImpl({
    required this.account,
    required this.database,
    required this.storage,
  });

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint("[RemoteDataSourceImpl] loginWithEmail() → email=$email");
    try {
      // * Directly create a new session
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      debugPrint(
          "[RemoteDataSourceImpl] Session created: id=${session.$id}, userId=${session.userId}");

      final doc = await database.getDocument(
        databaseId: AppStrings.databaseId,
        collectionId: AppStrings.userCollection,
        documentId: session.userId,
      );
      debugPrint("[RemoteDataSourceImpl] User document fetched: ${doc.data}");

      await storage.write(key: AppStrings.sessionId, value: session.$id);
      debugPrint("[RemoteDataSourceImpl] Session ID stored in secure storage");

      return UserModel.fromMap(doc.data);
    } catch (e, st) {
      debugPrint("[RemoteDataSourceImpl][ERROR] loginWithEmail failed → $e");
      debugPrint("[STACKTRACE] $st");
      rethrow;
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    debugPrint(
        "[RemoteDataSourceImpl] registerWithEmail() → email=$email, name=$name");
    try {
      final userAcc = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      debugPrint(
          "[RemoteDataSourceImpl] User account created: id=${userAcc.$id}");

      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      debugPrint("[RemoteDataSourceImpl] Session created: id=${session.$id}");

      await storage.write(key: AppStrings.sessionId, value: session.$id);
      debugPrint("[RemoteDataSourceImpl] Session ID stored in secure storage");

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

      debugPrint("[RemoteDataSourceImpl] User model mapped: $user");

      return UserModel.fromMap(user);
    } catch (e, st) {
      debugPrint("[RemoteDataSourceImpl][ERROR] registerWithEmail failed → $e");
      debugPrint("[STACKTRACE] $st");
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    debugPrint("[RemoteDataSourceImpl] getCurrentUser() called");
    try {
      final user = await account.get();
      debugPrint(
          "[RemoteDataSourceImpl] Account fetched: id=${user.$id}, email=${user.email}");

      final doc = await database.getDocument(
        databaseId: AppStrings.databaseId,
        collectionId: AppStrings.userCollection,
        documentId: user.$id,
      );
      debugPrint("[RemoteDataSourceImpl] User document fetched: ${doc.data}");

      return UserModel.fromMap(doc.data);
    } catch (e, st) {
      debugPrint("[RemoteDataSourceImpl][ERROR] getCurrentUser failed → $e");
      debugPrint("[STACKTRACE] $st");
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    debugPrint("[RemoteDataSourceImpl] logout() called");
    try {
      final sessionId = await storage.read(key: AppStrings.sessionId);
      debugPrint("[RemoteDataSourceImpl] Stored sessionId=$sessionId");

      if (sessionId != null) {
        await account.deleteSession(sessionId: sessionId);
        await storage.delete(key: AppStrings.sessionId);
        debugPrint("[RemoteDataSourceImpl] Session deleted (id=$sessionId)");
      } else {
        await account.deleteSession(sessionId: 'current');
        debugPrint("[RemoteDataSourceImpl] Fallback → current session deleted");
      }
    } catch (e, st) {
      debugPrint("[RemoteDataSourceImpl][ERROR] logout failed → $e");
      debugPrint("[STACKTRACE] $st");
      rethrow;
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    debugPrint("[RemoteDataSourceImpl] isUserLoggedIn() called");
    final sessionId = await storage.read(key: AppStrings.sessionId);
    debugPrint("[RemoteDataSourceImpl] Stored sessionId=$sessionId");
    return sessionId != null;
  }
}
