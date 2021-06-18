import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/list_of_lists/list_of_lists_ctrl.dart';
import 'package:shared_task_list/model/task_list.dart';

import 'add_list_dialog.dart';

class ListOfListsScreen extends StatelessWidget {
  final ListOfListsCtrl controller = Get.put(ListOfListsCtrl());
  late S _locale;

  @override
  Widget build(BuildContext context) {
    _locale = S.of(context);

    return Ui.scaffold(
      bar: Ui.appBar(title: _locale.my_lists),
      body: Material(
        child: _buildBody(context),
        color: Colors.transparent,
      ),
      bodyColor: Constant.bgColor,
      float: Platform.isAndroid
          ? FloatingActionButton(
              backgroundColor: Constant.accentColor,
              child: Icon(
                Icons.add,
                color: Constant.getTextColor(Constant.accentColor),
              ),
              onPressed: () {
                _showAddDialog(context);
              })
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        Obx(() => _buildList(context)),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.lists.length,
      itemBuilder: (ctx, index) {
        final list = controller.lists[index];

        return ListTile(
          trailing: list.name == Constant.taskList
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  // child: Text(_locale.current),
                  child: const Text('current'),
                )
              : IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _showConfirmDeleteDialog(context, list);
                  },
                ),
          title: Text(list.name),
          onTap: () async {
            if (list.name == Constant.taskList) {
              return;
            }

            await controller.open(list);
            Flushbar(
              title: _locale.current_list_changed,
              message: _locale.current_list_changed_to + list.name,
              duration: Duration(seconds: 3), // todo: to const
            )..show(context);
          },
        );
      },
    );
  }

  Future _showConfirmDeleteDialog(BuildContext context, TaskList list) async {
    await Ui.showAlert(
      builder: (ctx) {
        return Ui.alertDialog(
          title: _locale.delete_list + list.name,
          child: Text(_locale.task_delete_too),
          actions: [
            Ui.alertAction(
              context: ctx,
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              text: _locale.cancel,
              isDestructive: true,
            ),
            Ui.alertAction(
              context: ctx,
              onPressed: () async {
                Navigator.of(ctx).pop();
                await controller.deleteList(list);

                Flushbar(
                  title: _locale.delete,
                  message: "You list ${list.name} was deleted",
                  duration: Duration(seconds: 3),
                )..show(context);
              },
              text: _locale.delete,
            ),
          ],
          context: ctx,
        );
      },
      context: context,
    );
  }

  Future _showAddDialog(BuildContext context) async {
    await Ui.openDialog(
      context: context,
      dialog: AddListDialog(
        savePressed: (String name, String password) async {
          // если уже есть в базе отказываем
          bool isExistInDb = await controller.isExistInDb(name, password);

          if (isExistInDb) {
            Flushbar(
              title: _locale.create,
              message: "List $name already exist. Please change name or password",
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            )..show(context);
            return;
          }

          // если нет в базе, но есть на сервере - создаем только в базе
          // если на сервере нет - создаем там
          bool isExist = await controller.isExistList(name, password);

          controller.createList(name, password, !isExist);
          Flushbar(
            title: _locale.create,
            message: "New List $name was created",
            duration: Duration(seconds: 3),
          )..show(context);
        },
        labelText: '',
        hintText: _locale.taskListName,
        title: _locale.new_list,
      ),
    );
  }
}
