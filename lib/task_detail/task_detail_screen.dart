import 'dart:ui';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_bloc.dart';

class TaskDetailScreen extends StatefulWidget {
  final UserTask task;

  TaskDetailScreen({
    Key key,
    this.task,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloc = TaskDetailBloc();
  final _pc = SlidingUpPanelController();
  S locale;

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);

    if (widget.task != null) {
      _bloc.category = widget.task.category;
      _bloc.title = widget.task.title;
      _bloc.comment = widget.task.comment;
    }

    return Ui.scaffold(
      bar: Ui.appBar(
        title: widget.task == null ? locale.newTask : locale.task,
        rightButton: Ui.actionSvgButton('add-to-calendar', () => _addToCalendar(widget.task)),
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
            _buildSlidePanel(),
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
          SizedBox(height: 30),
          if (widget.task != null)
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 16),
                  child: Text(
                    '${widget.task.author} - ${Constant.dateFormatter.format(widget.task.timestamp)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
//          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              initialValue: widget.task?.title ?? '',
              decoration: InputDecoration(
                hintText: locale.title,
              ),
              autofocus: true,
              onChanged: (value) {
                _bloc.title = value;
              },
              validator: (newValue) {
                if (newValue.isEmpty) {
                  return locale.required;
                }
                return null;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              initialValue: widget.task?.comment ?? '',
              maxLines: 5,
//              maxLength: 255,
              decoration: InputDecoration(
                hintText: locale.comment,
              ),
              onChanged: (value) {
                _bloc.comment = value;
              },
            ),
          ),
          SizedBox(height: 50),
          StreamBuilder<String>(
            stream: _bloc.categoryButtonTitle,
            builder: (context, snapshot) {
              String title = '';

              if (!snapshot.hasData) {
                if (widget.task == null) {
                  title = locale.category;
                } else {
                  title = locale.category + ' - ${widget.task.category}';
                }
              } else {
                title = snapshot.data;
              }

              return Ui.flatButton(title, () {
                _bloc.getCategories();
                FocusScope.of(context).unfocus();
                _pc.anchor();
              });
            },
          ),
          SizedBox(height: 50),
          SizedBox(
            width: 150,
            height: 45,
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
              child: Text(
                widget.task == null ? locale.create : locale.update,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              color: Colors.blue,
              onPressed: () async {
                if (!_formKey.currentState.validate()) {
                  return;
                }
                if (widget.task == null) {
                  await _bloc.createTask();
                } else {
                  await _bloc.updateTask(widget.task);
                }

                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidePanel() {
    return SlidingUpPanelWidget(
      panelStatus: SlidingUpPanelStatus.hidden,
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              height: 50.0,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                    ),
                    child: Text(
                      locale.categoryList,
                      style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            /*Divider(
              height: 0.5,
              color: Colors.grey,
            ),*/
            Flexible(
              child: Container(
                child: StreamBuilder<List<Category>>(
                    stream: _bloc.categories,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      return ListView.separated(
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final category = snapshot.data[index];

                          return ListTile(
                            title: Text(category.name),
                            onTap: () {
                              _bloc.category = category.name;
                              _bloc.setCategoryTitle(category.name);
                              _pc.hide();
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 0.5,
                          );
                        },
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                      );
                    }),
                color: Colors.white,
              ),
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
      controlHeight: 50.0,
      anchor: 0.5,
      panelController: _pc,
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    const labelBackground = const Color.fromRGBO(0, 0, 0, 0.6);
    const labelTextStyle = const TextStyle(fontWeight: FontWeight.w500, color: Colors.white);

    return SpeedDial(
      marginBottom: 38,
      marginRight: 32,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      overlayOpacity: 0,
      children: [
        SpeedDialChild(
          child: Icon(Icons.save, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () async {
            if (!_formKey.currentState.validate()) {
              return;
            }
            if (widget.task == null) {
              await _bloc.createTask();
            } else {
              await _bloc.updateTask(widget.task);
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
                labelText: null,
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

  void _addToCalendar(UserTask task) {
    if (task?.title == null || task.title.isEmpty) {
      Ui.alertDialog(
          child: Text('Title is required'), actions: [Ui.flatButton('Ok', () => Navigator.of(context).pop())], context: context, title: 'Error');
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
