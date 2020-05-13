import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/join/join_screen.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_screen.dart';
import 'package:shared_task_list/task_list/quick_add_dialog.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';

import '../common/widget/color_set_dialog.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _bloc = TaskListBloc();
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
            body: FutureBuilder<Widget>(
              future: _buildBody(context, textWidth),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Ui.waitIndicator();
                }

                return snapshot.data;
              },
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

        final categories = _bloc.categoryMap.values.toList();
        categories.sort((cat1, cat2) => cat1.order?.compareTo(cat2.order ?? 0));
        var widgets = <Widget>[];

        for (final category in categories) {
          var taskList = snapshot.data[category.name];

          if (taskList == null || taskList.isEmpty) {
            continue;
          }

          List<Widget> tasks = taskList.map((task) => _buildListItem(context, task, textWidth)).toList();
          List<Widget> expandedWidgets = _buildExpandableWidgets(context, category.name, tasks);

          widgets.add(_buildExpandablePanel(context, category.name, expandedWidgets));
        }

        widgets.add(SizedBox(height: 100));

        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              children: widgets,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildExpandableWidgets(BuildContext context, String category, List<Widget> tasks) {
    return [
      Ui.flatButton('Add New', () async {
        _defaultCategory = category;
        await _openQuickAdd(context);
      }),
      ...tasks,
    ];
  }

  Future _openQuickAdd(BuildContext context) async {
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
                Flushbar(
                  title: "Create",
                  message: "Task $title was created!",
                  duration: Duration(seconds: 3),
                )..show(context);
              },
              onSetCategory: (String cat) => _defaultCategory = cat,
            );
          }),
    );
  }

  Widget _buildExpandablePanel(BuildContext context, String category, List<Widget> expandedWidgets) {
    final ctrl = ExpandableController(initialExpanded: _settings.isShowCategories);
    /*ctrl.addListener(() async {
      await _bloc.setCategoryExpand(category);
    });*/

    return ExpandablePanel(
      theme: ExpandableThemeData(
        useInkWell: false,
        iconPadding: EdgeInsets.only(top: 32),
      ),
      controller: ctrl,
      header: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
        margin: const EdgeInsets.only(top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              child: Icon(
                Icons.color_lens,
                size: 30,
                color: Constant.getColor(Colors.white, Colors.blue.shade600),
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
                  if (snapshot.hasData) {
//                    ctrl.expanded = snapshot.data[category].getExpand() == 1;
                  }
                  return Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        category,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: snapshot.hasData ? snapshot.data[category].getColor() : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }),
            const SizedBox(width: 10),
          ],
        ),
      ),
      expanded: Column(
        children: expandedWidgets,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, UserTask task, double textWidth) {
    bool hasComment = task.comment != null && task.comment.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () => Ui.route(context, TaskDetailScreen(task: task)),
            child: StreamBuilder<Map<String, Category>>(
                stream: _bloc.categoryMapStream,
                builder: (context, snapshot) {
                  Color textColor = Colors.black;
                  Color backgroundTaskColor = Colors.white;

                  if (snapshot.hasData) {
                    Color catColor = snapshot.data[task.category].getColor();

                    if (catColor != Colors.grey.shade600) {
                      final brightness = ThemeData.estimateBrightnessForColor(catColor);
                      textColor = brightness == Brightness.light ? Colors.black : Colors.white;
                      backgroundTaskColor = catColor;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: backgroundTaskColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[400],
                          blurRadius: 1.0, // has the effect of softening the shadow
                          spreadRadius: 1.0, // has the effect of extending the shadow
                          offset: const Offset(
                            1.0, // horizontal, move right 10
                            1.0, // vertical, move down 10
                          ),
                        ),
                      ],
                      borderRadius: const BorderRadius.all(const Radius.circular(20)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: hasComment ? textWidth - 35 : textWidth,
                          margin: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                          child: Text(
                            task.title,
                            style: TextStyle(fontSize: 18, color: textColor),
                          ),
                        ),
                        if (hasComment)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Ui.icon(CupertinoIcons.conversation_bubble, Icons.chat_bubble_outline),
                          ),
                      ],
                    ),
                  );
                }),
          ),
          SizedBox(
            width: 35,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'doneButton${task.uid}',
              backgroundColor: Colors.cyan.shade800,
              child: const Icon(Icons.done, size: 20),
              onPressed: () async {
                await _bloc.remove(task);
                Flushbar(
                  title: "Done",
                  message: "Task ${task.title} is complete!",
                  duration: Duration(seconds: 3),
                )..show(context);
              },
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    const labelBackground = const Color.fromRGBO(0, 0, 0, 0.6);
    const labelTextStyle = const TextStyle(fontWeight: FontWeight.w500, color: Colors.white);

    return SpeedDial(
      marginBottom: 40,
      marginRight: 32,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      overlayOpacity: 0,
      children: [
        SpeedDialChild(
          child: Icon(Icons.exit_to_app, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () async {
            await _bloc.exit();
            Ui.route(context, JoinScreen(), withHistory: false);
          },
          label: _locale.exit,
          labelStyle: labelTextStyle,
          labelBackgroundColor: labelBackground,
        ),
        SpeedDialChild(
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () => Ui.route(context, TaskDetailScreen()),
          label: _locale.newTask,
          labelStyle: labelTextStyle,
          labelBackgroundColor: labelBackground,
        ),
        SpeedDialChild(
          child: Icon(Icons.add_circle_outline, color: Colors.white),
          backgroundColor: Colors.purple,
          onTap: () {
            Ui.openDialog(
              context: context,
              dialog: TextFieldDialog(
                savePressed: (String newCategory) {
                  _bloc.createNewCategory(newCategory);
                  Flushbar(
                    title: "Create",
                    message: "Category $newCategory was created!",
                    duration: Duration(seconds: 3),
                  )..show(context);
                },
                title: _locale.newCategory,
                labelText: null,
                hintText: _locale.categoryName,
              ),
            );
          },
          label: _locale.newCategory,
          labelStyle: labelTextStyle,
          labelBackgroundColor: labelBackground,
        ),
      ],
    );
  }

  Widget _buildQuickAdd(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 90,
      child: FloatingActionButton(
        heroTag: 'quickAdd',
        child: Icon(Icons.add),
        backgroundColor: Colors.cyan.shade800,
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

  Future<Widget> _buildBody(BuildContext context, double textWidth) async {
    Widget body = Stack(
      children: [
        _buildList(context, textWidth),
        _buildMenuButton(context),
        _buildQuickAdd(context),
      ],
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bgName = prefs.getString('bg_name') ?? '';

    if (bgName.isEmpty) {
      return Container(child: body, color: Constant.bgColor);
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, bgName);
    var img = FileImage(File(path));

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: img,
          fit: BoxFit.cover,
        ),
      ),
      child: body,
    );
  }
}
