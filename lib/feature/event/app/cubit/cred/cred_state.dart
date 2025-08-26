part of 'cred_cubit.dart';

abstract class CredState extends Equatable {
  const CredState();
}

class CredInitial extends CredState {
  @override
  List<Object> get props => [];
}

class CredLoading extends CredState {
  @override
  List<Object> get props => [];
}

class CredSuccess extends CredState {
  final String uid;
  const CredSuccess({required this.uid});

  @override
  List<Object> get props => [uid];
}

class CredError extends CredState {
  final String message;
  const CredError({required this.message});

  @override
  List<Object> get props => [message];
}

class UserLoaded extends CredState {
  final UserEntity user;
  const UserLoaded({required this.user});

  @override
  List<Object> get props => [user];
}
