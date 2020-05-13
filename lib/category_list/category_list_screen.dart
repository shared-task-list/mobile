import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/category_list/category_list_bloc.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/model/category.dart';

class CategoryListScreen extends StatelessWidget {
  final _bloc = CategoryListBloc();

  @override
  Widget build(BuildContext context) {
    _bloc.getCategories();

    return Ui.scaffold(
      bar: Ui.appBar(
        title: 'Categories',
        rightButton: Platform.isIOS
            ? Ui.actionButton(CupertinoIcons.add, () {
                _showAddDialog(context);
              })
            : null,
      ),
      body: Material(
        child: _buildBody(),
        color: Constant.bgColor,
      ),
      float: Platform.isAndroid
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                _showAddDialog(context);
              })
          : null,
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<Category>>(
        stream: _bloc.categories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          final categories = snapshot.data;

          return ReorderableListView(
            onReorder: (int oldIndex, int newIndex) => _bloc.updateOrder(oldIndex, newIndex),
            children: <Widget>[
              for (final category in categories)
                ListTile(
                  key: ValueKey(category),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Ui.icon(CupertinoIcons.pen, Icons.edit),
                          onPressed: () {
                            _showEditDialog(context, category);
                          },
                        ),
                        IconButton(
                          icon: Ui.icon(CupertinoIcons.delete_simple, Icons.delete),
                          onPressed: () {
                            _showConfirmDeleteDialog(context, category);
                          },
                        ),
                      ],
                    ),
                  ),
                  title: Text(category.name),
                ),
            ],
          );
        });
  }

  void _showEditDialog(BuildContext context, Category category) {
    Ui.openDialog(
      context: context,
      dialog: TextFieldDialog(
        savePressed: (String newName) {
          _bloc.updateCategoryName(category, newName);
        },
        labelText: null,
        hintText: 'Name',
        title: 'New Name',
        agreeButtonText: 'Update',
        oldText: category.name,
      ),
    );
  }

  void _showConfirmDeleteDialog(BuildContext context, Category category) {
    Ui.showAlert(
      builder: (ctx) {
        return Ui.alertDialog(
          title: 'Delete Category ' + category.name,
          child: Text('All tasks in category also will be deleted'),
          actions: [
            Ui.alertAction(
              context: ctx,
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              text: 'Cancel',
              isDestructive: true,
            ),
            Ui.alertAction(
              context: ctx,
              onPressed: () {
                _bloc.deleteCategory(category);
                Navigator.of(ctx).pop();
                Flushbar(
                  title: "Delete",
                  message: "Category $category was deleted",
                  duration: Duration(seconds: 3),
                )..show(context);
              },
              text: 'Delete',
            ),
          ],
          context: ctx,
        );
      },
      context: context,
    );
  }

  void _showAddDialog(BuildContext context) {
    Ui.openDialog(
      context: context,
      dialog: TextFieldDialog(
        savePressed: (String newName) {
          _bloc.createNewCategory(newName);
          Flushbar(
            title: "Create",
            message: "Category $newName was created",
            duration: Duration(seconds: 3),
          )..show(context);
        },
        labelText: null,
        hintText: 'Name',
        title: 'New Category',
      ),
    );
  }
}
