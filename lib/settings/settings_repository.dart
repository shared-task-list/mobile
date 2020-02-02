import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/settings.dart';

class SettingsRepository {
  final _tableName = 'settings';

  Future<Settings> getSettings() async {
    try {
      var db = await DBProvider.db.database;
      List<Map> maps = await db.query(_tableName);
      var lists = maps.map((map) => Settings.fromMap(map));

      return lists.first ?? Settings(defaultCategory: '', isShowCategories: true);
    } catch (e) {
      return Settings(defaultCategory: '', isShowCategories: true);
    }
  }

  Future saveSettings(Settings settings) async {
    var db = await DBProvider.db.database;
    final setts = await getSettings();
    final isExist = setts.id != null && setts.id != 0;

    if (isExist) {
      await db.update(_tableName, settings.toMap());
    } else {
      await db.insert(_tableName, settings.toMap());
    }
  }
}
