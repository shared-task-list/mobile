import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/settings/settings_repository.dart';
import 'package:shared_task_list/task_list/task_list_repository.dart';
import 'package:uuid/uuid.dart';

class TaskListBloc {
  final _repository = TaskListRepository();
  final _settingsRepository = SettingsRepository();
  final _fbClient = FbClient();
  final tasksMap = PublishSubject<Map<String, List<UserTask>>>();
  final settings = PublishSubject<Settings>();
  final categoryMapStream = PublishSubject<Map<String, Category>>();

  var _taskList = List<UserTask>();
  var _taskMap = Map<String, List<UserTask>>();
  var _categoryMap = Map<String, Category>();
  DatabaseReference ref;

  TaskListBloc() {
//    _fbClient.reference.onChildChanged.listen(onData);
    String hash = _getPasswordHash();
    ref = _fbClient.reference.child(Constant.taskList + hash);
  }

  void _subscribe() {
    ref.onChildAdded.listen((Event event) {
      final task = UserTask.fromFbData(event);

      if (task == null || task.comment == Constant.serviceTaskComment) {
        return;
      }
      if (task.category.isEmpty) {
        task.category = Constant.noCategory;
      }
      if (!_categoryMap.containsKey(task.category)) {
        _categoryMap[task.category] = Category(name: task.category, colorString: colorToString(Colors.grey.shade600));
        Category(name: task.category).save();
      }
      try {
        _taskList.firstWhere((UserTask t) => t.uid == task.uid);
      } catch (e) {
        if (!_taskMap.containsKey(task.category)) {
          _taskMap[task.category] = List<UserTask>();
        }
        _taskMap[task.category].add(task);
        tasksMap.add(_taskMap);
      }
    });
    ref.onChildRemoved.listen((Event event) {
      final task = UserTask.fromFbData(event);

      if (task == null) {
        return;
      }
      if (task.category.isEmpty) {
        task.category = Constant.noCategory;
      }

      _taskList.removeWhere((UserTask t) => t.uid == task.uid);
      _taskMap[task.category].removeWhere((UserTask t) => t.uid == task.uid);
      tasksMap.add(_taskMap);
    });
    ref.onChildChanged.listen((Event event) {
      final task = UserTask.fromFbData(event);

      if (task == null) {
        return;
      }

      int index = _taskList.indexWhere((UserTask t) => t.uid == task.uid);
      int mapIndex = _taskMap[task.category].indexWhere((UserTask t) => t.uid == task.uid);

      _taskList[index] = task;
      _taskMap[task.category][mapIndex] = task;
      tasksMap.add(_taskMap);
    });
  }

  Future<bool> init() async {
    load();
//    getSettings();
    var cats = await getCategories();

    for (var cat in cats) {
      _categoryMap[cat.name] = cat;
    }

    categoryMapStream.add(_categoryMap);
    return true;
  }

  Future load() async {
    if (_taskList.isNotEmpty) {
      return;
    }

    await getTasks();
    CategoryProvider.saveList(_categoryMap.values.toList());
    _subscribe();
    var cats = await getCategories();

    for (var cat in cats) {
      _categoryMap[cat.name] = cat;
    }

    categoryMapStream.add(_categoryMap);
  }

  Future getTasks() async {
    List<UserTask> _tasks = await _repository.getTasks();

    if (_tasks.isNotEmpty) {
      _taskList = _tasks;

      createTaskMap(_taskList);
      tasksMap.add(_taskMap);
    }

    _taskList = await _fbClient.getAll(Constant.taskList);

    await createTaskMap(_taskList);
    tasksMap.add(_taskMap);

    _repository.saveTasks(_taskList);
  }

  Future remove(UserTask task) async {
    _taskList.remove(task);

    createTaskMap(_taskList);
    tasksMap.add(_taskMap);

    _repository.remove(task);
    await _fbClient.removeTask(task);

    _repository.saveTasks(_taskList);
  }

  // todo: to extension
  String colorToString(Color color) {
    return "${color.red},${color.green},${color.blue}";
  }

  Future createTaskMap(List<UserTask> taskList) async {
    _taskMap.clear();

    for (final task in taskList) {
      if (task.category == null || task.category.isEmpty) {
        task.category = Constant.noCategory;
      }
      _categoryMap[Constant.noCategory] = Category(
        name: Constant.noCategory,
        colorString: colorToString(Colors.grey.shade600),
      );
    }
    for (final category in _categoryMap.keys.toList()) {
      if (category == Constant.noCategory) {
        _taskMap[Constant.noCategory] = taskList.where((task) => task.category == Constant.noCategory).toList();
        _taskMap[Constant.noCategory].sort((task1, task2) => task1.timestamp.compareTo(task2.timestamp));
        continue;
      }

      _taskMap[category] = taskList.where((task) => task.category == category).toList();
      _taskMap[category].sort((task1, task2) => task1.timestamp.compareTo(task2.timestamp));
    }
  }

  void createNewCategory(String newCategory) {
    if (newCategory.isEmpty) {
      return;
    }

    final category = Category(name: newCategory, colorString: colorToString(Colors.grey.shade600));
    category.save();
    _categoryMap[newCategory] = category;
  }

  Future exit() async {
    await _repository.clearTasks();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constant.taskListKey);
    await prefs.remove(Constant.passwordKey);

    _settingsRepository.saveSettings(Settings(defaultCategory: '', isShowCategories: true));

    Constant.taskList = '';
    Constant.password = '';
  }

  Future quickAdd(String title, String category) async {
    // get preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userUid = prefs.getString(Constant.authorUidKey);

    // create task
    final task = UserTask(
      title: title,
      comment: '',
      timestamp: DateTime.now(),
      uid: Uuid().v4(),
      author: Constant.userName,
      category: category,
      authorUid: userUid,
    );
    await _repository.createTask(task);
    await _fbClient.addTask(task);
  }

  Future<List<Category>> getCategories() async {
    return await CategoryProvider.getList();
  }

  Future getSettings() async {
    var _settings = await _settingsRepository.getSettings();
    settings.add(_settings);
  }

  String _getPasswordHash() {
    List<int> bytes = utf8.encode(Constant.password);
    Digest digest = sha256.convert(bytes);

    return base64.encode(digest.bytes);
  }

  void dispose() {
    tasksMap.close();
    settings.close();
    categoryMapStream.close();
  }

  Future setColorForCategory(String category, Color color) async {
    var cat = _categoryMap[category];
    cat.colorString = "${color.red},${color.green},${color.blue}";
    await CategoryProvider.save(cat);

    _categoryMap[category] = cat;
    categoryMapStream.add(_categoryMap);
  }
}
