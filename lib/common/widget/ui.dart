import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/widget/svg_icon.dart';

class Ui {
  static Future route(BuildContext context, Widget widget, {bool withHistory = true}) async {
    PageRoute pageRoute;

    pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return widget;
      },
    );
    if (withHistory) {
      await Navigator.push(context, pageRoute);
    } else {
      await Navigator.pushAndRemoveUntil(context, pageRoute, (Route<dynamic> route) => false);
    }
  }

  static Widget scaffold({
    required Widget body,
    PreferredSizeWidget? bar,
    EdgeInsetsGeometry? insets,
    Color bodyColor = Colors.white,
    Widget? float,
  }) {
    return Scaffold(
      appBar: bar,
      body: Container(
        color: bodyColor,
        child: body,
        padding: insets,
      ),
      floatingActionButton: float,
    );
  }

  static PreferredSizeWidget appBar({
    required String title,
    Widget? rightButton,
    Widget? leftButton,
    bool centerTitle = true,
  }) {
    final textColor = Constant.getColor(Colors.white, Colors.black);
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
      iconTheme: IconThemeData(color: Constant.primaryColor),
    );
  }

  static Widget sliverAppBar({
    required String title,
    Widget? rightButton,
    Widget? leftButton,
    centerTitle = true,
  }) {
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

  static Widget actionButton(Widget icon, VoidCallback onPressed) {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
    );
  }

  static Widget actionSvgButton(String icon, VoidCallback onPressed) {
    return IconButton(
      icon: SvgIcon(path: icon, color: Constant.primaryColor),
      onPressed: onPressed,
    );
  }

  static Widget waitIndicator() {
    return const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  static Widget dialog({required Widget child}) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: child,
    );
  }

  static void showAlert({
    required WidgetBuilder builder,
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder: builder,
    );
  }

  static Widget alertDialog({
    required String title,
    required Widget child,
    required List<Widget> actions,
    required BuildContext context,
  }) {
    return AlertDialog(
      title: Text(title),
      elevation: 0,
      content: child,
      actions: actions,
    );
  }

  static Widget alertAction({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    bool isDestructive = false,
  }) {
    return TextButton(
      child: Text(text),
      onPressed: onPressed,
    );
  }

  static Future openDialog({
    required BuildContext context,
    required Widget dialog,
  }) async {
    await showDialog(context: context, builder: (_) => dialog);
  }
}
