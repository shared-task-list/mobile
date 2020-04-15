import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/category.dart';

class QuickAddDialog extends StatefulWidget {
  final String defaultCategory;
  final List<Category> categories;
  final Function(String, String) onSetName;
  final Function(String) onSetCategory;

  QuickAddDialog({
    Key key,
    this.onSetName,
    this.categories,
    this.defaultCategory,
    this.onSetCategory,
  }) : super(key: key);

  @override
  _QuickAddDialogState createState() => _QuickAddDialogState(
        onSetName,
        onSetCategory,
        categories,
        (defaultCategory == null || defaultCategory.isEmpty) ? Constant.noCategory : defaultCategory,
      );
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  final List<Category> categories;
  final Function(String, String) onSetName;
  final Function(String) onSetCategory;
  final _formKey = GlobalKey<FormState>();
  final isIos = Platform.isIOS;
  String defaultCategory;
  String _title = '';
  String _category = '';
  S locale;

  _QuickAddDialogState(this.onSetName, this.onSetCategory, this.categories, this.defaultCategory) {
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
              padding: EdgeInsets.only(right: 32.0),
              height: 230 + (categories.length * 45.0),
//            height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 40.0),
                  Expanded(
                    child: Column(
//                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        Text(
                          locale.taskTitle,
                          style: Theme.of(context).textTheme.title,
                        ),
//                        SizedBox(height: 20.0),
                        Form(
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
//                      SizedBox(height: 10.0),
                        Expanded(
                          child: SingleChildScrollView(
                            child: RadioButtonGroup(
                              labels: categories.map((category) => category.name).toList(),
                              onSelected: (String selected) => setState(() {
                                _category = selected;
                                defaultCategory = selected;
                                onSetCategory(selected);
                              }),
                              picked: _category,
                              itemBuilder: (Radio rb, Text txt, int i) {
                                return InkWell(
                                  child: Container(
                                    child: Row(children: <Widget>[rb, txt]),
                                  ),
                                  onTap: () => setState(() {
                                    _category = txt.data;
                                    defaultCategory = txt.data;
                                    onSetCategory(txt.data);
                                  }),
                                );
                              },
                            ),
                          ),
                        ),
//                      SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                child: Text(locale.cancel),
                                color: Colors.red,
                                colorBrightness: Brightness.dark,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                shape: Constant.buttonShape,
                              ),
                            ),
                            SizedBox(width: Platform.isIOS ? 20.0 : 10.0),
                            Expanded(
                              child: RaisedButton(
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

  Widget _buildRow(Category category) {
    return InkWell(
      enableFeedback: false,
      onTap: () {
        _category = category.name;
        defaultCategory = category.name;
        onSetCategory(category.name);
      },
      child: Container(
        child: Row(
          children: <Widget>[
            Radio(
              autofocus: _category == category.name,
              value: category.name,
              onChanged: (String value) {
                _category = value;
                defaultCategory = value;
                onSetCategory(value);
              },
              groupValue: _category,
            ),
            Text(
              category.name,
              style: TextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}
