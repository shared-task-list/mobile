import 'dart:io';

/**
 * Author: Damodar Lohani
 * profile: https://github.com/lohanidamodar
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/ui.dart';
import 'package:shared_task_list/generated/l10n.dart';
import 'package:shared_task_list/join/join_bloc.dart';
import 'package:shared_task_list/model/task_list.dart';
import 'package:shared_task_list/task_list/task_list_screen.dart';

class JoinScreen extends StatelessWidget {
  final _bloc = JoinBloc();
  final _formKey = GlobalKey<FormState>();

  Widget _buildPageContent(BuildContext context) {
    _bloc.getTaskLists();

    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ));
    }

    return Container(
      color: Colors.blue.shade100,
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          /*CircleAvatar(
              child: PNetworkImage(origami),
              maxRadius: 50,
              backgroundColor: Colors.transparent,
            ),*/
          SizedBox(
            height: 20.0,
          ),
          _buildLoginForm(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Ui.flatButton(S.of(context).create, () async {
                if (!_formKey.currentState.validate()) {
                  return;
                }
                bool isExist = await _bloc.isExist();

                if (isExist) {
                  _alertDialog(context, S.of(context).taskListExists);
                  return;
                }

                await _bloc.create();
                await _bloc.savePreferences();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => TaskListScreen(),
                  ),
                );
              }, style: TextStyle(color: Colors.blue, fontSize: 18.0)),
            ],
          ),
          SizedBox(height: 20),
          _buildRecentLists(),
        ],
      ),
    );
  }

  Widget _buildRecentLists() {
    return StreamBuilder<List<TaskList>>(
        stream: _bloc.taskLists,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Container();
          }

          List<Widget> widgets = [
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Recent Lists',
                    style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ];

          for (final list in snapshot.data) {
            if (list.name == null || list.name.isEmpty) {
              continue;
            }
            widgets.add(ListTile(
              leading: Text(
                list.name,
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _bloc.removeList(list);
                },
              ),
              onTap: () async {
                _bloc.taskList = list.name;
                _bloc.password = list.password;
                _bloc.updateList(list.id);

                await _bloc.savePreferences();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => TaskListScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ));
            /*widgets.add(Divider(
                  height: 0.5,
                  color: Colors.grey,
                ));*/
          }

          return Column(
            children: widgets,
          );
        });
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        height: 480,
        padding: EdgeInsets.all(20.0),
        child: Stack(
          children: <Widget>[
            ClipPath(
              clipper: RoundedDiagonalPathClipper(),
              child: Container(
                height: 420,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  color: Colors.white,
                ),
                child: FutureBuilder(
                  future: _bloc.getPreferences(),
                  builder: (ctx, snapshot) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 90.0,
                        ),
                        ..._buildFormRow(
                          hintText: S.of(context).username,
                          icon: Icons.person,
                          value: Constant.userName,
                          valueChanged: (String value) {
                            _bloc.username = value;
                            Constant.userName = value;
                          },
                        ),
                        ..._buildFormRow(
                          hintText: S.of(context).taskListName,
                          icon: Icons.list,
                          value: Constant.taskList,
                          valueChanged: (String value) {
                            _bloc.taskList = value;
                            Constant.taskList = value;
                          },
                        ),
                        ..._buildFormRow(
                          hintText: S.of(context).password,
                          icon: Icons.lock,
                          isPassword: true,
                          value: Constant.password,
                          valueChanged: (String value) {
                            _bloc.password = value;
                            Constant.password = value;
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.blue.shade600,
                  child: Icon(Icons.person),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: MediaQuery.of(context).size.width / 2 - (Platform.isIOS ? 100 : 65),
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Ui.button(
                      title: S.of(context).open,
                      radius: 40,
                      textStyle: TextStyle(color: Colors.white70),
                      onPressed: () async {
                        if (_formKey.currentState != null && !_formKey.currentState.validate()) {
                          return;
                        }
                        bool isExist = await _bloc.isExist();

                        if (!isExist) {
                          _alertDialog(context, S.of(context).openError);
                          return;
                        }

                        await _bloc.savePreferences();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => TaskListScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(context),
    );
  }

  List<Widget> _buildFormRow({
    ValueChanged<String> valueChanged,
    String hintText,
    String value,
    IconData icon,
    bool isPassword = false,
    BuildContext context,
  }) {
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          initialValue: value,
          style: TextStyle(color: Colors.blue),
          obscureText: isPassword,
          decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.blue.shade200),
              border: InputBorder.none,
              icon: Icon(
                icon,
                color: Colors.blue,
              )),
          onChanged: valueChanged,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).required;
            }
            return null;
          },
        ),
      ),
      Container(
        child: Divider(
          color: Colors.blue.shade400,
        ),
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
      ),
    ];
  }

  _alertDialog(BuildContext context, String alertText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BeautifulAlertDialog(alertText: alertText);
      },
    );
  }
}

class BeautifulAlertDialog extends StatelessWidget {
  final String alertText;

  const BeautifulAlertDialog({Key key, this.alertText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(right: 16.0),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 40.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).error,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 10.0),
                    Flexible(
                      child: Text(alertText),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("Ok"),
                          color: Colors.red,
                          colorBrightness: Brightness.dark,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
