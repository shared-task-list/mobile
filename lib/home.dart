import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/list_of_lists/list_of_lists_screen.dart';
import 'package:shared_task_list/settings/settings_screen.dart';
import 'package:shared_task_list/task_list/task_list_screen.dart';

import 'category_list/category_list_screen.dart';
import 'generated/l10n.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  late S _locale;
  int _selectedIndex = 0;
  late TaskListScreen _tastListScreen = TaskListScreen();
  late CategoryListScreen _categoryListScreen = CategoryListScreen();
  late ListOfListsScreen _listsScreen = ListOfListsScreen();
  late SettingsScreen _settingsScreen = SettingsScreen();

  @override
  Widget build(BuildContext context) {
    _locale = S.of(context);

    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _getItems(),
        currentIndex: _selectedIndex,
        fixedColor: Constant.primaryColor,
        onTap: _onItemTapped,
        backgroundColor: Constant.bgColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return _tastListScreen;
      case 1:
        return _categoryListScreen;
      case 2:
        return _listsScreen;
      case 3:
        return _settingsScreen;
      default:
        return Container();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> _getItems() {
    return <BottomNavigationBarItem>[
      _getItem(_locale.tasks, const Icon(Icons.format_list_bulleted)),
      _getItem(_locale.categories, const Icon(Icons.category)),
      _getItem(_locale.my_lists, const Icon(Icons.view_list)),
      _getItem(_locale.settings, const Icon(Icons.settings)),
    ];
  }

  BottomNavigationBarItem _getItem(String title, Widget icon) {
    return BottomNavigationBarItem(
      icon: icon,
      label: title,
    );
  }
}
