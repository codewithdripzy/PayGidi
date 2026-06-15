import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/home/presentation/screens/individual/profile/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

/// A custom header for the Home Screen that displays the app logo,
/// a personalized greeting for the user, and a notification icon.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    debugPrint("user data: ${authProvider.userData}");
    return Row(
      children: [
        SvgPicture.asset(
          PgAssets.customIcon(iconName: "agidi"),
          height: objectHeight(size: 50, context: context),
          colorFilter: theme.brightness == Brightness.dark
              ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
              : null,
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
              text: authProvider.userData?.firstName ?? "Guest User",
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
              fontFamily: PgFonts.googleSans,
            ),
          ],
        ),
        const Spacer(),
        PgScaleButton(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          ),
          child: Stack(
            children: [
              Icon(
                Iconsax.notification_copy,
                size: 28,
                color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
              ),
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
        ),
      ],
    );
  }
}
