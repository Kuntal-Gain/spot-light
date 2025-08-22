import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/constants/app_color.dart';
import 'package:spot_time/core/utils/text_style.dart';
import 'package:spot_time/feature/event/app/widgets/event_card.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/cred/cred_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            Expanded(
                child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return eventCard(
                    event: EventEntity(
                      id: '123',
                      name: 'Feast',
                      type: 'feast',
                      participants: ['user-1', 'user-2'],
                      createdAt: DateTime.now(),
                      createdBy: 'user-1',
                      messageId: '123',
                      description: 'description',
                      coverImage: '',
                    ),
                    ctx: context);
              },
            ))
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
          child: const Icon(Icons.add, color: AppColors.secondary),
        ));
  }
}
