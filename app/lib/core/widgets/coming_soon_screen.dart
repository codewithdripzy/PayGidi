import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoonScreen({
    super.key,
    required this.title,
    this.icon = Iconsax.card_copy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heightSpacing(24),
            Row(
              children: [
                PgTexts.text700(
                  context,
                  text: title,
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                  fontFamily: PgFonts.stackSans,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PgColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: PgTexts.text500(
                    context,
                    text: "Coming Soon",
                    fontSize: 11,
                    color: PgColors.primary,
                  ),
                ),
              ],
            ),
            heightSpacing(2),
            PgTexts.text400(
              context,
              text: "We're building something great for you.",
              fontSize: 16,
              color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                  .withValues(alpha: 0.7),
              maxLines: 2,
            ),
            heightSpacing(32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: PgColors.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: PgColors.primary, size: 40),
                    ),
                    heightSpacing(24),
                    PgTexts.text600(
                      context,
                      text: "Virtual & Physical Cards",
                      fontSize: 19,
                      color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                      textAlign: TextAlign.center,
                    ),
                    heightSpacing(5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        "Create virtual cards for secure online payments and order a physical card for everyday spending.",
                        style: TextStyle(
                          color:
                              (theme.textTheme.bodyMedium?.color ??
                                      PgColors.black)
                                  .withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    heightSpacing(24),
                    PgScaleButton(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(
                                  Iconsax.notification_copy,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text("We'll notify you when it's available!"),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        width: 170,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: const LinearGradient(
                            colors: [PgColors.primary, PgColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.notification_copy,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            PgTexts.text600(
                              context,
                              text: "Notify Me",
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
