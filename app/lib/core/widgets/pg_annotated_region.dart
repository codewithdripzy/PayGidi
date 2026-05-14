import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildPGAnnotatedRegion({
  required Widget child,
  required Brightness brightness,
  required Color color,
}) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      statusBarColor: color,
      statusBarIconBrightness: brightness,
    ),
    child: SafeArea(child: child),
  );
}

Widget heightSpacing(double height) => SizedBox(height: height);
Widget widthSpacing(double width) => SizedBox(width: width);
