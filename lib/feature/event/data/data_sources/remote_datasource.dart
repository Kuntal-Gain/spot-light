// lib/features/auth/data/datasources/remote_datasource.dart
import '../models/user_model.dart';

abstract class RemoteDataSource {
  Future<UserModel> loginWithEmail(
      {required String email, required String password});
  Future<UserModel> registerWithEmail(
      {required String name, required String email, required String password});
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<bool> isUserLoggedIn();
}
