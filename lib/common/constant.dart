import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';

class Constant {
  static final Constant _singleton = Constant._internal();
  static final url = GlobalConfiguration().getString("url");
  static final double dialogPadding = Platform.isIOS ? 24 : 8;
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
  static const noCategory = "No Category";
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
//  static List<String> categories = List<String>();
}

List<String> categories = List<String>();
