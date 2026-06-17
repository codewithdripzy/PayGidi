import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_gradient_text.dart';
import 'package:flutter/material.dart';

class ScaleSize {
  static double textScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Very small phones (e.g., iPhone SE 1st gen)
    if (width < 360) {
      return 0.7;
    }
    // Small phones
    else if (width < 400) {
      return 0.95;
    }
    // Standard-sized phones (this is our baseline)
    else if (width < 600) {
      return 1.03;
    }
    // Large phones & Small tablets
    else if (width < 900) {
      return 1.2;
    }
    // Large tablets and web
    else {
      return 1.3;
    }
  }
}

class PgTexts {
  PgTexts._();

  static Widget text400(
    BuildContext context, {
    required String text,
    TextAlign textAlign = TextAlign.start,
    Color color = PgColors.black,
    double fontSize = 14,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    String? fontFamily,
    double? height,
    int? maxLines,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: PgStyles.textStyle(
        context: context,
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
        height: height,
      ),
      textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
      overflow: textOverflow,
      maxLines: maxLines,
    );
  }

  static Widget text500(
    BuildContext context, {
    required String text,
    TextAlign textAlign = TextAlign.start,
    Color color = PgColors.black,
    double fontSize = 12,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    String? fontFamily,
    int? maxLines,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: PgStyles.textStyle(
        context: context,
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      overflow: textOverflow,
      textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
      maxLines: maxLines,
    );
  }

  static Widget text700(
    BuildContext context, {
    required String text,
    TextAlign textAlign = TextAlign.start,
    Color color = PgColors.black,
    double fontSize = 20,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    String? fontFamily,
    int? maxLines,
  }) {
    return Text(
      text,
      textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
      textAlign: textAlign,
      overflow: textOverflow,
      maxLines: maxLines,
      style: PgStyles.textStyle(
        context: context,
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        fontFamily: fontFamily,
      ),
    );
  }

  static Widget text600(
    BuildContext context, {
    required String text,
    TextAlign textAlign = TextAlign.start,
    Color color = PgColors.black,
    double fontSize = 24,
    TextDecoration textDecoration = TextDecoration.none,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    String? fontFamily,
    int? maxLines,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: textOverflow,
      textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
      maxLines: maxLines,
      style: PgStyles.textStyle(
        context: context,
        textDecoration: textDecoration,
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
    );
  }

  static Widget gradientText(
    BuildContext context, {
    required String text,
    required Gradient gradient,
    TextAlign textAlign = TextAlign.start,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w600,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    String? fontFamily,
  }) {
    return PgGradientText(
      text,
      gradient: gradient,
      textAlign: textAlign,
      style: PgStyles.textStyle(
        context: context,
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
        textOverflow: textOverflow,
        fontFamily: fontFamily,
      ),
    );
  }
}
