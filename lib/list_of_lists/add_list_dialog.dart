import 'package:flutter/material.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';

class AddListDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String labelText;
  final String? agreeButtonText;
  final String? oldText;
  final Function(String, String) savePressed;
  final IconData? icon;

  AddListDialog({
    Key? key,
    required this.savePressed,
    required this.title,
    required this.hintText,
    required this.labelText,
    this.agreeButtonText,
    this.icon,
    this.oldText,
  }) : super(key: key);

  @override
  _AddListDialogState createState() => _AddListDialogState();
}

class _AddListDialogState extends State<AddListDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    S locale = S.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Ui.dialog(
          child: Container(
            padding: const EdgeInsets.only(right: 32.0),
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 40.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 20.0),
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(height: 20.0),
                      Material(
                        color: Colors.white,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                autofocus: true,
                                maxLength: 30,
                                onChanged: (String value) => name = value,
                                validator: (String? value) {
                                  if (value != null && value.isEmpty) {
                                    return locale.field_required;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.list),
                                  hintText: locale.taskListName,
                                ),
                              ),
                              TextFormField(
                                obscureText: true,
                                maxLength: 30,
                                onChanged: (String value) => password = value,
                                validator: (String? value) {
                                  if (value != null && value.isEmpty) {
                                    return locale.field_required;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.lock_outline),
                                  hintText: locale.password,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              child: Text(widget.agreeButtonText ?? locale.create),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                shape: Constant.buttonShape,
                              ),
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                widget.savePressed(name, password);
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
    );
  }
}
