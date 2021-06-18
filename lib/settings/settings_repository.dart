import 'package:rxdart/rxdart.dart';
import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/model/settings.dart';

class SettingsRepository {
  final _tableName = 'settings';
  final sesstingsStream = BehaviorSubject<Settings>();
  late Settings setts;

  Future<Settings> getSettings() async {
    try {
      final db = await DBProvider.db.database;
      List<Map<String, dynamic>> maps = await db.query(_tableName);

      setts = maps.map((map) => Settings.fromMap(map)).first;
    } catch (e) {
      setts = Settings.empty();
    }

    sesstingsStream.add(setts);
    return setts;
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

  void dispose() {
    sesstingsStream.close();
  }
}
