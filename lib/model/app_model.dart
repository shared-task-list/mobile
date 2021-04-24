import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';

class ListInitData {
  List<UserTask> tasks = [];
  List<Category> categories = [];
  Settings settings = Settings.empty();
}
