import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';

class ColorSetDialog extends StatefulWidget {
  final Function(Color) onSetColor;

  ColorSetDialog({
    @required this.onSetColor,
  });

  @override
  _ColorSetDialogState createState() => _ColorSetDialogState(onSetColor);
}

class _ColorSetDialogState extends State<ColorSetDialog> {
  S _locale;
  Color _color;
  final Function(Color) onSetColor;

  _ColorSetDialogState(this.onSetColor);

  @override
  Widget build(BuildContext context) {
    _locale = S.of(context);

    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            height: Platform.isIOS ? 450 : 570,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Ui.dialog(
              child: Material(
                color: Colors.white,
                child: MaterialColorPicker(
                  colors: fullMaterialColors,
                  onColorChange: (Color color) {
                    _color = color;
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            left: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text(_locale.cancel),
                    color: Colors.red,
                    colorBrightness: Brightness.dark,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    shape: Constant.buttonShape,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: RaisedButton(
                    child: Text("Ok"),
                    color: Colors.blue,
                    colorBrightness: Brightness.dark,
                    onPressed: () async {
                      onSetColor(_color);
                      Navigator.pop(context);
                    },
                    shape: Constant.buttonShape,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
