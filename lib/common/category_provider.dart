import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/category.dart';

// TODO: no static
class CategoryProvider {
  static const _categoryTable = 'categories';

  static Future saveList(List<Category> newCategories) async {
    var dbf = DBProvider.db.database;
    var savedCategories = Map<String, Category>();
    var savedList = await getList();
    savedList.forEach((cat) {
      savedCategories[cat.name] = cat;
    });

    var db = await dbf;

    try {
      var batch = db.batch();
      batch.rawDelete('delete from $_categoryTable');

      // заем добавитть новые
      for (Category category in newCategories) {
        if (savedCategories.containsKey(category.name)) {
          category.colorString = savedCategories[category.name].colorString;
        }
        batch.insert(_categoryTable, category.toMap());
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

  static Future save(Category category) async {
    var db = await DBProvider.db.database;
    var batch = db.batch();
    batch.rawUpdate(
      'update $_categoryTable set name = ?, color_string = ? where id = ?',
      [category.name, category.colorString, category.id],
    );
    batch.commit(noResult: true);
  }
}
