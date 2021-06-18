import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/extension/color_extension.dart';
import 'package:shared_task_list/common/widget/color_picker_dialog.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/join/join_screen.dart';
import 'package:shared_task_list/settings/category_dialog.dart';
import 'package:shared_task_list/settings/settings_ctrl.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsCtrl controller = Get.put(SettingsCtrl());

  // final _bloc = SettingsBloc();
  final _primaryStyle = const TextStyle(fontSize: 18, color: Colors.black);
  final _secondStyle = const TextStyle(fontSize: 15, color: Colors.grey);
  late S locale;

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);
    // _bloc.setVisibleCats(_settings.isShowCategories);
    // _bloc.category.add(_settings.defaultCategory);

    return Ui.scaffold(
      bar: Ui.appBar(title: locale.settings),
      body: Material(
        color: controller.bgColor.value,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        _buildRow(
            primaryText: locale.defaultCategory,
            secondText: controller.settings.value.defaultCategory,
            onTap: () async {
              await Ui.openDialog(
                  context: context,
                  dialog: CategoryDialog(
                    savedCategory: controller.settings.value.defaultCategory,
                    onChanged: (String category) {
                      controller.settings.value.defaultCategory = category;
                    },
                  ));
            }),
        // show/hide
        InkWell(
          onTap: () {
            controller.settings.value.isShowQuickAdd = !controller.settings.value.isShowQuickAdd;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  locale.show_quick_add,
                  style: _primaryStyle,
                ),
                Switch(
                  activeColor: Constant.primaryColor,
                  value: controller.settings.value.isShowQuickAdd,
                  onChanged: (bool value) {
                    controller.settings.value.isShowQuickAdd = value;
                  },
                ),
              ],
            ),
          ),
        ),
        FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              if (snapshot.data == null) {
                return Container();
              }

              final prefs = snapshot.data!;
              String name = prefs.getString(Constant.authorKey) ?? '';
              controller.settings.value.name = name;

              return _buildRow(
                  primaryText: locale.username,
                  secondText: controller.settings.value.name,
                  onTap: () async {
                    await Ui.openDialog(
                      context: context,
                      dialog: TextFieldDialog(
                        savePressed: (String newName) {
                          controller.settings.value.name = newName;
                          prefs.setString(Constant.authorKey, newName);
                        },
                        title: locale.newName,
                        labelText: '',
                        hintText: locale.newName,
                      ),
                    );
                  });
            }),
        _buildRow(
          primaryText: locale.background,
          secondText: '',
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              builder: (ctx) => Container(
                child: Wrap(
                  children: _getBackgroundMenuOptions(ctx),
                ),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.only(top: 55),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  child: Text(
                    locale.exit,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: Constant.buttonShape,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () async {
                    await controller.exit();
                    await Get.off(() => JoinScreen());
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Future _openColor(BuildContext context) async {
    await Ui.openDialog(
      context: context,
      dialog: ColorPickerDialog(
        applyFunction: (Color color) async {
          Constant.bgColor = color;
          controller.bgColor.value = color;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('bg_color', color.toRgbString());
        },
      ),
    );
  }

  Future _openPick() async {
    final picker = ImagePicker();
    final image = await picker.getImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path;

    final bytes = await image.readAsBytes();
    String fileName = image.path.split('/').last;

    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('bg_name', fileName);
  }

  Widget _buildRow({
    required String primaryText,
    required String secondText,
    required GestureTapCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              primaryText,
              style: _primaryStyle,
            ),
            Text(
              secondText,
              style: _secondStyle,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      trailing: trailing,
    );
  }

  Future _clear() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('bg_name');
    prefs.remove('bg_color');
    Constant.bgColor = Colors.white;
    controller.bgColor.value = Colors.white;
  }

  VoidCallback _closeable(BuildContext ctx, Function f) {
    return () {
      Navigator.pop(ctx);
      f();
    };
  }

  List<Widget> _getBackgroundMenuOptions(BuildContext ctx) {
    return [
      ListTile(title: Text(locale.image), onTap: _closeable(ctx, _openPick), leading: const Icon(Icons.image)),
      ListTile(title: Text(locale.color), onTap: _closeable(ctx, _openColor), leading: const Icon(Icons.color_lens)),
      ListTile(title: Text(locale.clear), onTap: _closeable(ctx, _clear), leading: const Icon(Icons.clear)),
    ];
  }
}
