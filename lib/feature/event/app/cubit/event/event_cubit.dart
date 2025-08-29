import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spot_time/core/usecase/usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/add_event_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/get_single_event_usecase.dart';

import '../../../domain/entities/event_entity.dart';
import '../../../domain/usecases/events/get_events_usecase.dart';

part 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final AddEvent addEventUseCase;
  final GetEvents getEventsUseCase;
  final GetSingleEvent getSingleEventUseCase;

  EventCubit({
    required this.addEventUseCase,
    required this.getEventsUseCase,
    required this.getSingleEventUseCase,
  }) : super(EventInitial());

  Future<void> createEvent({required EventEntity event}) async {
    emit(EventLoading());
    print("[Cubit] createEvent called with: ${event.toString()}");

    try {
      final result = await addEventUseCase.call(event);

      result.fold(
        (failure) {
          print("[Cubit] Failed: ${failure.message}");
          emit(EventError(failure.message));
        },
        (_) {
          print("[Cubit] Success: Event created with ID -> ${event.eventId}");
          emit(EventCreated());
        },
      );
    } catch (e) {
      print("[Cubit] Exception: $e");
      emit(EventError(e.toString()));
    }
  }

  Future<void> getEvents() async {
    emit(EventLoading());

    try {
      final result = await getEventsUseCase.call(NoParams());

      result.fold(
        (failure) => emit(EventError(failure.message)),
        (events) => emit(EventsLoaded(events)),
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> getSingleEvent({required String eventId}) async {
    emit(EventLoading());

    try {
      final result = await getSingleEventUseCase.call(eventId);

      result.fold(
        (failure) => emit(EventError(failure.message)),
        (event) => emit(SingleEventLoaded(event)),
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
