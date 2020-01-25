import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_task_list/common/widget/ui.dart';

class CreateCategoryDialog extends StatelessWidget {
  final VoidCallback savePressed;
  final ValueChanged<String> onTextChanged;

  const CreateCategoryDialog({
    Key key,
    @required this.savePressed,
    @required this.onTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _pad = Platform.isIOS ? 24 : 8;

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
                        "New Category",
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(height: 20.0),
                      Flexible(
                        child: Material(
                          child: TextField(
                            autofocus: true,
//                          maxLength: 30,
                            onChanged: onTextChanged,
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
                            child: Text("Create"),
                            color: Colors.blue,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              savePressed();
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
