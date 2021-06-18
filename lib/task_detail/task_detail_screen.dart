import 'dart:ui';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_ctrl.dart';

class TaskDetailScreen extends StatelessWidget {
  final UserTask? task;
  final TaskDetailCtrl controller = Get.put(TaskDetailCtrl());

  TaskDetailScreen({
    Key? key,
    this.task,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  late S locale;

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);

    if (task != null) {
      controller.category = task!.category;
      controller.title = task!.title;
      controller.comment = task!.comment;
      controller.categoryButtonTitle.value = locale.category + ' - ${task?.category ?? ''}';
    } else {
      controller.categoryButtonTitle.value = locale.category;
    }

    return Ui.scaffold(
      bar: Ui.appBar(
        title: task == null ? locale.newTask : locale.task,
        rightButton: Ui.actionSvgButton(
          'add-to-calendar',
          () async => await _addToCalendar(context, task),
        ),
      ),
      body: Material(
        color: Constant.bgColor,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                child: _buildBody(context),
              ),
            ),
            _buildMenuButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          if (task != null)
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 16),
                  child: Text(
                    '${task!.author} - ${Constant.dateFormatter.format(task!.timestamp)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              initialValue: task?.title ?? '',
              decoration: InputDecoration(
                hintText: locale.title,
              ),
              autofocus: true,
              onChanged: (value) {
                controller.title = value;
              },
              validator: (String? newValue) {
                if (newValue != null && newValue.isEmpty) {
                  return locale.required;
                }
                return null;
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              initialValue: task?.comment ?? '',
              maxLines: 5,
              decoration: InputDecoration(
                hintText: locale.comment,
              ),
              onChanged: (value) {
                controller.comment = value;
              },
            ),
          ),
          const SizedBox(height: 50),
          OutlinedButton(
            child: Obx(() => Text(
                  controller.categoryButtonTitle.value.isNotEmpty ? controller.categoryButtonTitle.value : locale.category,
                  style: TextStyle(color: Constant.primaryColor),
                )),
            style: OutlinedButton.styleFrom(
              shape: Constant.buttonShape,
              side: BorderSide(color: Constant.primaryColor),
            ),
            onPressed: () async {
              await controller.getCategories();
              await _buildSlidePanel(context);
            },
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: 150,
            height: 45,
            child: ElevatedButton(
              child: Text(
                task == null ? locale.create : locale.update,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                primary: Constant.primaryColor,
                onPrimary: Colors.white,
                shape: Constant.buttonShape,
              ),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                if (task == null) {
                  await controller.createTask();
                } else {
                  await controller.updateTask(task!);
                }

                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback _closeable(BuildContext ctx, Function f) {
    return () {
      Navigator.pop(ctx);
      f();
    };
  }

  Future _buildSlidePanel(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (ctx) {
          if (controller.categories.isEmpty) {
            return Container();
          }

          return ListView.builder(
            itemCount: controller.categories.length,
            itemBuilder: (bctx, index) {
              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(controller.categories[index].name),
                onTap: _closeable(ctx, () {
                  controller.category = controller.categories[index].name;
                  controller.categoryButtonTitle.value = locale.category + ' - ' + controller.categories[index].name;
                }),
              );
            },
          );
        });
  }

  Widget _buildMenuButton(BuildContext context) {
    const labelBackground = const Color.fromRGBO(0, 0, 0, 0.6);
    const labelTextStyle = const TextStyle(fontWeight: FontWeight.w500, color: Colors.white);

    return SpeedDial(
      marginBottom: 38,
      marginEnd: 32,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      overlayOpacity: 0,
      backgroundColor: Constant.accentColor,
      foregroundColor: Colors.white,
      children: [
        SpeedDialChild(
          child: Icon(Icons.save, color: Constant.getTextColor(Constant.accentColor)),
          backgroundColor: Colors.green,
          onTap: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            if (task == null) {
              await controller.createTask();
            } else {
              await controller.updateTask(task!);
            }
          },
          label: task == null ? locale.create : locale.update,
          labelStyle: labelTextStyle,
          labelBackgroundColor: labelBackground,
        ),
        SpeedDialChild(
          child: Icon(Icons.add_circle_outline, color: Colors.white),
          backgroundColor: Colors.purple,
          onTap: () async {
            await Ui.openDialog(
              context: context,
              dialog: TextFieldDialog(
                savePressed: (String newCategory) => controller.createNewCategory(newCategory),
                title: locale.newCategory,
                labelText: '',
                hintText: locale.categoryName,
              ),
            );
          },
          label: locale.newCategory,
          labelStyle: labelTextStyle,
          labelBackgroundColor: labelBackground,
        ),
      ],
    );
  }

  Future _addToCalendar(BuildContext context, UserTask? task) async {
    if (task?.title == null || task!.title.isEmpty) {
      await Ui.openDialog(
        context: context,
        dialog: Ui.alertDialog(
          child: Text('Title is required'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          context: context,
          title: 'Error',
        ),
      );

      return;
    }

    final event = Event(
      title: task.title,
      description: task.comment,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(hours: 1)),
    );

    Add2Calendar.addEvent2Cal(event);
  }
}
