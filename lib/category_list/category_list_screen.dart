import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/category_list/category_list_bloc.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';

class CategoryListScreen extends StatelessWidget {
  final _bloc = CategoryListBloc();
  late S _locale;

  CategoryListScreen() {
    _bloc.getList();
  }

  @override
  Widget build(BuildContext context) {
    _locale = S.of(context);

    return Ui.scaffold(
      bar: Ui.appBar(
        title: _locale.categories,
      ),
      body: Material(
        child: _buildBody(),
        color: Constant.bgColor,
      ),
      float: FloatingActionButton(
          backgroundColor: Constant.accentColor,
          child: Icon(
            Icons.add,
            color: Constant.getTextColor(Constant.accentColor),
          ),
          onPressed: () {
            _showAddDialog(context);
          }),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<Category>>(
        stream: _bloc.categories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          final categories = snapshot.data ?? [];

          return Column(
            children: <Widget>[
              const SizedBox(height: 16),
              Expanded(
                child: ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) => _bloc.updateOrder(oldIndex, newIndex, categories),
                  children: <Widget>[
                    for (final category in categories)
                      ListTile(
                        key: ValueKey(category),
                        leading: Icon(Icons.drag_handle),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(context, category);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
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
                ),
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
        labelText: '',
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

  Future _showAddDialog(BuildContext context) async {
    await Ui.openDialog(
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
        labelText: '',
        hintText: 'Name',
        title: 'New Category',
      ),
    );
  }
}
