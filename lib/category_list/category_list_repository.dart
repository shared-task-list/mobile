import 'package:rxdart/rxdart.dart';
import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/category.dart';

class CategoryListRepository {
  static const _categoryTable = 'categories';
  final categories = BehaviorSubject<List<Category>>();

  void dispose() {
    categories.close();
  }

  Future getList() async {
    var db = await DBProvider.db.database;
    List<Map> maps = await db.query(_categoryTable);
    var lists = List<Category>();

    for (final map in maps) {
      final task = Category.fromMap(map);
      lists.add(task);
    }

    lists.sort((cat1, cat2) => cat1.order.compareTo(cat2.order));
    categories.add(lists);
  }

  Future save(Category category) async {
    var db = await DBProvider.db.database;
    await db.rawUpdate(
      'update $_categoryTable set name = ?, color_string = ?, "order" = ?, is_expand = ? where id = ?',
      [category.name, category.colorString, category.order, category.getExpand(), category.id],
    );
  }

  Future delete(Category category) async {
    var db = await DBProvider.db.database;
    await db.delete(_categoryTable, where: 'id = ?', whereArgs: [category.id]);
  }
}
