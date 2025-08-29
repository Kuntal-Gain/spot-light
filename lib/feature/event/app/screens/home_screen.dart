import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/constants/app_color.dart';
import 'package:spot_time/core/utils/text_style.dart';
import 'package:spot_time/feature/event/app/cubit/event/event_cubit.dart';
import 'package:spot_time/feature/event/app/widgets/event_card.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/loading_indicators.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/cred/cred_cubit.dart';
import 'add_event_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserEntity user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventCubit>().getEvents();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: AppColors.primary,
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/banner.png', height: mq.height * 0.15),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // TODO: build drop down menu
                  },
                ),
              ],
            ),
            Center(
              child: Text(
                'Upcoming Events',
                style: headingStyle(
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
            ),
            BlocBuilder<EventCubit, EventState>(
              builder: (context, state) {
                print(state);
                if (state is EventLoading) {
                  return const LoadingIndicator();
                }
                if (state is EventError) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                if (state is EventsLoaded) {
                  final events = state.events;

                  return Expanded(
                      child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];

                      return eventCard(
                        event: event,
                        user: widget.user,
                        ctx: context,
                      );
                    },
                  ));
                }
                return const SizedBox();
              },
            )
          ],
        ),
        floatingActionButton: Container(
          height: mq.height * 0.08,
          width: mq.height * 0.08,
          decoration: BoxDecoration(
            color: AppColors.primary,
            border: Border.all(color: AppColors.secondary, width: 1.8),
            // borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary,
                spreadRadius: 3,
                offset: const Offset(9, 9),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: AppColors.secondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventScreen(user: widget.user),
                ),
              );
            },
          ),
        ));
  }
}
