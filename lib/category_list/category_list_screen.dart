import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_task_list/category_list/category_list_ctrl.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';

class CategoryListScreen extends StatelessWidget {
  final CategoryListCtrl ctrl = Get.put(CategoryListCtrl());

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Ui.scaffold(
      bar: Ui.appBar(
        title: locale.categories,
      ),
      body: Material(
        child: _buildBody(context),
        color: Constant.bgColor,
      ),
      float: FloatingActionButton(
          backgroundColor: Constant.accentColor,
          child: Icon(
            Icons.add,
            color: Constant.getTextColor(Constant.accentColor),
          ),
          onPressed: () async {
            await _showAddDialog(context);
          }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() => _buildCategoryList(context)),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      onReorder: (int oldIndex, int newIndex) => ctrl.updateOrder(oldIndex, newIndex),
      children: ctrl.categories
          .map((category) => ListTile(
                key: ValueKey(category),
                leading: const Icon(Icons.drag_handle),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await _showEditDialog(context, category);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _showConfirmDeleteDialog(context, category);
                        },
                      ),
                    ],
                  ),
                ),
                title: Text(category.name),
              ))
          .toList(),
    );
  }

  Future _showEditDialog(BuildContext context, Category category) async {
    await Ui.openDialog(
      context: context,
      dialog: TextFieldDialog(
        savePressed: (String newName) {
          ctrl.updateCategoryName(category, newName);
        },
        labelText: '',
        hintText: 'Name',
        title: 'New Name',
        agreeButtonText: 'Update',
        oldText: category.name,
      ),
    );
  }

  Future _showConfirmDeleteDialog(BuildContext context, Category category) async {
    await Ui.showAlert(
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
                ctrl.deleteCategory(category);
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
          Get.back();
          ctrl.createNewCategory(newName);
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
