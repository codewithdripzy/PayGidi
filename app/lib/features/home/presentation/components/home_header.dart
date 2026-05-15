import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Row(
      children: [
        SvgPicture.asset(
          PgAssets.customIcon(iconName: "agidi"),
          height: objectHeight(size: 50, context: context),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PgTexts.text400(
              context,
              text: "Good Afternoon",
              fontSize: 12,
              color: Colors.grey,
            ),
            PgTexts.text700(
              context,
              text: authProvider.userName ?? "Guest User",
              fontSize: 16,
              color: PgColors.black,
              fontFamily: PgFonts.googleSans,
            ),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            const Icon(Iconsax.notification_copy, size: 28),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
