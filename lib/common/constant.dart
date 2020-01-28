import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';

class Constant {
  static final Constant _singleton = Constant._internal();
  static final url = GlobalConfiguration().getString("url");

  factory Constant() {
    return _singleton;
  }

  Constant._internal();

  static const dbName = 'shared_task.sqlite';
  static const child = "tasks";
  static const taskListKey = "TaskList";
  static const passwordKey = "Password";
  static const authorKey = "Author";
  static const authorUidKey = "AuthorUid";
  static const noCategory = "Без категории";
  static const serviceTaskComment = "service task";
  static const dateFormat = 'dd MMM HH:MM';
  static final dateFormatter = DateFormat(dateFormat);
  static String password = "";
  static String userName = "";
  static String taskList = "";
}

class AppData {
  static String password = "";
  static String userName = "";
  static String taskList = "";
  static List<String> categories = List<String>();
}

List<String> categories = List<String>();
