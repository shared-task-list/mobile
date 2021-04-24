import 'package:flutter/material.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';

import '../constant.dart';

class TextFieldDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String labelText;
  final String? agreeButtonText;
  final String? oldText;
  final ValueChanged<String> savePressed;
  final IconData? icon;

  TextFieldDialog({
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
  _TextFieldDialogState createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  String newData = '';

  @override
  Widget build(BuildContext context) {
    S locale = S.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Ui.dialog(
          child: Container(
            padding: const EdgeInsets.only(right: 32.0),
            height: 220,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(const Radius.circular(10)),
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
                          child: TextFormField(
                            initialValue: widget.oldText,
                            autofocus: true,
                            maxLength: 30,
                            onChanged: (String value) => newData = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
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
                                widget.savePressed(newData);
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
