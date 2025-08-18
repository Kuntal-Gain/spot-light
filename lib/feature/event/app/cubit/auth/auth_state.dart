part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class NotAuthenticated extends AuthState {
  final String message;
  const NotAuthenticated({required this.message});

  @override
  List<Object> get props => [message];
}
