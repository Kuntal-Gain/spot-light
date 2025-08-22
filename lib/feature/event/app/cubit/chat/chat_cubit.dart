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

  Future<void> sendMessage({
    required MessageEntity message,
    required String eventId,
  }) async {
    try {
      await sendMessageUsecase.call(
        SendMessageParams(message: message, eventId: eventId),
      );

      if (state is ChatLoaded) {
        final updatedMessages =
            List<MessageEntity>.from((state as ChatLoaded).messages)
              ..insert(0, message);
        emit(ChatLoaded(updatedMessages));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void subscribeToMessages(String eventId) {
    emit(ChatLoading());

    _messagesSub?.cancel(); // cleanup old subscription

    _messagesSub = fetchMessagesUsecase.call(eventId).listen((res) {
      res.fold(
        (failure) => emit(ChatError(failure.toString())),
        (messages) => emit(ChatLoaded(messages)),
      );
    });
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel(); // prevent leaks
    return super.close();
  }
}
