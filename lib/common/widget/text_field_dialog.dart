import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';

class TextFieldDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String labelText;
  final String agreeButtonText;
  final ValueChanged<String> savePressed;
  final IconData icon;

  TextFieldDialog({
    Key key,
    @required this.savePressed,
    @required this.title,
    this.agreeButtonText,
    this.icon,
    @required this.hintText,
    @required this.labelText,
  }) : super(key: key);

  @override
  _TextFieldDialogState createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  String newData;

  @override
  Widget build(BuildContext context) {
    S locale = S.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Ui.dialog(
          child: Container(
            padding: EdgeInsets.only(right: 32.0),
            height: 220,
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
                        widget.title,
                        style: Theme.of(context).textTheme.headline,
                      ),
                      SizedBox(height: 20.0),
                      Material(
                        color: Colors.white,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            autofocus: true,
                            maxLength: 30,
                            onChanged: (String value) => newData = value,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              icon: widget.icon == null ? null : Icon(widget.icon),
                              hintText: widget.hintText,
//                              labelText: labelText,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              child: Text(locale.cancel),
                              color: Colors.red,
                              colorBrightness: Brightness.dark,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            ),
                          ),
                          SizedBox(width: Platform.isIOS ? 20.0 : 10.0),
                          Expanded(
                            child: RaisedButton(
                              child: Text(widget.agreeButtonText ?? locale.create),
                              color: Colors.blue,
                              colorBrightness: Brightness.dark,
                              onPressed: () {
                                if (!_formKey.currentState.validate()) {
                                  return;
                                }
                                widget.savePressed(newData);
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            ),
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
