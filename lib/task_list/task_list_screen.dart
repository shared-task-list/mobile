import 'dart:io';

import 'package:cool_ui/cool_ui.dart';
import 'package:expandable/expandable.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_list/quick_add_dialog.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';
import 'package:shared_task_list/task_list/task_list_item.dart';

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

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initFuture = _bloc.init();
    _locale = S.of(context);
    Constant.noCategory = _locale.noCategory;
    double textWidth = MediaQuery.of(context).size.width - 80;

    _settings = Settings(
      defaultCategory: Constant.noCategory,
      isShowCategories: true,
      isShowQuickAdd: true,
    );

    return FutureBuilder(
        future: initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Ui.waitIndicator();
          }
          return Ui.scaffold(
            bar: Ui.appBar(
              title: Constant.taskList,
              leftButton: Ui.actionButton(Ui.icon(CupertinoIcons.refresh, Icons.refresh), () async {
                await _bloc.getTasks();
              }),
              rightButton: CupertinoPopoverButton(
                child: Ui.icon(CupertinoIcons.ellipsis, Icons.more_vert),
                popoverWidth: 250,
                popoverBuild: (ctx) {
                  return SizedBox(
                    width: 250.0,
                    height: 140.0,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(_locale.newTask),
                          leading: Ui.icon(CupertinoIcons.add, Icons.add, color: Colors.teal.shade800, size: 40),
                          onTap: () {
                            Navigator.pop(ctx);
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
                        ListTile(
                          title: Text(_locale.newCategory),
                          leading: Ui.icon(CupertinoIcons.add_circled, Icons.add_circle_outline, color: Colors.teal.shade800, size: 40),
                          onTap: () {
                            Navigator.pop(ctx);
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
                        ),
                      ],
                    ),
                  );
                },
              ),
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
          return Ui.waitIndicator();
        }

        final categories = _bloc.categoryMap.values.toList();

        if (categories.isNotEmpty) {
          categories.sort((cat1, cat2) => cat1.order?.compareTo(cat2.order ?? 0));
        }

        var widgets = <Widget>[];

        for (final category in categories) {
          var taskList = snapshot.data[category.name];

          if (taskList == null || taskList.isEmpty) {
            continue;
          }

          List<Widget> tasks = taskList.map((task) => TaskListItem(bloc: _bloc, task: task, textWidth: textWidth)).toList();
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

  Widget _buildQuickAdd(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
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
      fit: StackFit.expand,
      children: [
        _buildList(context, textWidth),
        StreamBuilder<Settings>(
            stream: _bloc.settings,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data.isShowQuickAdd) {
                return _buildQuickAdd(context);
              }

              return Container();
            }),
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
