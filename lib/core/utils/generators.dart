import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

String generateEventId() => "EV${Random().nextInt(100000)}";

String generatePollId() => "PL${Random().nextInt(100000)}";

String generateChatId() => "CH${Random().nextInt(100000)}";

String generateMessageId() => "MS${Random().nextInt(100000)}";

Future<bool> idAvaliability(String id, String collection) async {
  final doc =
      await FirebaseFirestore.instance.collection(collection).doc(id).get();

  return doc.exists;
}
