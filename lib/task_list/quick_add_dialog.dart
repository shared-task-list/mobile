import 'package:flutter/material.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';

class QuickAddDialog extends StatefulWidget {
  final Function(String) onSetName;

  const QuickAddDialog({Key key, this.onSetName}) : super(key: key);

  @override
  _QuickAddDialogState createState() => _QuickAddDialogState(onSetName);
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  final Function(String) onSetName;
  String _title = '';
  S locale;

  _QuickAddDialogState(this.onSetName);

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Constant.dialogPadding),
        child: Ui.dialog(
          child: Container(
            padding: EdgeInsets.only(right: 16.0),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(width: 40.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Text(
                        locale.taskTitle,
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(height: 20.0),
                      Flexible(
                        child: Material(
                          color: Colors.white,
                          child: TextField(
                            style: TextStyle(backgroundColor: Colors.white),
                            autofocus: true,
                            onChanged: (value) => _title = value,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            child: Text(locale.cancel),
                            color: Colors.red,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: Constant.buttonShape,
                          ),
                          SizedBox(width: 20.0),
                          RaisedButton(
                            child: Text(locale.create),
                            color: Colors.blue,
                            colorBrightness: Brightness.dark,
                            onPressed: () async {
                              if (_title.isEmpty) {
                                return;
                              }
                              onSetName(_title);
                              Navigator.pop(context);
                            },
                            shape: Constant.buttonShape,
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
