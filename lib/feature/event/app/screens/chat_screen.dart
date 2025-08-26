import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/widgets/loading_indicators.dart';

import '../cubit/chat/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  final String eventId;
  const ChatScreen({super.key, required this.eventId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().fetchMessages(messageId: widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const LoadingIndicator();
          }
          if (state is ChatError) {
            return Center(
              child: Text(state.message),
            );
          }
          if (state is ChatLoaded) {
            return ListView.builder(
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return ListTile(
                  title: Text(message.content),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
