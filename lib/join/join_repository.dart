import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/task_list.dart';

class JoinRepository {
  static const _taskListTable = 'task_lists';

  Future saveList() async {
    var db = await DBProvider.db.database;
    List<Map> maps = await db.query(
      _taskListTable,
      where: 'name = ? and password = ?',
      whereArgs: [Constant.taskList, Constant.password],
    );

    if (maps.isNotEmpty) {
      return;
    }

    var taskList = TaskList(
      password: Constant.password,
      name: Constant.taskList,
    );
    db.insert(_taskListTable, taskList.toMap());
  }

  Future<List<TaskList>> getLists() async {
    var db = await DBProvider.db.database;
    List<Map<String, dynamic>> maps = await db.query(_taskListTable, orderBy: 'updated_at desc');
    var lists = <TaskList>[];

    for (final map in maps) {
      lists.add(TaskList.fromMap(map));
    }

    return lists;
  }

  Future removeTaskList(TaskList taskList) async {
    var db = await DBProvider.db.database;
    await db.delete(_taskListTable, where: 'id = ?', whereArgs: [taskList.id]);
  }

  Future updateTaskList(int id) async {
    var db = await DBProvider.db.database;
    await db.rawUpdate(
      'update $_taskListTable set updated_at = ? where id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }
}
