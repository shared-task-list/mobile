import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/model/settings.dart';
import 'package:shared_task_list/settings/category_dialog.dart';
import 'package:shared_task_list/settings/settings_bloc.dart';
import 'package:shared_task_list/task_list/color_set_dialog.dart';

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
//      insets: const EdgeInsets.symmetric(horizontal: 16),
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
            /*InkWell(
              onTap: () {
                bool value = !_bloc.visibleCats;
                _bloc.setVisibleCats(value);
                _settings.isShowCategories = value;
                _bloc.saveSettings(_settings);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Expand Categories',
                      style: _primaryStyle,
                    ),
                    StreamBuilder<bool>(
                        stream: _bloc.isShowCategories,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          return Switch.adaptive(
                            value: snapshot.data,
                            onChanged: (bool value) {
                              _bloc.setVisibleCats(value);
                              _settings.isShowCategories = value;
                              _bloc.saveSettings(_settings);
                            },
                          );
                        }),
                  ],
                ),
              ),
            ),*/
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
              primaryText: 'Background',
              secondText: '',
              onTap: () async {
                Ui.actionSheet(
                  context: context,
                  iosActions: _getBackgroundMenuOptions(forIos: true),
                  androidActions: _getBackgroundMenuOptions(forIos: false),
                );
              },
            ),
            SizedBox(height: 50),
          ],
        ),
//        _buildSaveButton(),
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

  Function _closeable(Function f) {
    return () {
      Navigator.of(context).pop();
      f();
    };
  }

  List<Widget> _getBackgroundMenuOptions({@required bool forIos}) {
    if (forIos) {
      return [
        CupertinoActionSheetAction(child: Text('Image'), onPressed: _closeable(_openPick)),
        CupertinoActionSheetAction(child: Text('Color'), onPressed: _closeable(_openColor)),
        CupertinoActionSheetAction(child: Text('Clear'), onPressed: _closeable(_clear)),
      ];
    }

    return [
      ListTile(title: Text('Image'), onTap: _closeable(_openPick), leading: Icon(Icons.image)),
      ListTile(title: Text('Color'), onTap: _closeable(_openColor), leading: Icon(Icons.color_lens)),
      ListTile(title: Text('Color'), onTap: _closeable(_clear), leading: Icon(Icons.clear)),
    ];
  }
}
