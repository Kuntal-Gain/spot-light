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

  ChatCubit({
    required this.fetchMessagesUsecase,
    required this.sendMessageUsecase,
  }) : super(ChatInitial());

  void fetchMessages({required String messageId}) async {
    if (isClosed) return;

    try {
      emit(ChatLoading());

      final result = fetchMessagesUsecase.call(messageId);

      result.listen((either) {
        either.fold(
          (failure) => emit(ChatError(failure.toString())),
          (messages) => emit(ChatLoaded(messages)),
        );
      }).onError((error) {
        emit(ChatError(error.toString()));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage({
    required MessageEntity message,
    required String messageId,
  }) async {
    try {
      // Optimistic update (instant UI update before backend confirms)
      if (state is ChatLoaded) {
        final currentMessages =
            List<MessageEntity>.from((state as ChatLoaded).messages);
        emit(ChatLoaded([...currentMessages, message]));
      }

      final result = await sendMessageUsecase.call(
        SendMessageParams(eventId: messageId, message: message),
      );

      result.fold(
        (failure) {
          emit(ChatError(failure.toString()));
        },
        (_) {
          // Do nothing: the subscription will update messages in real-time
          // If you want, you can keep the optimistic update and skip emitting here
        },
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
