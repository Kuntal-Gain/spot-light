import 'package:cloud_firestore/cloud_firestore.dart';

String getTime(int time) {
  // Convert timestamp (ms since epoch) to DateTime
  final dateTime = DateTime.fromMillisecondsSinceEpoch(time);

  // Extract hour, minute, second with zero-padding
  final hours = dateTime.hour;
  final minutes = dateTime.minute;
  final isPM = hours >= 12;
  final hour = hours % 12;
  final formattedHour = hour == 0 ? '12' : hour.toString();
  final formattedMinutes = minutes.toString().padLeft(2, '0');

  // Format -> 09:29 AM or 09:29 PM
  return '$formattedHour:$formattedMinutes ${isPM ? 'PM' : 'AM'}';
}

String formatDate(int time) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(time);
  final now = DateTime.now();

  // Normalize times (remove hours, minutes, seconds)
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    return "Today";
  } else if (messageDate == yesterday) {
    return "Yesterday";
  } else {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return "$day/$month/$year";
  }
}

String formatDateTime(dynamic time) {
  final now = DateTime.now();
  final dateTime = time is Timestamp
      ? time.toDate()
      : DateTime.fromMillisecondsSinceEpoch(time as int);

  final duration = now.difference(dateTime);

  if (duration.inMinutes < 1) {
    return "Just Now";
  } else if (duration.inMinutes < 60) {
    return '${duration.inMinutes} min ago';
  } else if (duration.inHours < 24) {
    return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
  } else {
    return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
  }
}
