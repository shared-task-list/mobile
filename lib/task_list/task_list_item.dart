import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_screen.dart';
import 'package:shared_task_list/task_list/task_list_bloc.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    Key key,
    @required TaskListBloc bloc,
    @required this.task,
    @required this.textWidth,
  })  : _bloc = bloc,
        super(key: key);

  final TaskListBloc _bloc;
  final UserTask task;
  final double textWidth;

  @override
  Widget build(BuildContext context) {
    bool hasComment = task.comment != null && task.comment.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () => Ui.route(context, TaskDetailScreen(task: task)),
            child: StreamBuilder<Map<String, Category>>(
                stream: _bloc.categoryMapStream,
                builder: (context, snapshot) {
                  Color textColor = Colors.black;
                  Color backgroundTaskColor = Colors.white;
                  var brightness = ThemeData.estimateBrightnessForColor(backgroundTaskColor);

                  if (snapshot.hasData) {
                    Color catColor = snapshot.data[task.category].getColor();

                    if (catColor != Colors.grey.shade600) {
                      brightness = ThemeData.estimateBrightnessForColor(catColor);
                      textColor = brightness == Brightness.light ? Colors.black : Colors.white;
                      backgroundTaskColor = catColor;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: backgroundTaskColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[400],
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
                          margin: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                          child: Text(
                            task.title,
                            style: TextStyle(fontSize: 18, color: textColor),
                          ),
                        ),
                        if (hasComment)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Ui.icon(
                              CupertinoIcons.conversation_bubble,
                              Icons.chat_bubble_outline,
                              color: brightness == Brightness.light ? Colors.black : Colors.white,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
          ),
          SizedBox(
            width: 35,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'doneButton${task.uid}',
              backgroundColor: Colors.cyan.shade800,
              child: const Icon(Icons.done, size: 20),
              onPressed: () async {
                await _bloc.remove(task);
                Flushbar(
                  title: "Done",
                  message: "Task ${task.title} is complete!",
                  duration: Duration(seconds: 3),
                )..show(context);
              },
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}
