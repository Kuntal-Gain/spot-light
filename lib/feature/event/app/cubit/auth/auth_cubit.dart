import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spot_time/feature/event/domain/usecases/auth/get_current_user.dart';
import 'package:spot_time/feature/event/domain/usecases/auth/is_user_loggedin.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/user_entity.dart';
import '../cred/cred_cubit.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IsUserLoggedIn isUserLoggedIn;
  final GetCurrentUser getCurrentUser;
  AuthCubit({required this.isUserLoggedIn, required this.getCurrentUser})
      : super(AuthInitial());

  // appStarted
  Future<void> appStarted() async {
    emit(AuthLoading());

    try {
      final result = await isUserLoggedIn.call(NoParams());

      result.fold(
        (failure) => emit(NotAuthenticated(message: failure.message)),
        (isLoggedIn) async {
          if (isLoggedIn) {
            final userResult = await getCurrentUser.call(NoParams());

            userResult.fold(
              (failure) => emit(NotAuthenticated(message: failure.message)),
              (user) => emit(Authenticated(user: user!)),
            );
          } else {
            emit(const NotAuthenticated(message: 'User is not logged in'));
          }
        },
      );
    } catch (e) {
      emit(NotAuthenticated(message: e.toString()));
    }
  }
}
