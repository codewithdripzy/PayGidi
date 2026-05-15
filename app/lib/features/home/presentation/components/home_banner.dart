import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      PgAssets.customIcon(iconName: 'squad_ad'),
      width: double.infinity,
      height: objectHeight(size: 114, context: context),
      fit: BoxFit.cover,
    );
  }
}
