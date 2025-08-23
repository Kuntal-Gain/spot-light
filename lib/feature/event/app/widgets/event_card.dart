import 'package:flutter/material.dart';
import 'package:spot_time/core/constants/app_color.dart';
import 'package:spot_time/feature/event/domain/entities/event_entity.dart';

import '../../../../core/utils/text_style.dart';

Widget eventCard({required EventEntity event, required BuildContext ctx}) {
  final mq = MediaQuery.of(ctx).size;

  return Container(
    height: mq.height * 0.14,
    width: mq.width * 0.8,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.secondary, width: 1.8),
      borderRadius: BorderRadius.circular(5),
      color: AppColors.primary,
      boxShadow: [
        BoxShadow(
          color: AppColors.secondary,
          spreadRadius: 3,
          offset: const Offset(10, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              height: mq.height * 0.12,
              width: mq.height * 0.12,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColors.primary,
                border: Border.all(color: AppColors.secondary, width: 1.8),
              ),
              child: event.coverImage != null && event.coverImage!.isNotEmpty
                  ? Image.network(event.coverImage!)
                  : Center(
                      child: Text(
                        event.name.substring(0, 1),
                        style: headingStyle(
                          color: AppColors.secondary,
                          size: mq.height * 0.05,
                        ),
                      ),
                    ),
            ),
            Container(
              height: mq.height * 0.1,
              width: mq.width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text(
                        event.name,
                        style: headingStyle(
                          color: AppColors.secondary,
                          size: mq.height * 0.025,
                        ),
                      ),
                      eventWidget(
                          type: eventTypeItems
                              .firstWhere((e) => e.type == event.type),
                          size: Size(mq.width * 0.25, mq.height * 0.03)),
                    ],
                  ),
                  Text('user-2 is Added',
                      style: bodyStyle(
                        color: AppColors.secondary,
                        size: mq.height * 0.012,
                      )),
                ],
              ),
            )
          ],
        )
      ],
    ),
  );
}

class EventTypeItem {
  final String type;
  final Color color;

  EventTypeItem({
    required this.type,
    required this.color,
  });
}

final eventTypeItems = [
  EventTypeItem(type: 'feast', color: Colors.red),
  EventTypeItem(type: 'party', color: Colors.blue),
  EventTypeItem(type: 'birthday', color: Colors.green),
  EventTypeItem(type: 'meeting', color: Colors.indigo),
  EventTypeItem(type: 'other', color: Colors.purple),
];

Widget eventWidget({required EventTypeItem type, required Size size}) {
  return Container(
    height: size.height,
    width: size.width,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: type.color,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Center(
      child: Text(
        type.type,
        style: headingStyle(
          color: AppColors.primary,
          size: 12,
        ),
      ),
    ),
  );
}
