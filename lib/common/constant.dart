import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/common/extension/color_extension.dart';

class Constant {
  static final Constant _singleton = Constant._internal();
  static final url = GlobalConfiguration().getValue<String>("url");
  static final double dialogPadding = 8;
  static final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0));

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
  static const serviceTaskComment = "service task";
  static const dateFormat = 'dd MMMM HH:MM';
  static final dateFormatter = DateFormat(dateFormat);
  static String password = "";
  static String userName = "";
  static String taskList = "";
  static String noCategory = "";
  static Color bgColor = Colors.white;
  static Color primaryColor = Colors.cyan.shade800;
  static Color accentColor = Colors.cyan.shade800;
  static Color defaultCategoryColor = Colors.grey.shade600;

  static Color getColor(Color forDark, Color forLight) {
    final brightness = ThemeData.estimateBrightnessForColor(Constant.bgColor);
    return brightness == Brightness.light ? forLight : forDark;
  }

  static Color getTextColor(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }
}

class AppData {
  static String password = "";
  static String userName = "";
  static String taskList = "";
  static Category noCategory = Category(
    name: Constant.noCategory,
    colorString: Constant.defaultCategoryColor.toRgbString(),
  );
}
