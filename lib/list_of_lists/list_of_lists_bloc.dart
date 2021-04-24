import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/list_of_lists/list_of_lists_repository.dart';
import 'package:shared_task_list/model/task_list.dart';

class ListOfListsBloc {
  final _fbClient = FbClient();
  final _repo = ListOfListsRepository();
  final taskLists = BehaviorSubject<List<TaskList>>();

  ListOfListsBloc() {
    _repo.taskLists.listen((taskList) => taskLists.add(taskList));
  }

  Future getTaskLists() async {
    await _repo.getLists();
  }

  Future<bool> isExistList(String name, String password) async {
    if (name.isEmpty || password.isEmpty) {
      return false;
    }

    bool isExist = await _fbClient.isExistList(name, password);

    return isExist;
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

  void dispose() {
    _repo.dispose();
    taskLists.close();
  }
}
