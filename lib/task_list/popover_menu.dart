import 'package:flutter/material.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/task_detail/task_detail_screen.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';

enum MenuItem { addNew, addCategory }

class PopoverMenu extends StatelessWidget {
  const PopoverMenu({
    Key? key,
    required TaskListBloc bloc,
    required this.rootContext,
  })   : _bloc = bloc,
        super(key: key);

  final TaskListBloc _bloc;
  final BuildContext rootContext;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(rootContext);

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

  void _openCategoryDialog(BuildContext context, S locale) {
    Ui.openDialog(
      context: context,
      dialog: TextFieldDialog(
        savePressed: (String newCategory) {
          _bloc.createNewCategory(newCategory);
          // Flushbar(
          //   title: "Create",
          //   message: "Category $newCategory was created!",
          //   duration: Duration(seconds: 3),
          // )..show(rootContext);
        },
        title: locale.newCategory,
        labelText: '',
        hintText: locale.categoryName,
      ),
    );
  }
}
