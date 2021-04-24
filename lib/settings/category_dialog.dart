import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/model/category.dart';

class CategoryDialog extends StatefulWidget {
  final String? savedCategory;
  final ValueChanged<String> onChanged;

  const CategoryDialog({
    Key? key,
    required this.onChanged,
    this.savedCategory,
  }) : super(key: key);

  @override
  _CategoryDialogState createState() => _CategoryDialogState(savedCategory, onChanged);
}

class _CategoryDialogState extends State<CategoryDialog> {
  String _currentCategory = '';
  late ValueChanged<String> _onChanged;

  _CategoryDialogState(String? savedCategory, ValueChanged<String> onChanged) {
    this._currentCategory = savedCategory ?? '';
    this._onChanged = onChanged;
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
                      child: Text(
                        'Set Default Category',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: FutureBuilder<List<Category>>(
                            future: CategoryProvider.getList(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }

                              final categories = snapshot.data ?? [];
                              List<Category> addCats = [];
                              int cindex = categories.indexWhere((c) => c.name == Constant.noCategory);

                              if (cindex == -1) {
                                addCats.add(AppData.noCategory);
                              }

                              addCats.addAll(categories);

                              return Material(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    for (final category in addCats) _buildRow(category),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
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
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
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
