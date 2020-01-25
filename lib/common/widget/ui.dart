import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Ui {
  static void route(BuildContext context, Widget widget) {
    PageRoute pageRoute;

    if (Platform.isIOS) {
      pageRoute = CupertinoPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      );
    }
    if (Platform.isAndroid) {
      pageRoute = MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      );
    }

    Navigator.push(context, pageRoute);
  }

  static Widget scaffold({
    @required Widget body,
    Widget bar,
    EdgeInsetsGeometry insets,
    Color bodyColor,
  }) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: bar,
        body: Container(
          color: bodyColor == null ? Colors.white : bodyColor,
          child: body,
          padding: insets,
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: bar,
        backgroundColor: bodyColor == null ? Colors.white : bodyColor,
        child: Container(
          color: bodyColor == null ? Colors.white : bodyColor,
          child: body,
          padding: insets,
        ),
      );
    }

    return null;
  }

  static Widget appBar({
    String title,
    Widget rightButton,
    Widget leftButton,
    centerTitle = true,
  }) {
    if (Platform.isAndroid) {
      return AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        actions: <Widget>[
          if (rightButton != null) rightButton,
        ],
        leading: leftButton,
        iconTheme: IconThemeData(color: Colors.blue),
      );
    }
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        leading: leftButton,
        middle: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        trailing: rightButton,
        backgroundColor: Colors.white,
      );
    }

    return null;
  }

  static Widget sliverAppBar({
    @required String title,
    Widget rightButton,
    Widget leftButton,
    centerTitle = true,
  }) {
    if (Platform.isAndroid) {
      return SliverAppBar(
        title: Text(title),
        centerTitle: centerTitle,
        backgroundColor: Colors.white,
        pinned: true,
        floating: true,
        actions: <Widget>[
          if (rightButton != null) rightButton,
        ],
        leading: leftButton,
//        forceElevated: innerBoxIsScrolled,
      );
    }

    return null;
  }

  static Widget actionButton(Widget icon, VoidCallback onPressed) {
    if (Platform.isAndroid) {
      return IconButton(
        icon: icon,
        onPressed: onPressed,
      );
    }
    if (Platform.isIOS) {
      return GestureDetector(
        child: icon,
        onTap: onPressed,
      );
    }
    return null;
  }

  static Widget waitIndicator() {
    if (Platform.isAndroid) {
      return const Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    if (Platform.isIOS) {
      return const CupertinoActivityIndicator();
    }
    return null;
  }

  static Widget flatButton(String title, VoidCallback onPressed, {double fontSize}) {
    Widget textChild = Text(
      title,
      style: TextStyle(fontSize: fontSize ?? 15),
    );
    if (Platform.isAndroid) {
      return FlatButton(onPressed: onPressed, child: textChild);
    }
    if (Platform.isIOS) {
      return CupertinoButton(child: textChild, onPressed: onPressed);
    }
    return null;
  }

  static Widget button(String title, Color color, Color textColor, VoidCallback onPressed) {
    Widget textChild = Text(title);
    if (Platform.isAndroid) {
      return RaisedButton(
        onPressed: onPressed,
        child: textChild,
        color: color,
        textColor: textColor,
      );
    }
    if (Platform.isIOS) {
      return CupertinoButton.filled(
        child: textChild,
        onPressed: onPressed,
      );
    }
    return null;
  }

  static Widget switchButton({@required ValueChanged<bool> onChanged}) {
    if (Platform.isAndroid) {
      return Switch(value: true, onChanged: onChanged);
    }
    if (Platform.isIOS) {
      return CupertinoSwitch(value: true, onChanged: onChanged);
    }
    return null;
  }

  static Widget dropdown({
    @required double width,
    @required String title,
    @required BuildContext context,
    @required List<String> valueItems,
    double fontSize,
  }) {
    if (Platform.isIOS) {
      return SizedBox(
        width: width,
        child: CupertinoButton(
            child: Text(
              title,
              style: TextStyle(fontSize: fontSize ?? 18),
            ),
            onPressed: () async {
              await showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext builder) {
                    return Container(
                      height: MediaQuery.of(context).copyWith().size.height / 3,
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 40,
                        onSelectedItemChanged: (int newValue) {},
                        children: <Widget>[
                          for (final item in valueItems)
                            Container(
                              child: Center(
                                child: Text(item),
                              ),
                            ),
                        ],
                      ),
                    );
                  });
            }),
      );
    }
    if (Platform.isAndroid) {
      return SizedBox(
        width: width,
        child: DropdownButton<String>(
          isExpanded: true,
          isDense: true,
          hint: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize ?? 18),
          ),
          onChanged: (String newValue) {},
          items: valueItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontSize: fontSize ?? 18),
              ),
            );
          }).toList(),
        ),
      );
    }

    return null;
  }

  static Widget dialog({@required Widget child, String title}) {
    if (Platform.isAndroid) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: child,
      );
    }
    if (Platform.isIOS) {
      return CupertinoPopupSurface(
        child: child,
      );
    }

    return null;
  }

  static void openDialog({BuildContext context, Widget dialog}) {
    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (ctx) {
            return dialog;
          });
    }
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return dialog;
          });
    }
  }

  static Widget refresh({
    @required Widget child,
    @required Future<void> Function() future,
  }) {
    if (Platform.isAndroid) {
      return RefreshIndicator(child: child, onRefresh: future);
    }
    if (Platform.isIOS) {
      return CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverRefreshControl(onRefresh: future),
          child,
        ],
      );
    }

    return null;
  }
}
