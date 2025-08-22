part of 'event_cubit.dart';

abstract class EventState extends Equatable {
  const EventState();
}

class EventInitial extends EventState {
  @override
  List<Object?> get props => [];
}

class EventLoading extends EventState {
  @override
  List<Object?> get props => [];
}

class EventCreated extends EventState {
  @override
  List<Object?> get props => [];
}

class EventsLoaded extends EventState {
  final List<EventEntity> events;
  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class SingleEventLoaded extends EventState {
  final EventEntity event;
  const SingleEventLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventError extends EventState {
  final String message;
  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}
