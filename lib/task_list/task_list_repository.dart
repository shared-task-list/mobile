import 'package:rxdart/rxdart.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/app_model.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/settings/settings_repository.dart';

class TaskListRepository {
  static const _taskTable = 'tasks';
  final _fbClient = FbClient();
  final initStream = PublishSubject<ListInitData>();

  void dispose() {
    initStream.close();
  }

  Future init() async {
    var db = await DBProvider.db.database;
    List<Map> maps = await db.rawQuery(
      'select '
      't.Uid as tuid, t.Title as ttitle, t.Category as tcat, t.Timestamp as tt, '
      'cats.name as cname, cats.color_string as ccolor, cats.id as cid, cats."order" as corder, '
      's.default_category as sdf, s.is_show_categories as ssc, s.is_show_quick_add as sqd '
      'from tasks as t '
      'join categories as cats on 1 = 1 '
      'join settings as s on 1 = 1',
    );
    List<UserTask> tasks = [];
    List<Category> cats = [];
    Set<String> taskId = {};
    Set<String> catName = {};

    if (maps.isEmpty) {
      Settings settings = Settings(
        defaultCategory: Constant.noCategory,
        isShowCategories: true,
        isShowQuickAdd: true,
      );
      final initData = ListInitData()
        ..categories = cats
        ..tasks = tasks
        ..settings = settings;
      initStream.add(initData);

      var repo = SettingsRepository();
      await repo.saveSettings(settings);
      return;
    }

    Settings settings = Settings(
      defaultCategory: maps.first['sdf'],
      isShowCategories: maps.first['ssc'] == null ? true : maps.first['ssc'] == 1,
      isShowQuickAdd: maps.first['sqd'] == null ? true : maps.first['sqd'] == 1,
    );

    for (final item in maps) {
      if (!taskId.contains(item['tuid'])) {
        var task = UserTask(
          uid: item['tuid'],
          category: item['tcat'],
          title: item['ttitle'],
          timestamp: DateTime.parse(item["tt"]),
        );
        tasks.add(task);
        taskId.add(task.uid);
      }
      if (!catName.contains(item['cname'])) {
        var cat = Category(
          name: item['cname'],
          colorString: item['ccolor'],
          id: item['cid'],
          order: item['corder'] ?? 0,
        );
        catName.add(cat.name);
        cats.add(cat);
      }
    }

    final initData = ListInitData()
      ..categories = cats
      ..tasks = tasks
      ..settings = settings;
    initStream.add(initData);
  }

  Future<List<UserTask>> getTasks() async {
    final db = await DBProvider.db.database;
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
    final db = await DBProvider.db.database;
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
    final db = await DBProvider.db.database;
    await db.delete(_taskTable, where: 'Uid = ?', whereArgs: [task.uid]);
  }

  Future clearTasks() async {
    final db = await DBProvider.db.database;
    db.delete(_taskTable);
  }

  Future createTask(UserTask task) async {
    final db = await DBProvider.db.database;
    await db.insert(_taskTable, task.toMap());
  }
}
