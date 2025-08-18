import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';
import 'package:spot_time/feature/event/domain/usecases/auth/get_current_user.dart';
import 'package:spot_time/feature/event/domain/usecases/auth/login_with_email.dart';
import 'package:spot_time/feature/event/domain/usecases/auth/register_with_email.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/auth/logout_user.dart';

part 'cred_state.dart';

class CredCubit extends Cubit<CredState> {
  final GetCurrentUser getCurrentUser;
  final LoginWithEmail loginWithEmail;
  final RegisterWithEmail registerWithEmail;
  final LogoutUser logout;

  CredCubit({
    required this.getCurrentUser,
    required this.loginWithEmail,
    required this.registerWithEmail,
    required this.logout,
  }) : super(CredInitial());

  // login
  Future<void> login({required String email, required String password}) async {
    emit(CredLoading());

    try {
      final result = await loginWithEmail.call(
        LoginParams(email: email, password: password),
      );

      result.fold(
        (failure) => emit(CredError(message: failure.message)),
        (user) => emit(CredSuccess(user: user)),
      );
    } catch (e) {
      emit(CredError(message: e.toString()));
    }
  }

  // register

  Future<void> register(
      {required String name,
      required String email,
      required String password}) async {
    emit(CredLoading());

    try {
      final result = await registerWithEmail.call(
        RegisterParams(name: name, email: email, password: password),
      );

      result.fold(
        (failure) => emit(CredError(message: failure.message)),
        (user) => emit(CredSuccess(user: user)),
      );
    } catch (e) {
      emit(CredError(message: e.toString()));
    }
  }

  // current user

  Future<void> loadCurrentUser() async {
    emit(CredLoading());

    try {
      final result = await getCurrentUser.call(NoParams());

      result.fold(
        (failure) => emit(CredError(message: failure.message)),
        (user) => emit(CredSuccess(user: user!)),
      );
    } catch (e) {
      emit(CredError(message: e.toString()));
    }
  }

  // logout

  Future<void> logOut() async {
    await logout(NoParams());
    emit(CredInitial());
  }
}
