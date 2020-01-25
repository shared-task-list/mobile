import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/category.dart';

// TODO: no static
class CategoryProvider {
  static const _categoryTable = 'categories';

  static Future saveList(Set<String> categories) async {
    var db = await DBProvider.db.database;

    try {
      var batch = db.batch();
      batch.rawDelete('delete from $_categoryTable');

      for (final category in categories) {
        batch.insert(_categoryTable, Category(name: category).toMap());
      }

      batch.commit(noResult: true);
    } catch (e) {
      return;
    }
  }

  static Future<List<Category>> getList() async {
    var db = await DBProvider.db.database;
    List<Map> maps = await db.query(_categoryTable);
    var lists = List<Category>();

    for (final map in maps) {
      final task = Category.fromMap(map);
      lists.add(task);
    }

    return lists;
  }
}
