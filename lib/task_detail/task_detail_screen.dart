import 'dart:ui';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_bloc.dart';

class TaskDetailScreen extends StatefulWidget {
  final UserTask? task;

  TaskDetailScreen({
    Key? key,
    this.task,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloc = TaskDetailBloc();
  late S locale;

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);

    if (widget.task != null) {
      _bloc.category = widget.task!.category;
      _bloc.title = widget.task!.title;
      _bloc.comment = widget.task!.comment;
    }

    return Ui.scaffold(
      bar: Ui.appBar(
        title: widget.task == null ? locale.newTask : locale.task,
        rightButton: Ui.actionSvgButton(
          'add-to-calendar',
          () async => await _addToCalendar(context, widget.task),
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
            // _buildSlidePanel(),
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
          if (widget.task != null)
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 16),
                  child: Text(
                    '${widget.task!.author} - ${Constant.dateFormatter.format(widget.task!.timestamp)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
//          SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              initialValue: widget.task?.title ?? '',
              decoration: InputDecoration(
                hintText: locale.title,
              ),
              autofocus: true,
              onChanged: (value) {
                _bloc.title = value;
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
              initialValue: widget.task?.comment ?? '',
              maxLines: 5,
              decoration: InputDecoration(
                hintText: locale.comment,
              ),
              onChanged: (value) {
                _bloc.comment = value;
              },
            ),
          ),
          const SizedBox(height: 50),
          StreamBuilder<String>(
            stream: _bloc.categoryButtonTitle,
            builder: (context, snapshot) {
              String title = '';

              if (!snapshot.hasData) {
                if (widget.task == null) {
                  title = locale.category;
                } else {
                  title = locale.category + ' - ${widget.task?.category ?? ''}';
                }
              } else {
                title = locale.category + ' - ' + snapshot.data!;
              }

              return OutlinedButton(
                child: Text(
                  title,
                  style: TextStyle(color: Constant.primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  shape: Constant.buttonShape,
                  side: BorderSide(color: Constant.primaryColor),
                ),
                onPressed: () async {
                  await _bloc.getCategories();
                  await _buildSlidePanel(context);
                },
              );

              // FocusScope.of(context).unfocus();
            },
          ),
          SizedBox(height: 50),
          SizedBox(
            width: 150,
            height: 45,
            child: ElevatedButton(
              child: Text(
                widget.task == null ? locale.create : locale.update,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
                shape: Constant.buttonShape,
              ),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                if (widget.task == null) {
                  await _bloc.createTask();
                } else {
                  await _bloc.updateTask(widget.task!);
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
          return StreamBuilder<List<Category>>(
            stream: _bloc.categories,
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              final categories = snapshot.data;

              if (categories == null || categories.isEmpty) {
                return Container();
              }

              List<Category> addCats = [];
              int cindex = categories.indexWhere((c) => c.name == Constant.noCategory);

              if (cindex == -1) {
                addCats.add(AppData.noCategory);
              }

              addCats.addAll(categories);

              return ListView.builder(
                itemCount: addCats.length,
                itemBuilder: (bctx, index) {
                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(addCats[index].name),
                    onTap: _closeable(ctx, () {
                      _bloc.category = addCats[index].name;
                      _bloc.setCategoryTitle(addCats[index].name);
                    }),
                  );
                },
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
            if (widget.task == null) {
              await _bloc.createTask();
            } else {
              await _bloc.updateTask(widget.task!);
            }
          },
          label: widget.task == null ? locale.create : locale.update,
          labelStyle: labelTextStyle,
          labelBackgroundColor: labelBackground,
        ),
        SpeedDialChild(
          child: Icon(Icons.add_circle_outline, color: Colors.white),
          backgroundColor: Colors.purple,
          onTap: () async {
            Ui.openDialog(
              context: context,
              dialog: TextFieldDialog(
                savePressed: (String newCategory) => _bloc.createNewCategory(newCategory),
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

    final Event event = Event(
      title: task.title,
      description: task.comment,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(hours: 1)),
    );

    Add2Calendar.addEvent2Cal(event);
  }
}
