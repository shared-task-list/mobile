import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/settings/settings_screen.dart';
import 'package:shared_task_list/task_list/task_list_screen.dart';

import 'category_list/category_list_screen.dart';
import 'common/widget/ui.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  int _selectedIndex = 0;
  final _pages = <Widget>[
    TaskListScreen(),
    CategoryListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: _getItems(),
          backgroundColor: Constant.bgColor,
        ),
        tabBuilder: (BuildContext context, int index) {
          if (index >= _pages.length) {
            return null;
          }
          return CupertinoTabView(
            builder: (BuildContext context) {
              return _pages[index];
            },
          );
        },
      );
    }
    if (Platform.isAndroid) {
      return Scaffold(
        body: _pages.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: _getItems(),
          currentIndex: _selectedIndex,
          fixedColor: Colors.blue,
          onTap: _onItemTapped,
          backgroundColor: Constant.bgColor,
        ),
      );
    }
    return null;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> _getItems() {
    return <BottomNavigationBarItem>[
      _getItem('Tasks', Icon(Icons.format_list_bulleted)),
      _getItem('Categories', Ui.icon(CupertinoIcons.collections, Icons.category)),
      _getItem('Settings', Ui.icon(CupertinoIcons.settings, Icons.settings)),
    ];
  }

  BottomNavigationBarItem _getItem(String title, Widget icon) {
    return BottomNavigationBarItem(
//      icon: _getImage(imageName),
      icon: icon,
//      activeIcon: _getImage(imageName, isActive: true),
      title: Text(title),
    );
  }
}
