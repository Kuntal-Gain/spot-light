import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/network/logger.dart';
import 'package:spot_time/feature/event/domain/entities/poll_entity.dart';
import 'package:spot_time/feature/event/domain/entities/user_entity.dart';

import '../../../../core/constants/app_color.dart';
import '../../../../core/utils/text_style.dart';
import '../cubit/poll/poll_cubit.dart';

Widget pollCard({
  required PollEntity poll,
  required UserEntity user,
  required BuildContext context,
}) {
  int votedIdx =
      poll.options.indexWhere((option) => option.votes[user.uid] == true);

  void votePoll(String id) => BlocProvider.of<PollCubit>(context)
      .votePoll(pollId: poll.id, optionId: id);

  return ConstrainedBox(
    constraints: const BoxConstraints(
      maxHeight: 300, // ✅ poll bubble never exceeds this height
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          poll.question,
          style: headingStyle(size: 16, color: Colors.black),
        ),
        const SizedBox(height: 8),

        // ✅ if many options → scroll, else → just show
        if (poll.options.length > 4)
          Expanded(
            // <-- gives scroll view a height
            child: SingleChildScrollView(
              child: Column(
                children: poll.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            printLog("info", " voted for ${option.text}");
                          },
                          child: Container(
                            height: 24,
                            width: 24,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.secondary),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            option.text,
                            style: headingStyle(
                                size: 13, color: AppColors.secondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // const SizedBox(width: 6),
                        // Text(
                        //   "${option.votes.length}",
                        //   style: bodyStyle(
                        //     size: 12,
                        //     color: AppColors.secondary.withOpacity(0.7),
                        //   ),
                        // ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        else
          Column(
            children: poll.options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        printLog("info", " voted for ${option.text}");
                        votePoll(option.id);
                      },
                      child: Container(
                          height: 30,
                          width: 30,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.secondary),
                          ),
                          child: Icon(
                            votedIdx == poll.options.indexOf(option)
                                ? Icons.check_circle_sharp
                                : null,
                            color: AppColors.secondary,
                            size: 28,
                          )),
                    ),
                    Flexible(
                      child: Text(
                        option.text,
                        style: bodyStyle(size: 12, color: AppColors.secondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // const SizedBox(width: 6),
                    // Text(
                    //   "${option.votes.length}",
                    //   style: bodyStyle(
                    //     size: 12,
                    //     color: AppColors.secondary.withOpacity(0.7),
                    //   ),
                    // ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    ),
  );
}
