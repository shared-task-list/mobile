import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/task.dart';

class TaskDetailRepository {
  static const _taskTable = 'tasks';

  Future createTask(UserTask task) async {
    var db = await DBProvider.db.database;
    await db.insert(_taskTable, task.toMap());
  }

  Future updateTask(UserTask task) async {
    var db = await DBProvider.db.database;
    await db.rawUpdate(
      'update $_taskTable set Title = ?, Comment = ?, Category = ? where Uid = ?',
      [task.title, task.comment, task.category, task.uid],
    );
  }
}
