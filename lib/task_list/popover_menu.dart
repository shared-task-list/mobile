import 'dart:io';

import 'package:cool_ui/cool_ui.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/task_detail/task_detail_screen.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';

enum MenuItem { addNew, addCategory }

class PopoverMenu extends StatelessWidget {
  const PopoverMenu({
    Key key,
    @required TaskListBloc bloc,
    @required this.rootContext,
  })  : _bloc = bloc,
        super(key: key);

  final TaskListBloc _bloc;
  final BuildContext rootContext;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(rootContext);

    if (Platform.isIOS) {
      return _buildCupertinoPopoverButton(locale, context);
    }

    return _buildPopupMenu(locale, context);
  }

  Widget _buildPopupMenu(S locale, BuildContext context) {
    return PopupMenuButton<MenuItem>(
      onSelected: (MenuItem item) {
        switch (item) {
          case MenuItem.addNew:
            Ui.route(rootContext, TaskDetailScreen());
            break;
          case MenuItem.addCategory:
            _openCategoryDialog(context, locale);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<MenuItem>(
          value: MenuItem.addNew,
          child: Text(locale.newTask),
        ),
        PopupMenuItem<MenuItem>(
          value: MenuItem.addCategory,
          child: Text(locale.newCategory),
        ),
      ],
    );
  }

  Widget _buildCupertinoPopoverButton(S locale, BuildContext context) {
    return CupertinoPopoverButton(
      child: Ui.icon(CupertinoIcons.ellipsis, Icons.more_vert),
      popoverWidth: 250,
      popoverBuild: (ctx) {
        return SizedBox(
          width: 250.0,
          height: 140.0,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(locale.newTask),
                leading: Ui.icon(CupertinoIcons.add, Icons.add, color: Colors.teal.shade800, size: 40),
                onTap: () {
                  Navigator.pop(ctx);
                  Ui.route(rootContext, TaskDetailScreen());
                },
              ),
              ListTile(
                title: Text(locale.newCategory),
                leading: Ui.icon(CupertinoIcons.add_circled, Icons.add_circle_outline, color: Colors.teal.shade800, size: 40),
                onTap: () {
                  Navigator.pop(ctx);
                  _openCategoryDialog(context, locale);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCategoryDialog(BuildContext context, S locale) {
    Ui.openDialog(
      context: context,
      dialog: TextFieldDialog(
        savePressed: (String newCategory) {
          _bloc.createNewCategory(newCategory);
          Flushbar(
            title: "Create",
            message: "Category $newCategory was created!",
            duration: Duration(seconds: 3),
          )..show(rootContext);
        },
        title: locale.newCategory,
        labelText: null,
        hintText: locale.categoryName,
      ),
    );
  }
}
