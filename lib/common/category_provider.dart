import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/category.dart';

// TODO: no static
class CategoryProvider {
  static const _categoryTable = 'categories';

  static Future saveList(List<Category> newCategories) async {
    final db = await DBProvider.db.database;
    var savedCategories = Map<String, Category>();
    var oldCategories = await getList();

    for (final cat in oldCategories) {
      savedCategories[cat.name] = cat;
    }

//    await db.rawDelete('delete from $_categoryTable');

    final batch = db.batch();

    for (Category category in newCategories) {
      bool isExist = false;

      if (savedCategories.containsKey(category.name)) {
        isExist = true;
        category.colorString = savedCategories[category.name]!.colorString;
        category.order = savedCategories[category.name]!.order;
        category.isExpand = savedCategories[category.name]!.isExpand;
      }

      if (isExist) {
        batch.rawUpdate(
          'update $_categoryTable set name = ?, color_string = ?, "order" = ?, is_expand = ? where id = ?',
          [category.name, category.colorString, category.order, category.getExpand(), category.id],
        );
      } else {
        batch.rawInsert(
          'insert into $_categoryTable (name, color_string, "order", is_expand) values (?,?,?,?)',
          [category.name, category.colorString, category.order, category.getExpand()],
        );
      }
    }

    batch.commit(noResult: true);
  }

  static Future<List<Category>> getList() async {
    var db = await DBProvider.db.database;
    List<Map<String, dynamic>> maps = await db.query(_categoryTable);
    var lists = <Category>[];

    for (final map in maps) {
      final task = Category.fromMap(map);
      lists.add(task);
    }

    lists.sort((cat1, cat2) => cat1.order.compareTo(cat2.order));
    return lists;
  }

  static Future update(Category category) async {
    var db = await DBProvider.db.database;
    var batch = db.batch();
    batch.rawUpdate(
      'update $_categoryTable set name = ?, color_string = ?, "order" = ?, is_expand = ? where id = ?',
      [category.name, category.colorString, category.order, category.getExpand(), category.id],
    );
    batch.commit(noResult: true);
  }

  static Future<int> create(Category category) async {
    final db = await DBProvider.db.database;
    return await db.insert(_categoryTable, category.toMap());
  }

  static Future delete(Category category) async {
    var db = await DBProvider.db.database;
    await db.delete(_categoryTable, where: 'id = ?', whereArgs: [category.id]);
  }
}
