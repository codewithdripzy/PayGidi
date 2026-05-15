import 'package:flutter/material.dart';

class PgStyles {
  PgStyles._();
  static TextStyle textStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    TextDecoration? textDecoration,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    required BuildContext context,
    String? fontFamily,
  }) {
    return TextStyle(
      overflow: textOverflow,
      height: height,
      color: color,
      fontWeight: fontWeight,
      fontSize: objectWidth(context: context, size: fontSize),
      decoration: textDecoration,
      decorationColor: color,
      fontFamily: fontFamily ?? 'Google Sans Flex',
    );
  }
}

double mediaQueryWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double mediaQueryHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double objectWidth({required num size, required BuildContext context}) {
  return MediaQuery.sizeOf(context).width * (size / 430);
}

double objectHeight({required num size, required BuildContext context}) {
  return MediaQuery.sizeOf(context).height * (size / 932);
}
