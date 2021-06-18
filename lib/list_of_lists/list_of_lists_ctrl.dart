import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/list_of_lists/list_of_lists_repository.dart';
import 'package:shared_task_list/model/task_list.dart';

class ListOfListsCtrl extends GetxController {
  late FbClient _fbClient;
  late ListOfListsRepository _repo;
  var lists = List<TaskList>.empty().obs;

  @override
  void onInit() async {
    super.onInit();
    _fbClient = FbClient();

    _repo = ListOfListsRepository();
    _repo.taskLists.listen((list) => lists.value = list);
    await _repo.getLists();
  }

  Future<bool> isExistList(String name, String password) async {
    if (name.isEmpty || password.isEmpty) {
      return false;
    }

    return await _fbClient.isExistList(name, password);
  }

  Future<bool> isExistInDb(String name, String password) async {
    if (name.isEmpty || password.isEmpty) {
      return false;
    }

    TaskList list = await _repo.get(name, password);
    return list.id != 0;
  }

  Future createList(String name, String password, bool createInFb) async {
    await _repo.createList(name, password, createInFb);
  }

  Future deleteList(TaskList list) async {
    lists.remove(list);
    await _repo.deleteList(list);
  }

  Future open(TaskList list) async {
    await _savePreferences(list.name, list.password);
  }

  Future _savePreferences(String name, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constant.taskListKey, name);
    await prefs.setString(Constant.passwordKey, password);

    Constant.taskList = name;
    Constant.password = password;
  }

  @override
  void onClose() {
    super.onClose();
    _repo.dispose();
  }
}
