import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/model/task.dart';

class FbClient {
  static DatabaseReference _db;
  static final FbClient _singleton = FbClient._internal();

  factory FbClient() {
    _db = FirebaseDatabase.instance.reference();
    return _singleton;
  }

  FbClient._internal();

  DatabaseReference get reference => _db;

  Future<bool> isExist(String taskList) async {
    String hash = _getPasswordHash();
    DataSnapshot snapshot = await _db.child(taskList + hash).once();

    var data = snapshot.value as Map<dynamic, dynamic>;

    return data != null;
  }

  Future<List<UserTask>> getAll(String taskList) async {
    String hash = _getPasswordHash();
    DataSnapshot snapshot = await _db.child(taskList + hash).once();

    var data = snapshot.value as Map<dynamic, dynamic>;
    var tasks = List<UserTask>();
    var items = List<Map<String, dynamic>>();

    for (final item in data.values) {
      var itemMap = item as Map<dynamic, dynamic>;
      var jsonData = Map<String, dynamic>();

      itemMap.forEach((key, value) {
        jsonData[key.toString()] = value;
      });

      items.add(jsonData);
    }
    for (final item in items) {
      UserTask task = UserTask.fromMap(item);

      if (task.author == 'Admin' && task.comment == Constant.serviceTaskComment) {
        continue;
      }

      tasks.add(task);
    }

    return tasks;
  }

  Future createTaskList(String taskList) async {
    String hash = _getPasswordHash();
    final serviceTask = UserTask(
      author: 'Admin',
      comment: Constant.serviceTaskComment,
      timestamp: DateTime.now(),
      authorUid: null,
      category: null,
      title: null,
      uid: null,
    );
    await _db.child(taskList + hash).push().set(serviceTask.toMap());
  }

  Future addTask(UserTask task) async {
    String hash = _getPasswordHash();
    await _db.child(Constant.taskList + hash).child(task.uid).set(task.toMap());
  }

  Future updateTask(UserTask task) async {
    String hash = _getPasswordHash();
    await _db.child(Constant.taskList + hash).child(task.uid).update(task.toMap());
  }

  Future removeTask(UserTask task) async {
    String hash = _getPasswordHash();
    await _db.child(Constant.taskList + hash).child(task.uid).remove();
  }

  String _getPasswordHash() {
    List<int> bytes = utf8.encode(Constant.password);
    Digest digest = sha256.convert(bytes);

    return base64.encode(digest.bytes);
  }
}
