import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/extension/color_extension.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/app_model.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/settings/settings_repository.dart';
import 'package:shared_task_list/task_list/task_list_repository.dart';
import 'package:uuid/uuid.dart';

class TaskListBloc {
  final _repository = TaskListRepository();
  final _settingsRepo = SettingsRepository();
  final _fbClient = FbClient();
  final settings = BehaviorSubject<Settings>();
  final categoryTaskMapStream = BehaviorSubject<Map<Category, List<UserTask>>>();

  final _categoryTaskMap = Map<Category, List<UserTask>>();
  late DatabaseReference ref;

  TaskListBloc() {
    String hash = _getPasswordHash();
    ref = _fbClient.reference.child(Constant.taskList + hash);
  }

  void _subscribe() {
    ref.onChildAdded.listen((Event event) async {
      final task = UserTask.fromFbData(event);

      if (task.comment == Constant.serviceTaskComment) {
        return;
      }

      if (task.category.isEmpty) {
        task.category = Constant.noCategory;
      }

      try {
        final category = _categoryTaskMap.keys.firstWhere((cat) => cat.name == task.category);
        final taskList = _categoryTaskMap[category]!;

        for (final existTask in taskList) {
          if (existTask.uid == task.uid) {
            return;
          }
        }

        taskList.add(task);
        _categoryTaskMap[category] = taskList;
      } catch (e) {
        final newCategory = Category(
          name: task.category,
          colorString: Constant.defaultCategoryColor.toRgbString(),
          order: DateTime.now().millisecondsSinceEpoch,
        );
        _categoryTaskMap[newCategory] = [task];
      }

      categoryTaskMapStream.add(_categoryTaskMap);
    });
    ref.onChildRemoved.listen((Event event) async {
      final task = UserTask.fromFbData(event);

      if (task.uid == '') {
        return;
      }

      if (task.category.isEmpty) {
        task.category = Constant.noCategory;
      }

      final category = _categoryTaskMap.keys.firstWhere((cat) => cat.name == task.category);
      final taskList = _categoryTaskMap[category]!;

      taskList.remove(task);
      _categoryTaskMap[category] = taskList;

      categoryTaskMapStream.add(_categoryTaskMap);
      await _repository.remove(task);
    });
    ref.onChildChanged.listen((Event event) {
      final task = UserTask.fromFbData(event);

      if (task.uid == '') {
        return;
      }

      try {
        final category = _categoryTaskMap.keys.firstWhere((cat) => cat.name == task.category);
        final taskList = _categoryTaskMap[category]!;
        int index = taskList.indexWhere((UserTask t) => t.uid == task.uid);

        if (index == -1) {
          return;
        }

        taskList[index] = task;
        _categoryTaskMap[category] = taskList;
        categoryTaskMapStream.add(_categoryTaskMap);
      } catch (e) {
        return;
      }
    });
  }

  Future<bool> init() async {
    _repository.initStream.listen((ListInitData data) {
      settings.add(data.settings);

      for (final category in data.categories) {
        final tasks = data.tasks.where((task) => task.category == category.name);

        if (tasks.isEmpty) {
          continue;
        }

        _categoryTaskMap[category] = tasks.toList();
      }

      categoryTaskMapStream.add(_categoryTaskMap);

      load();
      _subscribe();
    });

    await _repository.init();

    return true;
  }

  Future load() async {
    if (_categoryTaskMap.isNotEmpty) {
      return;
    }

    final taskList = await _fbClient.getAll(Constant.taskList);
    final categoryNames = taskList.map((task) => task.category.isEmpty ? Constant.noCategory : task.category).toSet();
    final existCategories = _categoryTaskMap.keys.toList();
    final existsCategoryNames = existCategories.map((category) => category.name).toSet();

    _categoryTaskMap.clear();

    for (final categoryName in categoryNames) {
      late Category category;

      if (existsCategoryNames.contains(categoryName)) {
        category = existCategories.firstWhere((cat) => cat.name == categoryName);
      } else {
        category = Category(
          name: categoryName,
          colorString: Constant.defaultCategoryColor.toRgbString(),
          order: DateTime.now().millisecondsSinceEpoch,
          isExpand: true,
        );
        int id = await CategoryProvider.create(category);
        category.id = id;
      }

      final tasks = taskList.where((task) => task.category == category.name);

      if (tasks.isEmpty) {
        continue;
      }

      _categoryTaskMap[category] = tasks.toList();
    }

    categoryTaskMapStream.add(_categoryTaskMap);

    await CategoryProvider.saveList(_categoryTaskMap.keys.toList());
    await _repository.saveTasks(taskList);
  }

  Future remove(UserTask task) async {
    final category = _categoryTaskMap.keys.firstWhere((category) => category.name == task.category);
    final taskList = _categoryTaskMap[category]!;

    taskList.remove(task);
    _categoryTaskMap[category] = taskList;
    categoryTaskMapStream.add(_categoryTaskMap);

    _repository.remove(task);
    await _fbClient.removeTask(task);
  }

  void createNewCategory(String newCategory) {
    if (newCategory.isEmpty) {
      return;
    }

    final category = Category(
      name: newCategory,
      colorString: Constant.defaultCategoryColor.toRgbString(),
      order: DateTime.now().millisecondsSinceEpoch,
    );
    category.save();
  }

  Future quickAdd(String title, String category) async {
    // get preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userUid = prefs.getString(Constant.authorUidKey) ?? '';

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

  String _getPasswordHash() {
    List<int> bytes = utf8.encode(Constant.password);
    Digest digest = sha256.convert(bytes);

    return base64.encode(digest.bytes);
  }

  void dispose() {
    settings.close();
    categoryTaskMapStream.close();
    _repository.dispose();
  }

  Future setColorForCategory(Category category, Color color) async {
    final taskList = _categoryTaskMap[category]!;

    category.colorString = color.toRgbString();
    _categoryTaskMap[category] = taskList;

    categoryTaskMapStream.add(_categoryTaskMap);
    await CategoryProvider.update(category);
  }

  List<Category> get categories {
    final categories = _categoryTaskMap.keys.toList();
    categories.sort((cat1, cat2) => cat1.order.compareTo(cat2.order));
    // categories.insert(0, AppData.noCategory);

    return categories;
  }

  Future getSettings() async {
    final setts = await _settingsRepo.getSettings();
    settings.add(setts);
  }
}
