import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/extension/string_extension.dart';
import 'package:shared_task_list/join/join_screen.dart';
import 'package:uuid/uuid.dart';

import 'common/constant.dart';
import 'generated/l10n.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cfg = await GlobalConfiguration().loadFromAsset("settings");
  final FirebaseApp _ = await Firebase.initializeApp(
    name: 'GeneralShoppingList',
    options: FirebaseOptions(
      appId: cfg.getValue("fb_app_id"),
      apiKey: cfg.getValue("api_key"),
      messagingSenderId: cfg.getValue("fb_sender_id"),
      projectId: cfg.getValue("fb_project_id"),
      databaseURL: cfg.getValue("url"),
    ),
  );

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
        final screen = (Constant.taskList.isEmpty && Constant.password.isEmpty) ? JoinScreen() : Home();

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
      },
    );
  }

  Future<SharedPreferences> _getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Constant.taskList = prefs.getString(Constant.taskListKey) ?? '';
    Constant.password = prefs.getString(Constant.passwordKey) ?? '';
    Constant.userName = prefs.getString(Constant.authorKey) ?? '';

    String userUUid = prefs.getString(Constant.authorUidKey) ?? '';

    if (userUUid.isEmpty) {
      prefs.setString(Constant.authorUidKey, Uuid().v4());
    }

    String colorString = prefs.getString('bg_color') ?? '';
    Constant.bgColor = colorString.isEmpty ? Colors.white : colorString.toColor();

    return prefs;
  }
}
