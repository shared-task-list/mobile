import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/settings/settings_repository.dart';
import 'package:shared_task_list/task_list/task_list_repository.dart';

class SettingsCtrl extends GetxController {
  final _repo = SettingsRepository();
  final categories = List<Category>.empty().obs;
  final bgColor = Constant.bgColor.obs;
  final settings = Settings.empty().obs;

  @override
  void onInit() async {
    super.onInit();

    _repo.sesstingsStream.listen((value) => settings.value = value);
    settings.listen((setts) async {
      print(setts);
      await _repo.saveSettings(setts);
    });

    await getSettings();
  }

  @override
  void onClose() {
    _repo.dispose();
  }

  Future<Settings> getSettings() async {
    return await _repo.getSettings();
  }

  Future saveSettings(Settings settings) async {
    await _repo.saveSettings(settings);
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

  // void setVisibleCats(bool value) {
  //   visibleCats = value;
  //   isShowCategories.add(visibleCats);
  // }
}
