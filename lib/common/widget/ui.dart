import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/svg_icon.dart';

class Ui {
  static void route(BuildContext context, Widget widget, {bool withHistory = true}) {
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
    if (withHistory) {
      Navigator.push(context, pageRoute);
    } else {
      Navigator.pushAndRemoveUntil(context, pageRoute, (Route<dynamic> route) => false);
    }
  }

  static Widget scaffold({
    @required Widget body,
    Widget bar,
    EdgeInsetsGeometry insets,
    Color bodyColor = Colors.white,
    Widget float,
  }) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: bar,
        body: Container(
          color: bodyColor == null ? Constant.bgColor : bodyColor,
          child: body,
          padding: insets,
        ),
        floatingActionButton: float,
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: bar,
        backgroundColor: bodyColor,
        child: Container(
          color: bodyColor,
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
    bool centerTitle = true,
  }) {
    final textColor = Constant.getColor(Colors.white, Colors.black);
    if (Platform.isAndroid) {
      return AppBar(
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        centerTitle: centerTitle,
        backgroundColor: Constant.bgColor,
        brightness: Brightness.light,
        actions: <Widget>[
          if (rightButton != null) rightButton,
        ],
        leading: leftButton,
        iconTheme: IconThemeData(color: Constant.getColor(Colors.white, Colors.blue)),
      );
    }
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        leading: leftButton,
        middle: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
        trailing: rightButton,
        backgroundColor: Constant.bgColor,
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
        backgroundColor: Constant.bgColor,
        pinned: true,
        floating: true,
        actions: <Widget>[
          if (rightButton != null) rightButton,
        ],
        leading: leftButton,
//        forceElevated: innerBoxIsScrolled,
      );
    }
    if (Platform.isIOS) {
      return CupertinoSliverNavigationBar(
        largeTitle: Text(title),
        backgroundColor: Constant.bgColor,
        trailing: rightButton,
        leading: leftButton,
        middle: Text(title),
      );
    }

    return null;
  }

  static Widget actionButton(Widget icon, VoidCallback onPressed) {
    final iconColor = Constant.getColor(Colors.white, Colors.blue);
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

  static Widget actionSvgButton(String icon, VoidCallback onPressed) {
    if (Platform.isAndroid) {
      return IconButton(
        icon: SvgIcon(path: icon, color: Constant.getColor(Colors.white, Colors.blue)),
        onPressed: onPressed,
      );
    }
    if (Platform.isIOS) {
      return GestureDetector(
        child: SvgIcon(path: icon, color: Constant.getColor(Colors.white, Colors.blue)),
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

  static Widget flatButton(String title, VoidCallback onPressed, {double fontSize, TextStyle style}) {
    Widget textChild = Text(
      title,
      style: style,
    );
    if (Platform.isAndroid) {
      return FlatButton(onPressed: onPressed, child: textChild);
    }
    if (Platform.isIOS) {
      return CupertinoButton(child: textChild, onPressed: onPressed);
    }
    return null;
  }

  static Widget button({
    String title,
    Color color = Colors.blue,
    Color textColor = Colors.white,
    VoidCallback onPressed,
    double radius,
    TextStyle textStyle,
  }) {
    Widget textChild = Text(title, style: textStyle);
    if (Platform.isAndroid) {
      return RaisedButton(
        onPressed: onPressed,
        child: textChild,
        color: color,
        textColor: textColor,
        shape: radius == null ? null : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      );
    }
    if (Platform.isIOS) {
      return CupertinoButton.filled(
        child: textChild,
        onPressed: onPressed,
        borderRadius: BorderRadius.all(Radius.circular(radius == null ? 8 : radius)),
      );
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

  static Widget dialog({@required Widget child}) {
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

  static void showAlert({
    @required WidgetBuilder builder,
    @required BuildContext context,
  }) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: builder,
      );
    }
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: builder,
      );
    }
  }

  static Widget alertDialog({
    @required String title,
    @required Widget child,
    @required List<Widget> actions,
    @required BuildContext context,
  }) {
    if (Platform.isAndroid) {
      return AlertDialog(
        title: Text(title),
        elevation: 0,
        content: child,
        actions: actions,
      );
    }
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: child,
        actions: actions,
      );
    }

    return null;
  }

  static Widget alertAction({
    @required BuildContext context,
    @required Function onPressed,
    @required String text,
    bool isDestructive = false,
  }) {
    if (Platform.isIOS) {
      return CupertinoDialogAction(
        child: Text(text),
        onPressed: onPressed,
        isDestructiveAction: isDestructive,
      );
    }
    if (Platform.isAndroid) {
      return FlatButton(
        child: Text(text),
        onPressed: onPressed,
      );
    }

    return null;
  }

  static void openDialog({
    @required BuildContext context,
    @required Widget dialog,
  }) {
    if (Platform.isAndroid) {
      showDialog(context: context, builder: (_) => dialog);
    }
    if (Platform.isIOS) {
      showCupertinoDialog(context: context, builder: (_) => dialog);
    }
  }

  static Future showActionSheet({
    @required BuildContext context,
    @required WidgetBuilder builder,
  }) async {
    if (Platform.isIOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: builder,
      );
    }
    if (Platform.isAndroid) {
      await showModalBottomSheet(
        context: context,
        builder: builder,
      );
    }
  }

  static Widget actionSheet({
    @required BuildContext context,
    @required List<Widget> iosActions,
    @required List<Widget> androidActions,
  }) {
    if (Platform.isIOS) {
      return CupertinoActionSheet(
        actions: iosActions,
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
          isDestructiveAction: true,
        ),
      );
    }
    if (Platform.isAndroid) {
      return Container(
        child: Wrap(
          children: androidActions,
        ),
      );
    }

    return null;
  }

  static Widget icon(IconData forIos, IconData forDroid, {Color color, double size}) {
    return Icon(Platform.isIOS ? forIos : forDroid);
  }

  static Widget wswitch({
    @required bool value,
    @required ValueChanged<bool> onChange,
  }) {
    if (Platform.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChange,
      );
    }
    if (Platform.isAndroid) {
      return Switch(
        value: value,
        onChanged: onChange,
      );
    }
  }
}
