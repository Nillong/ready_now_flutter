import 'package:firebase_core/firebase_core.dart';

class ChatEntry {
  String key;
  DateTime dateTime;
  String message;

  ChatEntry(this.dateTime, this.message);

  toJson() {
    return {
      "date": dateTime.millisecondsSinceEpoch,
      "message": message,
    };
  }
}