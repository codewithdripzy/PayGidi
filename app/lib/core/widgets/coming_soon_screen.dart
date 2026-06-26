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
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heightSpacing(24),
            PgTexts.text700(
              context,
              text: title,
              fontSize: 28,
              color: theme.textTheme.titleLarge?.color ?? PgColors.black,
              fontFamily: PgFonts.stackSans,
            ),
            heightSpacing(4),
            PgTexts.text400(
              context,
              text: "We're building something great for you.",
              fontSize: 16,
              color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                  .withValues(alpha: 0.7),
            ),
            heightSpacing(32),
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade100,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              PgColors.primary,
                              PgColors.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PgColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 40),
                      ),
                      heightSpacing(24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: PgColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: PgTexts.text500(
                          context,
                          text: "Coming Soon",
                          fontSize: 12,
                          color: PgColors.primary,
                        ),
                      ),
                      heightSpacing(16),
                      PgTexts.text600(
                        context,
                        text: "Virtual & Physical Cards",
                        fontSize: 18,
                        color:
                            theme.textTheme.bodyLarge?.color ?? PgColors.black,
                        textAlign: TextAlign.center,
                      ),
                      heightSpacing(8),
                      PgTexts.text400(
                        context,
                        text:
                            "Create virtual cards for secure online payments and order a physical card for everyday spending. We'll let you know as soon as it's ready.",
                        fontSize: 14,
                        color: (theme.textTheme.bodyMedium?.color ??
                                PgColors.black)
                            .withValues(alpha: 0.7),
                        textAlign: TextAlign.center,
                      ),
                      heightSpacing(32),
                      PgScaleButton(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "We'll notify you when cards are available!",
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
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: const LinearGradient(
                              colors: [
                                PgColors.primary,
                                PgColors.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: PgTexts.text600(
                            context,
                            text: "Notify Me",
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
