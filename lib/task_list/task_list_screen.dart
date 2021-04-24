import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/common/widget/color_picker_dialog.dart';
import 'package:shared_task_list/task_list/popover_menu.dart';
import 'package:shared_task_list/task_list/quick_add_dialog.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';
import 'package:shared_task_list/task_list/task_list_item.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _defaultCategory = '';
  S _locale = S();
  List<Category> _isOpen = [];
  late Future<bool> initFuture;
  final _bloc = TaskListBloc();

  _TaskListScreenState() {
    Constant.noCategory = _locale.noCategory;
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
    double textWidth = MediaQuery.of(context).size.width - 80;

    return FutureBuilder(
        future: initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Ui.waitIndicator();
          }
          return Ui.scaffold(
            bar: Ui.appBar(
              title: Constant.taskList,
              leftButton: Ui.actionButton(const Icon(Icons.refresh), () async {
                await _bloc.load();
              }),
              rightButton: PopoverMenu(bloc: _bloc, rootContext: context),
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
    return StreamBuilder<Map<Category, List<UserTask>>>(
      stream: _bloc.categoryTaskMapStream,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Ui.waitIndicator();
        }

        var categoryTaskMap = snapshot.data;

        if (categoryTaskMap == null) {
          categoryTaskMap = {
            AppData.noCategory: [],
          };
        }

        final categories = _bloc.categories;
        final widgets = <ExpansionPanel>[];
        _isOpen = [];

        for (var i = 0; i < categories.length; i++) {
          final category = categories[i];
          final taskList = categoryTaskMap[category];

          if (taskList == null || taskList.isEmpty) {
            continue;
          }

          _isOpen.add(category);
          List<Widget> tasks = taskList.map((task) => TaskListItem(bloc: _bloc, task: task, textWidth: textWidth)).toList();
          ExpansionPanel expandedWidgets = _buildExpandableWidgets(context, category, tasks, i);

          widgets.add(expandedWidgets);
        }

        return Material(
          color: Constant.bgColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                ExpansionPanelList(
                  elevation: 0,
                  dividerColor: Constant.bgColor,
                  children: widgets,
                  expansionCallback: (i, isOpen) => setState(() => _isOpen[i].isExpand = !isOpen),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  ExpansionPanel _buildExpandableWidgets(BuildContext context, Category category, List<Widget> tasks, int i) {
    final categoryColor = category.getColor();

    return ExpansionPanel(
      backgroundColor: Constant.bgColor,
      headerBuilder: (ctx, isOpen) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.color_lens, color: categoryColor),
              onPressed: () async => await openColorDialog(context, category),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
            ),
            SizedBox(width: 1),
          ],
        );
      },
      body: Column(
        children: [
          TextButton.icon(
            icon: Icon(Icons.add, color: categoryColor),
            label: Text(
              _locale.add_new,
              style: TextStyle(color: category.getColor()),
            ),
            onPressed: () async {
              _defaultCategory = category.name;
              await _openQuickAdd(context);
            },
          ),
          ...tasks,
        ],
      ),
      isExpanded: _isOpen[i].isExpand,
      canTapOnHeader: true,
    );
  }

  Future _openQuickAdd(BuildContext context) async {
    Ui.openDialog(
      context: context,
      dialog: QuickAddDialog(
        categories: _bloc.categories,
        defaultCategory: _defaultCategory,
        onSetName: (String title, String category) async {
          _defaultCategory = category;
          await _bloc.quickAdd(title, category);
          // Flushbar(
          //   title: "Create",
          //   message: "Task $title was created!",
          //   duration: Duration(seconds: 3),
          // )..show(context);
        },
        onSetCategory: (String cat) => _defaultCategory = cat,
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
        backgroundColor: Constant.accentColor,
        onPressed: () async {
          await _bloc.getSettings();
          await Ui.openDialog(
            context: context,
            dialog: StreamBuilder<Settings>(
                stream: _bloc.settings,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  final settingsCategory = snapshot.data?.defaultCategory ?? Constant.noCategory;
                  final cat = _defaultCategory.isEmpty ? settingsCategory : _defaultCategory;
                  List<Category> addCats = [];
                  int cindex = _bloc.categories.indexWhere((c) => c.name == Constant.noCategory);

                  if (cindex == -1) {
                    addCats.add(AppData.noCategory);
                  }

                  addCats.addAll(_bloc.categories);

                  return QuickAddDialog(
                    categories: addCats,
                    defaultCategory: cat,
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
              if (!snapshot.hasData || snapshot.data == null) {
                return Container();
              }

              if (snapshot.data!.isShowQuickAdd) {
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
    final img = FileImage(File(path));

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

  Future openColorDialog(BuildContext context, Category category) async {
    return await Ui.openDialog(
      context: context,
      dialog: ColorPickerDialog(
        applyFunction: (Color color) async => await _bloc.setColorForCategory(category, color),
      ),
    );
  }
}
