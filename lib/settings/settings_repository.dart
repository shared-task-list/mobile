import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/settings.dart';

class SettingsRepository {
  final _tableName = 'settings';

  Future<Settings> getSettings() async {
    try {
      var db = await DBProvider.db.database;
      List<Map<String, dynamic>> maps = await db.query(_tableName);
      final lists = maps.map((map) => Settings.fromMap(map));

      return lists.isNotEmpty ? lists.first : Settings.empty();
    } catch (e) {
      return Settings.empty();
    }
  }

  Future saveSettings(Settings settings) async {
    var db = await DBProvider.db.database;
    // final setts = await getSettings();
    // final isExist = setts.id != 0;

    db.delete(_tableName);

    // if (isExist) {
    // await db.update(_tableName, settings.toMap());
    // } else {
    await db.insert(_tableName, settings.toMap());
    // }
  }
}
