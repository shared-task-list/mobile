import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/text_field_dialog.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
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
              color: Colors.white,
              child: _buildBody(context),
            );
          }),
//      insets: const EdgeInsets.symmetric(horizontal: 16),
    );
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
            SizedBox(height: 50),
          ],
        ),
//        _buildSaveButton(),
      ],
    );
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
            ),
          ],
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildSaveButton() {
    final double width = 200;
    final double leftMargin = (MediaQuery.of(context).size.width / 2) - (width / 2);
    return Positioned(
      bottom: 20,
      left: leftMargin,
      child: SizedBox(
        width: width,
        height: 45,
        child: Ui.button(
          title: 'Save',
          radius: 40,
          onPressed: () {},
        ),
      ),
    );
  }
}
