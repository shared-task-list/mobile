import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/join/join_screen.dart';
import 'package:shared_task_list/task_list/task_list_screen.dart';
import 'package:uuid/uuid.dart';

import 'common/constant.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("settings");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ));
    }
    return _getApp();
  }

  Widget _getApp() {
    return FutureBuilder(
      future: _getPreferences(),
      builder: (ctx, snapshot) {
        final screen = (Constant.taskList.isEmpty && Constant.password.isEmpty) ? JoinScreen() : TaskListScreen();

        if (Platform.isIOS) {
          return CupertinoApp(
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: screen,
          );
        } else {
          return MaterialApp(
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: screen,
          );
        }
      },
    );
  }

  Future<SharedPreferences> _getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Constant.taskList = prefs.getString(Constant.taskListKey) ?? "";
    Constant.password = prefs.getString(Constant.passwordKey) ?? "";
    Constant.userName = prefs.getString(Constant.authorKey) ?? "";

    String userUUid = prefs.getString(Constant.authorUidKey) ?? '';

    if (userUUid.isEmpty) {
      prefs.setString(Constant.authorUidKey, Uuid().v4());
    }

    return prefs;
  }
}
