import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/join/join_repository.dart';
import 'package:shared_task_list/model/task_list.dart';

class JoinBloc {
  final _fbClient = FbClient();
  final _repository = JoinRepository();
  final taskLists = BehaviorSubject<List<TaskList>>();

  String username;
  String taskList;
  String password;

  Future<bool> isExist() async {
    if (taskList.isEmpty || password.isEmpty) {
      return false;
    }

    Constant.password = password;
    bool isExist = await _fbClient.isExist(Constant.taskList);

    return isExist;
  }

  Future create() async {
    if (Constant.taskList.isEmpty || Constant.password.isEmpty) {
      return false;
    }
    await _fbClient.createTaskList(Constant.taskList);
  }

  Future savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constant.taskListKey, taskList);
    await prefs.setString(Constant.passwordKey, password);
    await prefs.setString(Constant.authorKey, username);

    Constant.taskList = taskList;
    Constant.password = password;
    Constant.userName = username;

    await _repository.saveList();
  }

  Future getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString(Constant.authorKey) ?? "";

    if (name.isEmpty) {
      return;
    }

    username = name;
    Constant.userName = name;
  }

  Future getTaskLists() async {
    final _taskLists = await _repository.getLists();
    taskLists.add(_taskLists);
  }

  Future removeList(TaskList taskList) async {
    await _repository.removeTaskList(taskList);
    await getTaskLists();
  }
}
