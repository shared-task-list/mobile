import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/app_model.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/settings/settings_repository.dart';
import 'package:shared_task_list/task_list/task_list_repository.dart';
import 'package:shared_task_list/common/extension/color_extension.dart';
import 'package:uuid/uuid.dart';

class TaskListCtrl extends GetxController {
  late TaskListRepository _repository;
  late SettingsRepository _settingsRepo;
  late FbClient _fbClient;
  late DatabaseReference ref;

  var settings = Settings.empty().obs;
  var categories = List<Category>.empty().obs;
  var categoryTaskMap = Map<Category, List<UserTask>>().obs;

  @override
  void onInit() {
    super.onInit();

    _fbClient = FbClient();
    _repository = TaskListRepository();
    _settingsRepo = SettingsRepository();

    String hash = _getPasswordHash();
    ref = _fbClient.reference.child(Constant.taskList + hash);

    init();
  }

  @override
  void onClose() {
    super.onClose();
    _repository.dispose();
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
        final category = categoryTaskMap.keys.firstWhere((cat) => cat.name == task.category);
        final taskList = categoryTaskMap[category] ?? [];

        for (final existTask in taskList) {
          if (existTask.uid == task.uid) {
            return;
          }
        }

        taskList.add(task);
        categoryTaskMap[category] = taskList;
      } catch (e) {
        final newCategory = Category(
          name: task.category,
          colorString: Constant.defaultCategoryColor.toRgbString(),
          order: DateTime.now().millisecondsSinceEpoch,
          // isExpand: true,
        );
        newCategory.isExpand.value = true;
        newCategory.save();

        categories.add(newCategory);
        categoryTaskMap[newCategory] = [task];
      }
    });
    ref.onChildRemoved.listen((Event event) async {
      final task = UserTask.fromFbData(event);

      if (task.uid == '') {
        return;
      }

      if (task.category.isEmpty) {
        task.category = Constant.noCategory;
      }

      final category = categoryTaskMap.keys.firstWhere((cat) => cat.name == task.category);
      final taskList = categoryTaskMap[category]!;

      taskList.remove(task);
      categoryTaskMap[category] = taskList;

      // categoryTaskMapStream.add(categoryTaskMap);
      await _repository.remove(task);
    });
    ref.onChildChanged.listen((Event event) async {
      final task = UserTask.fromFbData(event);

      if (task.uid == '') {
        return;
      }

      try {
        final category = categoryTaskMap.keys.firstWhere((cat) => cat.name == task.category);
        final taskList = categoryTaskMap[category]!;
        int index = taskList.indexWhere((UserTask t) => t.uid == task.uid);

        if (index == -1) {
          return;
        }

        taskList[index] = task;
        categoryTaskMap[category] = taskList;
        // categoryTaskMapStream.add(categoryTaskMap);

        await _repository.update(task);
      } catch (e) {
        return;
      }
    });
  }

  Future init() async {
    _repository.initStream.listen((ListInitData data) async {
      settings.value = data.settings;

      for (final category in data.categories) {
        final tasks = data.tasks.where((task) => task.category == category.name);

        if (tasks.isEmpty) {
          continue;
        }

        categoryTaskMap[category] = tasks.toList();
        categories.add(category);
      }

      await load();
      _subscribe();
    });

    await _repository.init();
  }

  Future load() async {
    final taskList = await _fbClient.getAll(Constant.taskList);
    final categoryNames = taskList.map((task) => task.category.isEmpty ? Constant.noCategory : task.category).toSet();
    final existCategories = categoryTaskMap.keys.toList();
    final existsCategoryNames = existCategories.map((category) => category.name).toSet();

    categoryTaskMap.clear();
    categories.clear();

    for (final categoryName in categoryNames) {
      late Category category;

      if (existsCategoryNames.contains(categoryName)) {
        category = existCategories.firstWhere((cat) => cat.name == categoryName);
      } else {
        category = Category(
          name: categoryName,
          colorString: Constant.defaultCategoryColor.toRgbString(),
          order: DateTime.now().millisecondsSinceEpoch,
          // isExpand: true,
        );
        category.isExpand.value = true;
        // int id = await CategoryProvider.create(category);
        // category.id = id;
      }

      final tasks = taskList.where((task) => task.category == category.name);

      if (tasks.isEmpty) {
        continue;
      }

      categories.add(category);
      categoryTaskMap[category] = tasks.toList();
    }

    _repository.saveTasks(taskList);
    CategoryProvider.saveList(categoryTaskMap.keys.toList());
  }

  Future remove(UserTask task) async {
    final category = categoryTaskMap.keys.firstWhere((category) => category.name == task.category);
    final taskList = categoryTaskMap[category]!;

    taskList.remove(task);
    categoryTaskMap[category] = taskList;
    // categoryTaskMapStream.add(categoryTaskMap);

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

    await _repository.create(task);
    await _fbClient.addTask(task);
  }

  String _getPasswordHash() {
    List<int> bytes = utf8.encode(Constant.password);
    Digest digest = sha256.convert(bytes);

    return base64.encode(digest.bytes);
  }

  Future setColorForCategory(Category category, Color color) async {
    final taskList = categoryTaskMap[category] ?? [];

    category.colorString = color.toRgbString();
    categoryTaskMap[category] = taskList;

    await CategoryProvider.update(category);
  }

  // List<Category> get categories {
  //   final categories = categoryTaskMap.keys.toList();
  //   categories.sort((cat1, cat2) => cat1.order.compareTo(cat2.order));

  //   int cindex = categories.indexWhere((c) => c.name == Constant.noCategory);

  //   if (cindex == -1) {
  //     categories.insert(0, AppData.noCategory);
  //   }

  //   return categories;
  // }

  Future getSettings() async {
    settings.value = await _settingsRepo.getSettings();
  }
}
