import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_screen.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    Key? key,
    required TaskListBloc bloc,
    required this.task,
    required this.textWidth,
  })   : _bloc = bloc,
        super(key: key);

  final TaskListBloc _bloc;
  final UserTask task;
  final double textWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () => Ui.route(context, TaskDetailScreen(task: task)),
            child: _buildItem(task),
          ),
          SizedBox(
            width: 35,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'doneButton${task.uid}',
              backgroundColor: Constant.primaryColor,
              child: Icon(
                Icons.done,
                size: 20,
                color: Constant.getTextColor(Constant.primaryColor),
              ),
              onPressed: () async {
                await _bloc.remove(task);
                // Flushbar(
                //   title: "Done",
                //   message: "Task ${task.title} is complete!",
                //   duration: Duration(seconds: 3),
                // )..show(context);
              },
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildItem(UserTask task) {
    bool hasComment = task.comment.isNotEmpty;
    Color backgroundTaskColor = Colors.white;
    Color textColor = Colors.black;
    Color catColor = Constant.defaultCategoryColor;

    try {
      catColor = _bloc.categories.firstWhere((cat) => cat.name == task.category).getColor();
    } catch (e) {
      catColor = Colors.white;
      textColor = Colors.black;
    }

    if (catColor != Constant.defaultCategoryColor) {
      backgroundTaskColor = catColor;
      textColor = Constant.getTextColor(catColor);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundTaskColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 1.0, // has the effect of softening the shadow
            spreadRadius: 1.0, // has the effect of extending the shadow
            offset: const Offset(
              1.0, // horizontal, move right 10
              1.0, // vertical, move down 10
            ),
          ),
        ],
        borderRadius: const BorderRadius.all(const Radius.circular(20)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: hasComment ? textWidth - 35 : textWidth,
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text(
              task.title,
              style: TextStyle(fontSize: 18, color: textColor),
            ),
          ),
          if (hasComment)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.chat_bubble_outline,
                color: Constant.getTextColor(backgroundTaskColor),
              ),
            ),
        ],
      ),
    );
  }
}
