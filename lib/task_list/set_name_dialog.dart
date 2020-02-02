import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';

class SetNameDialog extends StatefulWidget {
  final Function(String) onSetName;
  final String savedName;

  const SetNameDialog({Key key, this.onSetName, this.savedName}) : super(key: key);

  @override
  _SetNameDialogState createState() => _SetNameDialogState(onSetName, savedName);
}

class _SetNameDialogState extends State<SetNameDialog> {
  final Function(String) onSetName;
  final String savedName;
  S locale;
  String _newName = '';

  _SetNameDialogState(this.onSetName, this.savedName);

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Constant.dialogPadding),
        child: Ui.dialog(
          child: Container(
            padding: EdgeInsets.only(right: 30.0),
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
                        locale.newName,
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(height: 20.0),
                      Flexible(
                        child: Material(
                          color: Colors.white,
                          child: TextField(
                            style: TextStyle(backgroundColor: Colors.white),
                            autofocus: true,
                            onChanged: (value) => _newName = value,
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
                            child: Text(locale.update),
                            color: Colors.blue,
                            colorBrightness: Brightness.dark,
                            onPressed: () async {
                              if (_newName.isEmpty) {
                                return;
                              }
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString(Constant.authorKey, _newName);
                              Constant.userName = _newName;
                              onSetName(_newName);
                              Navigator.pop(context);
                            },
                            shape: Constant.buttonShape,
                          ),
                        ],
                      ),
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
