import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';

class SetNameDialog extends StatefulWidget {
  const SetNameDialog({Key key}) : super(key: key);

  @override
  _SetNameDialogState createState() => _SetNameDialogState();
}

class _SetNameDialogState extends State<SetNameDialog> {
  String _newName = '';
  final double _pad = Platform.isIOS ? 24 : 8;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _pad),
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
                        "New Name",
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(height: 20.0),
                      Flexible(
                        child: Material(
                          child: TextField(
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
                            child: Text("Cancel"),
                            color: Colors.red,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          ),
                          SizedBox(width: 20.0),
                          RaisedButton(
                            child: Text("Update"),
                            color: Colors.blue,
                            colorBrightness: Brightness.dark,
                            onPressed: () async {
                              if (_newName.isEmpty) {
                                return;
                              }
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString(Constant.userName, _newName);
                              Constant.userName = _newName;
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
