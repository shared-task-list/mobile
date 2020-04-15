import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
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
      bar: Ui.appBar(title: widget.task == null ? locale.newTask : locale.task),
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
    return FabCircularMenu(
      child: Container(),
      options: <Widget>[
        IconButton(
          icon: Icon(Icons.add_circle_outline),
          onPressed: () {
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
        ),
        IconButton(
          icon: Icon(Icons.save),
          onPressed: () async {
            if (!_formKey.currentState.validate()) {
              return;
            }
            await _bloc.createTask();
            Navigator.pop(context);
          },
        ),
      ],
      fabColor: Colors.blue,
      ringColor: Colors.blue.shade100,
      ringWidth: 48,
      ringDiameter: 48 * 4.0,
    );
  }
}
