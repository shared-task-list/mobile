import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/model/category.dart';

class CategoryDialog extends StatefulWidget {
  final String savedCategory;
  final ValueChanged<String> onChanged;

  const CategoryDialog({Key key, this.savedCategory, this.onChanged}) : super(key: key);

  @override
  _CategoryDialogState createState() => _CategoryDialogState(savedCategory, onChanged);
}

class _CategoryDialogState extends State<CategoryDialog> {
  String _currentCategory = '';
  ValueChanged<String> _onChanged;

  _CategoryDialogState(String savedCategory, ValueChanged<String> onChanged) {
    this._currentCategory = savedCategory;
    this._onChanged = onChanged;
  }

  @override
  Widget build(BuildContext context) {
    final double width = 200;
    final double leftMargin = (width / 3);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Constant.dialogPadding),
        child: Ui.dialog(
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16),
                      child: Text(
                        'Set Default Category',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: FutureBuilder<List<Category>>(
                            future: CategoryProvider.getList(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                return Container();
                              }

                              return Material(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    for (final category in snapshot.data) _buildRow(category),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                    if (Platform.isIOS) SizedBox(height: 60),
                  ],
                ),
                if (Platform.isIOS)
                  Positioned(
                    bottom: 10,
                    left: leftMargin,
                    child: SizedBox(
                      height: 45,
                      width: width,
                      child: Ui.button(
                        title: 'Ok',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        radius: 20,
                      ),
                    ),
                  ),
              ],
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
        _currentCategory = category.name;
        _onChanged(category.name);
        setState(() {
          _currentCategory = category.name;
        });
      },
      child: Container(
        child: Row(
          children: <Widget>[
            Radio(
              autofocus: _currentCategory == category.name,
              value: category.name,
              onChanged: (String value) {
                _currentCategory = value;
                _onChanged(value);
                setState(() {
                  _currentCategory = value;
                });
              },
              groupValue: _currentCategory,
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
