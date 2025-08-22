import 'package:equatable/equatable.dart';
import '../../../domain/entities/poll_entity.dart';

abstract class PollState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PollInitial extends PollState {}

class PollLoading extends PollState {}

class PollLoaded extends PollState {
  final List<PollEntity> polls;
  PollLoaded(this.polls);

  @override
  List<Object?> get props => [polls];
}

class PollError extends PollState {
  final String error;
  PollError(this.error);

  @override
  List<Object?> get props => [error];
}

class PollActionSuccess extends PollState {} // for vote or create success
