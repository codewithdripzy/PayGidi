import 'package:flutter/material.dart';

class PgFonts {
  PgFonts._();

  static const String stackSans = 'StackSansNotch';
  static const String googleSans = 'Google Sans Flex';
  static const String googleSans9 = 'Google Sans Flex 9pt';
  static const String googleSans36 = 'Google Sans Flex 36pt';
  static const String googleSans72 = 'Google Sans Flex 72pt';
  static const String googleSans120 = 'Google Sans Flex 120pt';

  static const String fontFamily = stackSans;

  static const TextStyle extraLight = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w200,
  );

  static const TextStyle light = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle regular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle medium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle semiBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
  );
}
