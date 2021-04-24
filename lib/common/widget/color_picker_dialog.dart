import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/generated/l10n.dart';

class ColorPickerDialog extends StatefulWidget {
  final Function(Color) applyFunction;

  ColorPickerDialog({
    Key? key,
    required this.applyFunction,
  }) : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color? _color;
  late S _locale;

  @override
  Widget build(BuildContext context) {
    _locale = S.of(context);

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          ColorPicker(
            onColorChanged: (Color color) => _color = color,
            width: 44,
            height: 44,
            borderRadius: 22,
            heading: Text(
              _locale.select_color,
              style: Theme.of(context).textTheme.headline5,
            ),
            subheading: Text(
              _locale.select_shade_color,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            actionButtons: ColorPickerActionButtons(
              closeButton: true,
            ),
          ),
          Expanded(child: Container()),
          Row(
            children: [
              const SizedBox(width: 10.0),
              Expanded(
                child: ElevatedButton(
                  child: Text(_locale.cancel),
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
                  child: Text(_locale.update),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    shape: Constant.buttonShape,
                  ),
                  onPressed: () {
                    if (_color == null) {
                      return;
                    }

                    widget.applyFunction(_color!);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 10.0),
            ],
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
