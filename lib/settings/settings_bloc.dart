import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/settings/settings_repository.dart';
import 'package:shared_task_list/task_list/task_list_repository.dart';

class SettingsBloc {
  final _repository = SettingsRepository();
  final categories = BehaviorSubject<List<Category>>();
  final category = BehaviorSubject<String>();
  final name = BehaviorSubject<String>();
  final bgColor = BehaviorSubject<Color>();
  final isShowCategories = BehaviorSubject<bool>();

  bool visibleCats = false;

  SettingsBloc() {
    bgColor.add(Constant.bgColor);
  }

  Future<Settings> getSettings() async {
    return await _repository.getSettings();
  }

  Future saveSettings(Settings settings) async {
    await _repository.saveSettings(settings);
  }

  Future exit() async {
    var taskRepo = TaskListRepository();
    await taskRepo.clearTasks();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constant.taskListKey);
    await prefs.remove(Constant.passwordKey);

//    _repository.saveSettings(Settings(defaultCategory: '', isShowCategories: true, isShowQuickAdd: true));

    Constant.taskList = '';
    Constant.password = '';
  }

  void setVisibleCats(bool value) {
    visibleCats = value;
    isShowCategories.add(visibleCats);
  }

  void close() {
    categories.close();
    category.close();
    name.close();
    isShowCategories.close();
    bgColor.close();
  }
}
