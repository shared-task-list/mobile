import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/color_set_dialog.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/join/join_screen.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/settings/category_dialog.dart';
import 'package:shared_task_list/settings/settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _bloc = SettingsBloc();
  final _primaryStyle = TextStyle(fontSize: 18, color: Colors.black);
  final _secondStyle = TextStyle(fontSize: 15, color: Colors.grey);
  Settings _settings;
  S locale;

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);

    return StreamBuilder<Color>(
        stream: _bloc.bgColor,
        builder: (context, streamSnapshot) {
          return Ui.scaffold(
            bar: Ui.appBar(title: locale.settings),
            body: FutureBuilder<Settings>(
                future: _bloc.getSettings(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  _settings = snapshot.data;
                  _bloc.setVisibleCats(_settings.isShowCategories);
                  _bloc.category.add(_settings.defaultCategory);

                  return Material(
                    color: streamSnapshot.data,
                    child: _buildBody(context),
                  );
                }),
          );
        });
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            StreamBuilder<String>(
                stream: _bloc.category,
                builder: (context, snapshot) {
                  final cat = snapshot.data ?? '';
                  return _buildRow(
                      primaryText: locale.defaultCategory,
                      secondText: cat.isEmpty ? Constant.noCategory : cat,
                      onTap: () {
                        Ui.openDialog(
                            context: context,
                            dialog: CategoryDialog(
                              savedCategory: _settings.defaultCategory,
                              onChanged: (String category) {
                                //save
                                _settings.defaultCategory = category;
                                _bloc.saveSettings(_settings);
                                _bloc.category.add(category);
                              },
                            ));
                      });
                }),
            // show/hide
            InkWell(
              onTap: () {
                setState(() {
                  _settings.isShowQuickAdd = !_settings.isShowQuickAdd;
                });
                _bloc.saveSettings(_settings);
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
                    Ui.wswitch(
                      value: _settings.isShowQuickAdd,
                      onChange: (bool value) {
                        setState(() {
                          _settings.isShowQuickAdd = value;
                        });
                        _bloc.saveSettings(_settings);
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

                  final prefs = snapshot.data;
                  String name = prefs.getString(Constant.authorKey) ?? '';
                  _bloc.name.add(name);

                  return StreamBuilder<String>(
                      stream: _bloc.name,
                      builder: (ctx, snapshot) {
                        final data = snapshot.data ?? '';
                        return _buildRow(
                            primaryText: locale.username,
                            secondText: data,
                            onTap: () {
                              Ui.openDialog(
                                context: context,
                                dialog: TextFieldDialog(
                                  savePressed: (String newName) {
                                    _bloc.name.add(newName);
                                    prefs.setString(Constant.authorKey, newName);
                                  },
                                  title: locale.newName,
                                  labelText: null,
                                  hintText: locale.newName,
                                ),
                              );
                            });
                      });
                }),
            _buildRow(
              primaryText: locale.background,
              secondText: '',
              onTap: () {
                Ui.showActionSheet(
                  context: context,
                  builder: (ctx) => Ui.actionSheet(
                    context: ctx,
                    iosActions: _getBackgroundMenuOptions(ctx, forIos: true),
                    androidActions: _getBackgroundMenuOptions(ctx, forIos: false),
                  ),
                );
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 55),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 200,
                    child: Ui.flatButton(
                      locale.exit,
                      () async {
                        await _bloc.exit();
                        Ui.route(context, JoinScreen(), withHistory: false);
                      },
                      style: TextStyle(color: Colors.red, fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ],
    );
  }

  Future _openColor() async {
    Ui.openDialog(
      context: context,
      dialog: ColorSetDialog(
        onSetColor: (Color color) async {
          final colorString = "${color.red},${color.green},${color.blue}";
          var prefs = await SharedPreferences.getInstance();
          prefs.setString('bg_color', colorString);
          Constant.bgColor = color;
          _bloc.bgColor.add(color);
        },
      ),
    );
  }

  Future _openPick() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path;

    var bytes = await image.readAsBytes();
    String fileName = image.path.split('/').last;

    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes);

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('bg_name', fileName);
  }

  Widget _buildRow({
    @required String primaryText,
    @required String secondText,
    @required GestureTapCallback onTap,
    Widget trailing,
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
    _bloc.bgColor.add(Colors.white);
  }

  Function _closeable(BuildContext ctx, Function f) {
    return () {
      Navigator.pop(ctx);
      f();
    };
  }

  List<Widget> _getBackgroundMenuOptions(BuildContext ctx, {@required bool forIos}) {
    if (forIos) {
      return [
        CupertinoActionSheetAction(child: Text(locale.image), onPressed: _closeable(ctx, _openPick)),
        CupertinoActionSheetAction(child: Text(locale.color), onPressed: _closeable(ctx, _openColor)),
        CupertinoActionSheetAction(child: Text(locale.clear), onPressed: _closeable(ctx, _clear)),
      ];
    }

    return [
      ListTile(title: Text(locale.image), onTap: _closeable(ctx, _openPick), leading: const Icon(Icons.image)),
      ListTile(title: Text(locale.color), onTap: _closeable(ctx, _openColor), leading: const Icon(Icons.color_lens)),
      ListTile(title: Text(locale.clear), onTap: _closeable(ctx, _clear), leading: const Icon(Icons.clear)),
    ];
  }
}
