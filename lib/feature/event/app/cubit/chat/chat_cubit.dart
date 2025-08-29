import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_entity.dart';
import '../../../domain/usecases/events/fetch_messages_usecase.dart';
import '../../../domain/usecases/events/send_message_usecase.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FetchMessagesUsecase fetchMessagesUsecase;
  final SendMessage sendMessageUsecase;

  StreamSubscription? _messagesSub;

  ChatCubit({
    required this.fetchMessagesUsecase,
    required this.sendMessageUsecase,
  }) : super(ChatInitial());

  /// Fetch + listen to messages in real-time
  void fetchMessages({required String messageId}) {
    emit(ChatLoading());

    // Cancel any previous subscription to avoid leaks
    _messagesSub?.cancel();

    final result = fetchMessagesUsecase.call(messageId);

    _messagesSub = result.listen((either) {
      either.fold(
        (failure) => emit(ChatError(failure.toString())),
        (messages) => emit(ChatLoaded(messages)),
      );
    }, onError: (error) {
      emit(ChatError(error.toString()));
    });
  }

  /// Send message with optimistic update
  Future<void> sendMessage({
    required MessageEntity message,
    required String messageId,
  }) async {
    try {
      // Optimistic update
      if (state is ChatLoaded) {
        final current =
            List<MessageEntity>.from((state as ChatLoaded).messages);
        emit(ChatLoaded([...current, message]));
      }

      final result = await sendMessageUsecase.call(
        SendMessageParams(eventId: messageId, message: message),
      );

      result.fold(
        (failure) {
          emit(ChatError(failure.toString()));
        },
        (_) {
          // No need to emit — stream subscription handles updates
        },
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
