import 'package:expandable/expandable.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/join/join_screen.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/settings/settings_screen.dart';
import 'package:shared_task_list/task_detail/task_detail_screen.dart';
import 'package:shared_task_list/task_list/quick_add_dialog.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';

import 'color_set_dialog.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _bloc = TaskListBloc();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  String _defaultCategory = '';
  S _locale;
  Settings _settings;
  Future<bool> initFuture;

  _TaskListScreenState() {
    initFuture = _bloc.init();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    _bloc.init();
    _locale = S.of(context);
    Constant.noCategory = _locale.noCategory;
    double textWidth = MediaQuery.of(context).size.width - 80;

    _settings = Settings(defaultCategory: Constant.noCategory, isShowCategories: true);

    return FutureBuilder(
        future: initFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Ui.waitIndicator();
          }
          return Ui.scaffold(
            bar: Ui.appBar(
              title: Constant.taskList,
              rightButton: Ui.actionButton(Icons.refresh, () async {
                await _bloc.getTasks();
              }),
            ),
            body: Stack(
              children: [
                /*StreamBuilder<Settings>(
                  stream: _bloc.settings,
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }

                    _settings = snapshot.data;
                    return _buildList(context, textWidth);
                  },
                ),*/
                _buildList(context, textWidth),
                _buildMenuButton(context),
                _buildQuickAdd(context),
              ],
            ),
          );
        });
  }

  Widget _buildList(BuildContext context, double textWidth) {
    return StreamBuilder<Map<String, List<UserTask>>>(
      stream: _bloc.tasksMap,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Align(
            alignment: Alignment.center,
            child: Ui.waitIndicator(),
          );
        }

        final tasks = snapshot.data;
        var widgets = <Widget>[];

        tasks.forEach(
          (category, taskList) {
            if (taskList.isEmpty) {
              return;
            }

            List<Widget> tasks = taskList.map((task) => _buildListItem(context, task, textWidth)).toList();
            List<Widget> expandedWidgets = _buildExpandableWidgets(category, tasks);

            widgets.add(_buildExpandablePanel(category, expandedWidgets));
          },
        );

        widgets.add(SizedBox(height: 100));

        return Material(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: widgets,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildExpandableWidgets(String category, List<Widget> tasks) {
    return [
      Ui.flatButton('Add New', () {
        _defaultCategory = category;
        // TODO:  to func
        Ui.openDialog(
          context: context,
          dialog: FutureBuilder<List<Category>>(
              future: _bloc.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                final categories = snapshot.data;

                return QuickAddDialog(
                  categories: categories,
                  defaultCategory: _defaultCategory,
                  onSetName: (String title, String category) async {
                    _defaultCategory = category;
                    await _bloc.quickAdd(title, category);
                  },
                  onSetCategory: (String cat) => _defaultCategory = cat,
                );
              }),
        );
      }),
      ...tasks,
    ];
  }

  Widget _buildExpandablePanel(String category, List<Widget> expandedWidgets) {
    final ctrl = ExpandableController(initialExpanded: _settings.isShowCategories);

    return ExpandablePanel(
      theme: ExpandableThemeData(
        useInkWell: false,
        iconPadding: EdgeInsets.only(top: 32),
      ),
      controller: ctrl,
      header: Container(
        padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
        margin: EdgeInsets.only(top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              child: Icon(
                Icons.color_lens,
                size: 30,
              ),
              onTap: () {
                Ui.openDialog(
                  context: context,
                  dialog: ColorSetDialog(
                    onSetColor: (Color color) {
                      _bloc.setColorForCategory(category, color);
                    },
                  ),
                );
              },
            ),
            StreamBuilder<Map<String, Category>>(
                stream: _bloc.categoryMapStream,
                builder: (context, snapshot) {
                  return Text(
                    category,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: snapshot.hasData ? snapshot.data[category].getColor() : Colors.grey.shade600,
                    ),
                  );
                }),
            SizedBox(width: 10),
          ],
        ),
      ),
      expanded: Column(
        children: expandedWidgets,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, UserTask task, double textWidth) {
    return Material(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => TaskDetailScreen(task: task),
                ),
              );
            },
            child: StreamBuilder<Map<String, Category>>(
                stream: _bloc.categoryMapStream,
                builder: (context, snapshot) {
                  Color textColor = Colors.black;
                  Color backgroundTaskColor = Colors.white;

                  if (snapshot.hasData) {
                    var catColor = snapshot.data[task.category].getColor();
                    if (catColor != Colors.grey.shade600) {
                      final brightness = ThemeData.estimateBrightnessForColor(catColor);
                      textColor = brightness == Brightness.light ? Colors.black : Colors.white;
                      backgroundTaskColor = catColor;
                    }
                  }

                  return Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                    decoration: BoxDecoration(
                      color: backgroundTaskColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[400],
                          blurRadius: 1.0, // has the effect of softening the shadow
                          spreadRadius: 1.0, // has the effect of extending the shadow
                          offset: Offset(
                            1.0, // horizontal, move right 10
                            1.0, // vertical, move down 10
                          ),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: textWidth,
                          margin: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                          child: Text(
                            task.title,
                            style: TextStyle(fontSize: 18, color: textColor),
                          ),
                        ),
                        /*Container(
                        margin: EdgeInsets.only(left: 16, bottom: 8, top: 4),
                        child: Text(
                          task.author + ' - ' + time,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),*/
                      ],
                    ),
                  );
                }),
          ),
          Container(
            height: 32,
            width: 32,
            margin: EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: IconButton(
              iconSize: 16,
              color: Colors.white,
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.done),
              onPressed: () async {
                await _bloc.remove(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return FabCircularMenu(
      child: Container(),
      animationDuration: const Duration(milliseconds: 400),
      options: <Widget>[
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () async {
            await _bloc.exit();
            Ui.route(context, JoinScreen(), withHistory: false);
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Ui.route(context, SettingsScreen());
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Ui.route(context, TaskDetailScreen());
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            Ui.openDialog(
              context: context,
              dialog: TextFieldDialog(
                savePressed: (String newCategory) => _bloc.createNewCategory(newCategory),
                title: _locale.newCategory,
                labelText: null,
                hintText: _locale.categoryName,
              ),
            );
          },
        ),
      ],
      fabColor: Colors.blue,
      ringColor: Colors.blue.shade100,
      ringWidth: 48,
      ringDiameter: 50 * 5.0,
    );
  }

  Widget _buildQuickAdd(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 90,
      child: FloatingActionButton(
        heroTag: 'quickAdd',
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Ui.openDialog(
            context: context,
            dialog: FutureBuilder<List<Category>>(
                future: _bloc.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  final categories = snapshot.data;

                  return QuickAddDialog(
                    categories: categories,
                    defaultCategory: _defaultCategory.isEmpty ? _settings.defaultCategory : _defaultCategory,
                    onSetName: (String title, String category) async {
                      _defaultCategory = category;
                      await _bloc.quickAdd(title, category);
                    },
                    onSetCategory: (String cat) => _defaultCategory = cat,
                  );
                }),
          );
        },
      ),
    );
  }
}
