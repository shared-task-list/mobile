import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final double width;
  final double height;
  final String path;
  final Color color;

  const SvgIcon({
    Key key,
    this.width = 24,
    this.height = 24,
    @required this.path,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/image/$path.svg",
      width: width,
      height: height,
      color: color,
    );
  }
}
