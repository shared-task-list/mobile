import 'package:flutter/material.dart';
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
    Key? key,
    required this.onSetName,
    required this.categories,
    required this.defaultCategory,
    required this.onSetCategory,
  }) : super(key: key);

  @override
  _QuickAddDialogState createState() => _QuickAddDialogState(
        onSetName,
        onSetCategory,
        categories,
        defaultCategory.isEmpty ? Constant.noCategory : defaultCategory,
      );
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  final List<Category> categories;
  final Function(String, String) onSetName;
  final Function(String) onSetCategory;
  final _formKey = GlobalKey<FormState>();
  String defaultCategory;
  String _title = '';
  String _category = '';
  late S locale;

  _QuickAddDialogState(
    this.onSetName,
    this.onSetCategory,
    this.categories,
    this.defaultCategory,
  ) {
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
              padding: const EdgeInsets.only(right: 32.0),
              height: 230 + (categories.length * 45.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(const Radius.circular(10)),
              ),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 40.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        const SizedBox(height: 20.0),
                        Text(
                          locale.taskTitle,
                          style: Theme.of(context).textTheme.headline6,
                        ),
//                        SizedBox(height: 20.0),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            style: TextStyle(backgroundColor: Colors.white),
                            autofocus: true,
                            onChanged: (value) => _title = value,
                            validator: (String? value) {
                              if (value != null && value.isEmpty) {
                                return S.of(context).required;
                              }

                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (final category in categories)
                                  RadioListTile<String>(
                                    activeColor: Constant.primaryColor,
                                    groupValue: _category,
                                    value: category.name,
                                    title: Text(
                                      category.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(color: category.name == defaultCategory ? Colors.black : Colors.black38),
                                    ),
                                    onChanged: (String? value) {
                                      if (value == null) {
                                        return;
                                      }

                                      setState(() {
                                        _category = value;
                                        defaultCategory = value;
                                        onSetCategory(value);
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                child: Text(locale.cancel),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
                                  shape: Constant.buttonShape,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: ElevatedButton(
                                child: Text(locale.create),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white,
                                  shape: Constant.buttonShape,
                                ),
                                onPressed: () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  onSetName(_title, _category);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
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
