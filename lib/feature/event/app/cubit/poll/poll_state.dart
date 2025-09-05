import 'package:equatable/equatable.dart';
import '../../../domain/entities/poll_entity.dart';

abstract class PollState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PollInitial extends PollState {}

class PollLoading extends PollState {}

class PollLoaded extends PollState {
  final PollEntity poll;
  PollLoaded(this.poll);

  @override
  List<Object?> get props => [poll];
}

class PollUpdated extends PollState {
  final PollEntity poll;
  PollUpdated(this.poll);

  @override
  List<Object?> get props => [poll];
}

class PollError extends PollState {
  final String error;
  PollError(this.error);

  @override
  List<Object?> get props => [error];
}

class PollActionSuccess extends PollState {} // for vote or create success
