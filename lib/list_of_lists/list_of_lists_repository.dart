import 'package:rxdart/rxdart.dart';
import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/task_list.dart';

class ListOfListsRepository {
  static const _taskListTable = 'task_lists';
  final _fbClient = FbClient();
  final taskLists = BehaviorSubject<List<TaskList>>();

  Future getLists() async {
    var db = await DBProvider.db.database;
    List<Map<String, dynamic>> maps = await db.query(_taskListTable, orderBy: 'updated_at desc');
    var lists = <TaskList>[];

    for (final map in maps) {
      lists.add(TaskList.fromMap(map));
    }

    taskLists.add(lists);
  }

  void dispose() {
    taskLists.close();
  }

  Future<TaskList> get(String name, String password) async {
    var db = await DBProvider.db.database;
    List<Map<String, dynamic>> maps = await db.query(
      _taskListTable,
      where: 'name = ? and password = ?',
      whereArgs: [name, password],
    );

    if (maps.isEmpty) {
      return TaskList.empty();
    }

    return TaskList.fromMap(maps.first);
  }

  Future createList(String name, String password, bool createInFb) async {
    var db = await DBProvider.db.database;
    List<Map> maps = await db.query(
      _taskListTable,
      where: 'name = ? and password = ?',
      whereArgs: [name, password],
    );

    if (maps.isNotEmpty) {
      return null;
    }

    var taskList = TaskList(
      name: name,
      password: password,
    );
    await db.insert(_taskListTable, taskList.toMap());
    getLists();

    if (createInFb) {
      _fbClient.createNewTaskList(name, password);
    }
  }

  Future deleteList(TaskList list) async {
    var db = await DBProvider.db.database;
    await db.delete(_taskListTable, where: 'id = ?', whereArgs: [list.id]);
    // TODO: delete in fb
  }
}
