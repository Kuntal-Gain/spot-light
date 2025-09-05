// The core screen for creating a new poll
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/constants/app_color.dart';
import 'package:spot_time/core/utils/debouncer.dart';
import 'package:spot_time/core/utils/generators.dart';
import 'package:spot_time/core/utils/snackbar.dart';
import 'package:spot_time/core/widgets/custom_button.dart';
import 'package:spot_time/feature/event/app/cubit/chat/chat_cubit.dart';
import 'package:spot_time/feature/event/app/cubit/poll/poll_cubit.dart';
import 'package:spot_time/feature/event/app/cubit/poll/poll_state.dart';
import 'package:spot_time/feature/event/domain/entities/chat_entity.dart';
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';

import '../../../../core/utils/text_style.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/user_entity.dart';

class AddPollScreen extends StatefulWidget {
  final EventEntity event;
  final UserEntity user;

  const AddPollScreen({super.key, required this.event, required this.user});

  @override
  State<AddPollScreen> createState() => _AddPollScreenState();
}

class _AddPollScreenState extends State<AddPollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  DateTime? _expiresAt;
  late Debouncer debouncer;

  @override
  void initState() {
    super.initState();
    debouncer = Debouncer(milliseconds: 1500);
    // Initialize with two option fields by default
    _optionControllers.add(TextEditingController());
    _optionControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    // Don't allow fewer than two options
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != _expiresAt) {
      setState(() {
        _expiresAt = pickedDate;
      });
    }
  }

  void _createPoll() {
    debouncer.run(() {
      if (_formKey.currentState!.validate()) {
        final question = _questionController.text;
        final options =
            _optionControllers.map((controller) => controller.text).toList();

        final validOptions = options.where((text) => text.isNotEmpty).toList();

        final poll = PollEntity(
          id: generatePollId(),
          eventId: widget.event.eventId,
          question: question,
          options: validOptions
              .asMap()
              .entries
              .map((option) => PollOptionEntity(
                    id: 'op${option.key}',
                    text: option.value,
                    votes: {},
                  ))
              .toList(),
          createdBy: widget.user.uid,
          createdAt: DateTime.now(),
          expiresAt: _expiresAt,
        );

        // send poll as a message
        context.read<ChatCubit>().sendMessage(
            message: MessageEntity(
              id: '',
              senderId: widget.user.uid,
              content: poll.question,
              type: 'poll',
              pollId: poll.id,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
            event: widget.event);

        // save poll to db
        context.read<PollCubit>().createPoll(poll);
      }
    });
  }

  Widget _buildTextField(
      TextEditingController controller, String label, Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary, width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        maxLines: null,
        controller: controller,
        style: bodyStyle(size: size.width * 0.03, color: AppColors.secondary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              bodyStyle(size: size.width * 0.03, color: AppColors.secondary),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a question.';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return BlocListener<PollCubit, PollState>(
      listener: (context, state) {
        if (state is PollLoading) {
          loadingBar(context, 'Creating poll...');
        }
        Navigator.of(context, rootNavigator: true).pop();
        if (state is PollError) {
          errorBar(context, 'Failed to create poll');
        }
        if (state is PollActionSuccess) {
          successBar(context, 'Poll created successfully');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Create Poll',
            style: bodyStyle(size: 19, color: AppColors.secondary),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_questionController, 'Poll Question', mq),
                const SizedBox(height: 24),
                Text(
                  'Poll Options',
                  style: bodyStyle(size: 19, color: AppColors.secondary),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _optionControllers.length,
                  itemBuilder: (context, index) {
                    // Use Dismissible for swipe-to-delete functionality
                    return Dismissible(
                      key: ValueKey(_optionControllers[index]
                          .hashCode), // Unique key for Dismissible
                      direction:
                          DismissDirection.endToStart, // Allow right swipe only
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        // Prevent removal if there are only two options left
                        if (_optionControllers.length <= 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'A poll must have at least two options.')),
                          );
                          return false;
                        }
                        // Show a confirmation dialog before deleting
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text(
                                  "Are you sure you want to delete this option?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        // Remove the option after a successful swipe
                        _removeOption(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Option ${index + 1} dismissed')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        // This is the item that will be swiped away
                        child: _buildTextField(
                          _optionControllers[index],
                          'Option ${index + 1}',
                          mq,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: AppColors.primary,
                    onPressed: () {
                      _addOption();
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Expiration Date',
                  style: bodyStyle(size: 19, color: AppColors.secondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _expiresAt == null
                            ? 'No expiration date selected'
                            : 'Expires: ${_expiresAt!.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.rectangle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        color: AppColors.primary,
                        onPressed: () {
                          _selectDate(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomButton1(
                  label: 'Create Poll',
                  onTap: _createPoll,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
