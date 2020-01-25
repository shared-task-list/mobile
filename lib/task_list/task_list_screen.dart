import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/join/join_screen.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_screen.dart';
import 'package:shared_task_list/task_list/create_category_dialog.dart';
import 'package:shared_task_list/task_list/set_name_dialog.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';

class TaskListScreen extends StatelessWidget {
  final _bloc = TaskListBloc();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    _bloc.load();
    double textWidth = MediaQuery.of(context).size.width - 80;

    return Ui.scaffold(
      bar: Ui.appBar(title: Constant.taskList),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          _bloc.getTasks();
          _refreshController.refreshCompleted();
        },
        child: Stack(
          children: [
            _buildList(context, textWidth),
            _buildMenuButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, double textWidth) {
    return StreamBuilder<Map<String, List<UserTask>>>(
      stream: _bloc.tasksMap,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Align(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        final tasks = snapshot.data;
        var widgets = <Widget>[];

        tasks.forEach((category, taskList) {
          if (taskList.isEmpty) {
            return;
          }

          widgets.add(Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 16, left: 16),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ));

          for (final task in taskList) {
            widgets.add(_buildListItem(context, task, textWidth));
          }
        });

        widgets.add(SizedBox(height: 100));

        return SingleChildScrollView(
          child: Column(
            children: widgets,
          ),
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, UserTask task, double textWidth) {
    String time = _getTimeString(task);
    return Material(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => TaskDetailScreen(task: task),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400],
                    blurRadius: 1.0, // has the effect of softening the shadow
                    spreadRadius: 1.0, // has the effect of extending the shadow
                    offset: Offset(
                      1.0, // horizontal, move right 10
                      1.0, // vertical, move down 10
                    ),
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: textWidth,
                    margin: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text(
                      task.title,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  /*Container(
                    margin: EdgeInsets.only(left: 16, bottom: 8, top: 4),
                    child: Text(
                      task.author + ' - ' + time,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
          Container(
            height: 28,
            width: 28,
            margin: EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade300,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: IconButton(
              iconSize: 16,
              color: Colors.white,
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.done),
              onPressed: () async {
                await _bloc.remove(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return FabCircularMenu(
      child: Container(),
      options: <Widget>[
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () async {
            await _bloc.exit();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => JoinScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            Ui.openDialog(
              context: context,
              dialog: SetNameDialog(),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => TaskDetailScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline),
          onPressed: () {
            Ui.openDialog(
              context: context,
              dialog: CreateCategoryDialog(
                savePressed: () {
                  _bloc.createNewCategory();
                },
                onTextChanged: (String value) {
                  _bloc.newCategory = value;
                },
              ),
            );
          },
        ),
      ],
      fabColor: Colors.blue,
      ringColor: Colors.blue.shade100,
      ringWidth: 48,
      ringDiameter: 48 * 4.0,
    );
  }

  String _getTimeString(UserTask task) {
    return Constant.dateFormatter.format(task.timestamp);
  }
}
