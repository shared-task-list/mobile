import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/settings/settings_repository.dart';

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
