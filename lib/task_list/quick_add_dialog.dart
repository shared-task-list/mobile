import 'package:flutter/material.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';

class QuickAddDialog extends StatefulWidget {
  final String defaultCategory;
  final List<Category> categories;
  final Function(String, String) onSetName;

  QuickAddDialog({Key key, this.onSetName, this.categories, this.defaultCategory}) : super(key: key);

  @override
  _QuickAddDialogState createState() => _QuickAddDialogState(
        onSetName,
        categories,
        (defaultCategory == null || defaultCategory.isEmpty) ? Constant.noCategory : defaultCategory,
      );
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  final List<Category> categories;
  final Function(String, String) onSetName;
  final _formKey = GlobalKey<FormState>();
  String defaultCategory;
  String _title = '';
  String _category = '';
  S locale;

  _QuickAddDialogState(this.onSetName, this.categories, this.defaultCategory) {
    _category = defaultCategory;
  }

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Constant.dialogPadding),
        child: Ui.dialog(
          child: Material(
            child: Container(
              padding: EdgeInsets.only(right: 16.0),
              height: 230,
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
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              style: TextStyle(backgroundColor: Colors.white),
                              autofocus: true,
                              onChanged: (value) => _title = value,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return S.of(context).required;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            isDense: true,
                            value: defaultCategory,
                            onChanged: (String newValue) {
                              setState(() {
                                _category = newValue;
                                defaultCategory = newValue;
                              });
                            },
                            items: categories.map<DropdownMenuItem<String>>((Category value) {
                              return DropdownMenuItem<String>(
                                value: value.name,
                                child: Text(value.name, style: TextStyle(fontSize: 18)),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20.0),
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
                                if (!_formKey.currentState.validate()) {
                                  return;
                                }

                                onSetName(_title, _category);
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
      ),
    );
  }
}
