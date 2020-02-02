import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/task.dart';

class TaskListRepository {
  static const _taskTable = 'tasks';

  Future<List<UserTask>> getTasks() async {
    var db = await DBProvider.db.database;
    List<Map> maps = await db.query(_taskTable);
    var lists = List<UserTask>();

    for (final map in maps) {
      final task = UserTask.fromMap(map);

      if (task.author == 'Admin' && task.comment == Constant.serviceTaskComment) {
        continue;
      }

      lists.add(task);
    }

    return lists;
  }

  Future saveTasks(List<UserTask> tasks) async {
    var db = await DBProvider.db.database;
    try {
      var batch = db.batch();
      batch.rawDelete('delete from $_taskTable');

      for (final task in tasks) {
        batch.insert(_taskTable, task.toMap());
      }

      batch.commit(noResult: true);
    } catch (e) {
      return;
    }
  }

  Future remove(UserTask task) async {
    var db = await DBProvider.db.database;
    await db.delete(_taskTable, where: 'Uid = ?', whereArgs: [task.uid]);
  }

  Future clearTasks() async {
    var db = await DBProvider.db.database;
    db.delete(_taskTable);
  }

  Future createTask(UserTask task) async {
    var db = await DBProvider.db.database;
    await db.insert(_taskTable, task.toMap());
  }
}
