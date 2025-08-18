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
  final UserEntity user;
  const CredSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class CredError extends CredState {
  final String message;
  const CredError({required this.message});

  @override
  List<Object> get props => [message];
}
