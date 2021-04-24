import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/list_of_lists/list_of_lists_bloc.dart';
import 'package:shared_task_list/model/task_list.dart';

import 'add_list_dialog.dart';

class ListOfListsScreen extends StatelessWidget {
  final _bloc = ListOfListsBloc();
  late S _locale;

  @override
  Widget build(BuildContext context) {
    _bloc.getTaskLists();
    _locale = S.of(context);

    return Ui.scaffold(
      bar: Ui.appBar(
        title: _locale.my_lists,
        rightButton: Ui.actionButton(Icon(Icons.add), () {
          _showAddDialog(context);
        }),
      ),
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
        StreamBuilder<List<TaskList>>(
          stream: _bloc.taskLists,
          builder: (BuildContext context, AsyncSnapshot<List<TaskList>> snapshot) {
            if (!snapshot.hasData) {
              return Ui.waitIndicator();
            }

            final taskList = snapshot.data ?? [];

            return ListView.builder(
              shrinkWrap: true,
              itemCount: taskList.length,
              itemBuilder: (ctx, index) {
                final list = taskList[index];

                return ListTile(
                  trailing: list.name == Constant.taskList
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          // child: Text('(${_locale.current})'),
                          child: Text('current'),
                        )
                      : IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _showConfirmDeleteDialog(context, list);
                          },
                        ),
                  title: Text(list.name),
//                  subtitle: list.name == Constant.taskList ? Text('(${_locale.current})') : null,
                  onTap: () async {
                    if (list.name == Constant.taskList) {
                      return;
                    }
                    await _bloc.open(list);
                    _bloc.getTaskLists();
                    // Flushbar(
                    //   title: _locale.current_list_changed,
                    //   message: _locale.current_list_changed_to + list.name,
                    //   duration: Duration(seconds: 3),
                    // )..show(context);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showConfirmDeleteDialog(BuildContext context, TaskList list) {
    Ui.showAlert(
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
              onPressed: () {
                _bloc.deleteList(list);
                Navigator.of(ctx).pop();
                // Flushbar(
                //   title: _locale.delete,
                //   message: "You list ${list.name} was deleted",
                //   duration: Duration(seconds: 3),
                // )..show(context);
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
          bool isExistInDb = await _bloc.isExistInDb(name, password);

          if (isExistInDb) {
            // Flushbar(
            //   title: _locale.create,
            //   message: "List $name already exist. Please change name or password",
            //   duration: Duration(seconds: 3),
            //   backgroundColor: Colors.red,
            // )..show(context);
            return;
          }

          // если нет в базе, но есть на сервере - создаем только в базе
          // если на сервере нет - создаем там
          bool isExist = await _bloc.isExistList(name, password);

          _bloc.createList(name, password, !isExist);
          // Flushbar(
          //   title: _locale.create,
          //   message: "New List $name was created",
          //   duration: Duration(seconds: 3),
          // )..show(context);
        },
        labelText: '',
        hintText: _locale.taskListName,
        title: _locale.new_list,
      ),
    );
  }
}
