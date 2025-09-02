import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/constants/app_color.dart';
import 'package:spot_time/core/constants/app_strings.dart';
import 'package:spot_time/core/network/logger.dart';
import 'package:spot_time/core/utils/size_box.dart';
import 'package:spot_time/core/utils/time_formatter.dart';
import 'package:spot_time/core/widgets/loading_indicators.dart';
import 'package:spot_time/feature/event/data/models/user_model.dart';
import 'package:spot_time/feature/event/domain/entities/chat_entity.dart';
import 'package:spot_time/feature/event/domain/entities/event_entity.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';

import '../../../../core/utils/text_style.dart';
import '../cubit/chat/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  final String messageID;
  final EventEntity event;
  final UserEntity user;

  const ChatScreen({
    super.key,
    required this.messageID,
    required this.event,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // final DatabaseReference _messagesRef =
  //     FirebaseDatabase.instance.ref('events');

  StreamSubscription<DatabaseEvent>? _messageSub;

  Future<UserEntity?> fetchUser(String uid) async {
    // example: pull from Firestore/Realtime DB
    final snap = await FirebaseFirestore.instance
        .collection(AppStrings.userCollection)
        .doc(uid)
        .get();
    if (!snap.exists) return null;

    final data = snap.data()!;
    return UserModel.fromMap(data);
  }

  void sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      final uid = widget.user.uid;

      final newMessage = MessageEntity(
        id: '',
        senderId: uid,
        content: _controller.text.trim(),
        type: 'text',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // await _messagesRef.child(widget.messageID).child('messages').push().set({
      //   'senderId': newMessage.senderId,
      //   'content': newMessage.content,
      //   'type': newMessage.type,
      //   'createdAt': newMessage.createdAt,
      // });

      context
          .read<ChatCubit>()
          .sendMessage(message: newMessage, event: widget.event);

      _controller.clear();
    }
  }

  // ✅ Group messages by date
  Map<String, List<MessageEntity>> groupMessagesByDate(
      List<MessageEntity> messages) {
    Map<String, List<MessageEntity>> grouped = {};
    for (var msg in messages) {
      final dateKey = formatDate(msg.createdAt);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(msg);
    }
    return grouped;
  }

  @override
  void initState() {
    super.initState();

    printLog('info', widget.event.eventId);
    printLog('info', widget.messageID);
    context.read<ChatCubit>().fetchMessages(
        messageId: widget.messageID, eventId: widget.event.eventId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _messageSub?.cancel();
    super.dispose();
  }

// ✅ Main body widget
  Widget _bodyWidget(List<MessageEntity> messages) {
    final groupedMessages = groupMessagesByDate(messages);
    final dateKeys = groupedMessages.keys.toList();

    return ListView.builder(
      controller: _scrollController,
      itemCount: dateKeys.length,
      itemBuilder: (context, dateIndex) {
        final date = dateKeys[dateIndex];
        final dayMessages = groupedMessages[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Date separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Text(
                  date,
                  style: headingStyle(
                    size: 22,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),

            // 🔹 Messages under that date
            ...dayMessages.map((message) => _buildMessageItem(message)),
          ],
        );
      },
    );
  }

// ✅ Extracted message item (your old code refactored)
  Widget _buildMessageItem(MessageEntity message) {
    final isMe = message.senderId == widget.user.uid;

    if (message.senderId.toLowerCase() == 'server') {
      return Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey.shade300),
            child: Text(
              message.content,
              softWrap: true,
              maxLines: null,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                FutureBuilder(
                  future: fetchUser(message.senderId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final user = snapshot.data;
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.secondary, width: 1.8),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.secondary,
                          backgroundImage: (user!.avatar.isNotEmpty)
                              ? NetworkImage(user.avatar)
                              : null,
                          child: (user.avatar.isEmpty)
                              ? Text(
                                  (user.name.isNotEmpty)
                                      ? user.name[0].toUpperCase()
                                      : "?",
                                  style: headingStyle(
                                      color: AppColors.primary, size: 22),
                                )
                              : null,
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CupertinoActivityIndicator();
                    } else {
                      return sizeZ();
                    }
                  },
                ),

              // 🔹 Message bubble
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.secondary,
                  border: Border.all(color: AppColors.secondary, width: 1.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      softWrap: true,
                      maxLines: null,
                      style: bodyStyle(
                        color: isMe ? AppColors.secondary : AppColors.primary,
                        size: 15,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          color: isMe ? AppColors.secondary : AppColors.primary,
                          size: 18,
                        ),
                        sizeHor(5),
                        Text(
                          getTime(message.createdAt),
                          softWrap: true,
                          maxLines: null,
                          style: bodyStyle(
                            color:
                                isMe ? AppColors.secondary : AppColors.primary,
                            size: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (isMe)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 1.8),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    backgroundImage: (widget.user.avatar.isNotEmpty)
                        ? NetworkImage(widget.user.avatar)
                        : null,
                    child: (widget.user.avatar.isEmpty)
                        ? Text(
                            (widget.user.name.isNotEmpty)
                                ? widget.user.name[0].toUpperCase()
                                : "?",
                            style: headingStyle(
                                color: AppColors.secondary, size: 22),
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        backgroundColor: AppColors.primary,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary, width: 1.8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.5, top: 2),
                  child: Text(
                    widget.event.name.substring(0, 1),
                    style: headingStyle(
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.event.name,
                    style: headingStyle(size: 18, color: AppColors.secondary)),
                sizeVar(5),
                Text('${widget.event.participants.length} members',
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const LoadingIndicator();
                }
                if (state is ChatError) {
                  return Center(child: Text(state.message));
                }
                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(child: Text("No messages yet."));
                  }

                  return _bodyWidget(state.messages);
                }
                return const SizedBox();
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // attach media
                  Transform.rotate(
                    angle: pi / 4.5,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        border:
                            Border.all(color: AppColors.primary, width: 1.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.attach_file,
                          color: AppColors.primary),
                    ),
                  ),

                  sizeHor(5),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.secondary, width: 2),
                      ),
                      child: TextField(
                        style: bodyStyle(
                          color: AppColors.secondary,
                          size: 15,
                        ),
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                        ),
                      ),
                    ),
                  ),

                  sizeHor(5),

                  Transform.rotate(
                    angle: -pi / 4.5,
                    child: GestureDetector(
                      onTap: sendMessage,
                      child: Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          border:
                              Border.all(color: AppColors.primary, width: 1.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: FloatingActionButton(
          backgroundColor: AppColors.secondary,
          onPressed: () {
            // TODO : poll functionality
          },
          child: const Icon(Icons.poll, color: AppColors.primary),
        ),
      ),
    );
  }
}
