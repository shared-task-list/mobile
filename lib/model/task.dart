import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

class UserTask {
  String author;
  String authorUid;
  String category;
  String comment;
  String title;
  String uid;
  DateTime timestamp;

  UserTask({
    required this.author,
    required this.authorUid,
    required this.category,
    required this.timestamp,
    required this.title,
    required this.uid,
    this.comment = '',
  });

  factory UserTask.fromJson(String str) => UserTask.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserTask.fromMap(Map<String, dynamic> json) => UserTask(
        author: json["Author"] == null ? "" : json["Author"],
        authorUid: json["AuthorUid"] == null ? "" : json["AuthorUid"],
        category: json["Category"] == null ? "" : json["Category"],
        comment: json["Comment"] == null ? "" : json["Comment"],
        timestamp: json["Timestamp"] == null ? DateTime.now() : DateTime.parse(json["Timestamp"]),
        title: json["Title"] == null ? "" : json["Title"],
        uid: json["Uid"] == null ? "" : json["Uid"],
      );

  Map<String, dynamic> toMap() => {
        "Author": author,
        "AuthorUid": authorUid,
        "Category": category,
        "Comment": comment,
        "Timestamp": timestamp.toIso8601String(),
        "Title": title,
        "Uid": uid,
      };

  factory UserTask.fromFbData(Event event) {
    var data = event.snapshot.value as Map<dynamic, dynamic>;
    var jsonData = Map<String, dynamic>();

    data.forEach((key, value) {
      jsonData[key.toString()] = value;
    });

    var task = UserTask.fromMap(jsonData);
    return task;
  }
}
