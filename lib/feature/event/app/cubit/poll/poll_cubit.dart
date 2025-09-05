import 'package:bloc/bloc.dart';
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';
import 'package:spot_time/feature/event/domain/usecases/poll/create_poll_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/poll/vote_poll_usecase.dart';
import '../../../domain/usecases/poll/get_single_poll_usecase.dart';
import 'poll_state.dart';

class PollCubit extends Cubit<PollState> {
  final CreateNewPoll createNewPollUsecase;
  final VotePollUsecase votePollUsecase;
  final GetSinglePoll getSinglePollUsecase;

  PollCubit({
    required this.createNewPollUsecase,
    required this.votePollUsecase,
    required this.getSinglePollUsecase,
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

  // Vote in a poll
  Future<void> votePoll({
    required String pollId,
    required String optionId,
  }) async {
    emit(PollLoading());

    final params = VotePollParams(pollId: pollId, optionId: optionId);
    final result = await votePollUsecase.call(params);

    result.fold(
      (failure) => emit(PollError(failure.toString())),
      (_) {
        // ✅ Optimistic update of local poll state
        if (state is PollLoaded) {
          final currentPoll = (state as PollLoaded).poll;

          final updatedOptions = currentPoll.options.map((opt) {
            final newVotes = Map<String, dynamic>.from(opt.votes);

            // remove old vote
            newVotes.removeWhere((uid, _) =>
                uid ==
                "currentUserUid"); // <-- replace later with getCurrentUid()

            // add new vote
            if (opt.id == optionId) {
              newVotes["currentUserUid"] = true;
            }

            return PollOptionEntity(
              id: opt.id,
              text: opt.text,
              votes: newVotes,
            );
          }).toList();

          final updatedPoll = PollEntity(
            id: currentPoll.id,
            eventId: currentPoll.eventId,
            question: currentPoll.question,
            options: updatedOptions,
            createdBy: currentPoll.createdBy,
            createdAt: currentPoll.createdAt,
            expiresAt: currentPoll.expiresAt,
          );

          emit(PollUpdated(updatedPoll)); // ✅ UI gets updated poll instantly
        } else {
          emit(PollActionSuccess()); // fallback
        }
      },
    );
  }

  Future<void> getSinglePoll(String pollId) async {
    emit(PollLoading());
    final result = await getSinglePollUsecase.call(pollId);

    result.fold(
      (failure) => emit(PollError(failure.toString())),
      (poll) => emit(PollLoaded(poll)),
    );
  }

  /// Optional: You can implement fetching all polls for an event here
  /// using a repository stream if you want real-time updates
}
