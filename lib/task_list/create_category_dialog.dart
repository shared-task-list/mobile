import 'package:flutter/material.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';

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
    final locale = S.of(context);
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
                        locale.newCategory,
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
                            onPressed: () {
                              savePressed();
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
