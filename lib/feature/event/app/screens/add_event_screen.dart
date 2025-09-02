import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/constants/app_color.dart';
import 'package:spot_time/core/utils/snackbar.dart';
import 'package:spot_time/core/widgets/custom_button.dart';
import 'package:spot_time/feature/event/app/cubit/event/event_cubit.dart';
import 'package:spot_time/feature/event/app/widgets/event_card.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';

import '../../../../core/utils/generators.dart';
import '../../../../core/utils/text_style.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/event_entity.dart';

class AddEventScreen extends StatefulWidget {
  final UserEntity user;
  const AddEventScreen({super.key, required this.user});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  int selectedType = 0;

  void createEvent() {
    if (formKey.currentState!.validate()) {
      context.read<EventCubit>().createEvent(
            event: EventEntity(
              eventId: '',
              name: nameController.text,
              description: descriptionController.text,
              type: eventTypeItems[selectedType].type,
              participants: [widget.user.uid],
              createdAt: Timestamp.now(),
              createdBy: widget.user.uid,
              messageId: generateMessageId(),
              coverImage: '',
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return BlocListener<EventCubit, EventState>(
      listener: (context, state) {
        if (state is EventLoading) {
          loadingBar(context, 'Creating Event...');
          return;
        }
        if (state is EventError) {
          debugPrint(state.message);
          errorBar(context, state.message);
        }
        if (state is EventCreated) {
          successBar(context, "Event Created Successfully");
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Add Event',
            style: headingStyle(color: AppColors.secondary, size: 16),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // circular avtar

                Center(
                  child: Container(
                    height: mq.height * 0.12,
                    width: mq.height * 0.12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.secondary, width: 1.8),
                      color: AppColors.primary,
                    ),
                    child: Center(
                      child: Text(
                        nameController.text.isNotEmpty
                            ? nameController.text.substring(0, 1)
                            : '?',
                        style:
                            headingStyle(color: AppColors.secondary, size: 22),
                      ),
                    ),
                  ),
                ),

                // event name
                Container(
                  height: mq.height * 0.07,
                  width: mq.width * 0.9,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondary, width: 1.8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    style: bodyStyle(color: AppColors.secondary, size: 15),
                    controller: nameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Event Name',
                      hintStyle: bodyStyle(color: Colors.grey, size: 12),
                    ),
                    validator: Validators.notEmpty,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),

                // event type

                Container(
                    height: mq.height * 0.07,
                    width: mq.width * 0.9,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.secondary, width: 1.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: DropdownButtonFormField(
                      dropdownColor: AppColors.primary,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Select Event Type',
                        hintStyle: bodyStyle(color: Colors.grey, size: 12),
                      ),
                      validator: Validators.notEmpty,
                      onChanged: (value) {
                        setState(() {});
                      },
                      items: eventTypeItems.map((e) {
                        return DropdownMenuItem(
                          value: e.type,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: eventWidget(
                                type: e,
                                size: Size(mq.width * 0.2, mq.height * 0.025)),
                          ),
                        );
                      }).toList(),
                      selectedItemBuilder: (ctx) {
                        return eventTypeItems.map((e) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type, // or your custom widget
                              style: bodyStyle(color: e.color, size: 14),
                            ),
                          );
                        }).toList();
                      },
                    )),

                // event description
                Container(
                  height: mq.height * 0.07,
                  width: mq.width * 0.9,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondary, width: 1.8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Event Description',
                      hintStyle: bodyStyle(color: Colors.grey, size: 12),
                    ),
                    validator: Validators.notEmpty,
                  ),
                ),

                // event add button
                CustomButton1(
                  label: "Create Event",
                  onTap: createEvent,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
