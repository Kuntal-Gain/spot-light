import 'package:bloc/bloc.dart';
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';
import 'package:spot_time/feature/event/domain/usecases/events/create_poll_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/vote_poll_usecase.dart';
import 'poll_state.dart';

class PollCubit extends Cubit<PollState> {
  final CreateNewPoll createNewPollUsecase;
  final VotePollUsecase votePollUsecase;

  PollCubit({
    required this.createNewPollUsecase,
    required this.votePollUsecase,
  }) : super(PollInitial());

  /// Create a new poll
  Future<void> createPoll(PollEntity poll) async {
    emit(PollLoading());
    final result = await createNewPollUsecase.call(poll);

    result.fold(
      (failure) => emit(PollError(failure.toString())),
      (_) => emit(PollActionSuccess()),
    );
  }

  /// Vote in a poll
  Future<void> votePoll(
      {required String pollId, required String optionId}) async {
    emit(PollLoading());
    final params = VotePollParams(pollId: pollId, optionId: optionId);
    final result = await votePollUsecase.call(params);

    result.fold(
      (failure) => emit(PollError(failure.toString())),
      (_) => emit(PollActionSuccess()),
    );
  }

  /// Optional: You can implement fetching all polls for an event here
  /// using a repository stream if you want real-time updates
}
