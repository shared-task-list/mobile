import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/color_picker_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/task_list/popover_menu.dart';
import 'package:shared_task_list/task_list/quick_add_dialog.dart';
import 'package:shared_task_list/task_list/task_list_ctrl.dart';
import 'package:shared_task_list/task_list/task_list_item.dart';

class TaskListScreen extends StatelessWidget {
  final TaskListCtrl controller = Get.put(TaskListCtrl());
  String _defaultCategory = '';
  S _locale = S();

  @override
  Widget build(BuildContext context) {
    _locale = S.of(context);
    double textWidth = MediaQuery.of(context).size.width - 80;

    return Ui.scaffold(
      bar: Ui.appBar(
        title: Constant.taskList,
        leftButton: Ui.actionButton(const Icon(Icons.refresh), () async {
          await controller.load();
        }),
        rightButton: PopoverMenu(rootContext: context),
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
  }

  Widget _buildList(BuildContext context, double textWidth, List<Category> categories) {
    final widgets = <ExpansionPanel>[];

    for (final category in categories) {
      final taskList = controller.categoryTaskMap[category];

      if (taskList == null || taskList.isEmpty) {
        continue;
      }

      List<Widget> tasks = taskList.map((task) => TaskListItem(task: task, textWidth: textWidth)).toList();
      ExpansionPanel expandedWidgets = _buildExpandableWidgets(context, category, tasks);

      widgets.add(expandedWidgets);
    }

    if (widgets.isEmpty) {
      return Container();
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
              expansionCallback: (i, isOpen) => categories[i].isExpand.value = !isOpen,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  ExpansionPanel _buildExpandableWidgets(BuildContext context, Category category, List<Widget> tasks) {
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
            const SizedBox(width: 1),
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
      isExpanded: category.isExpand.value,
      canTapOnHeader: true,
    );
  }

  Future _openQuickAdd(BuildContext context) async {
    await Ui.openDialog(
      context: context,
      dialog: QuickAddDialog(
        categories: controller.categories,
        defaultCategory: _defaultCategory,
        onSetName: (String title, String category) async {
          _defaultCategory = category;
          await controller.quickAdd(title, category);

          Flushbar(
            title: "Create",
            message: "Task $title was created!",
            duration: const Duration(seconds: 3),
          )..show(context);
        },
        onSetCategory: (String cat) => _defaultCategory = cat,
      ),
    );
  }

  Widget _buildQuickAdd(BuildContext context, Settings settings) {
    if (!settings.isShowQuickAdd) {
      return Container();
    }

    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton(
        heroTag: 'quickAdd',
        child: const Icon(Icons.add),
        backgroundColor: Constant.accentColor,
        onPressed: () async {
          await controller.getSettings();
          await Ui.openDialog(
            context: context,
            dialog: QuickAddDialog(
              categories: controller.categories,
              defaultCategory: controller.settings.value.defaultCategory == '' ? _locale.noCategory : controller.settings.value.defaultCategory,
              onSetName: (String title, String category) async {
                _defaultCategory = category;
                await controller.quickAdd(title, category);
              },
              onSetCategory: (String cat) => _defaultCategory = cat,
            ),
          );
        },
      ),
    );
  }

  Future<Widget> _buildBody(BuildContext context, double textWidth) async {
    Widget body = Stack(
      fit: StackFit.expand,
      children: [
        Obx(() => _buildList(context, textWidth, controller.categories)),
        Obx(() => _buildQuickAdd(context, controller.settings.value)),
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
        applyFunction: (Color color) async => await controller.setColorForCategory(category, color),
      ),
    );
  }
}
