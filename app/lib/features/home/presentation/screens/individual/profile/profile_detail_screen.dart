import 'package:app/core/theme/pg_colors.dart';
// import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';

class IndividualProfileDetailScreen extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? content;

  const IndividualProfileDetailScreen({
    super.key,
    required this.title,
    this.description,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return buildPGAnnotatedRegion(
      brightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacing(24),
                PgScaleButton(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_outlined,
                      size: 20,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: title,
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                if (description != null) ...[
                  heightSpacing(4),
                  PgTexts.text400(
                    context,
                    text: description!,
                    fontSize: 16,
                    color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                        .withValues(alpha: 0.7),
                  ),
                ],
                heightSpacing(32),
                Expanded(
                  child: content ??
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.construction_rounded,
                              size: 64,
                              color: PgColors.primary.withValues(alpha: 0.2),
                            ),
                            heightSpacing(16),
                            PgTexts.text600(
                              context,
                              text: "Coming Soon",
                              fontSize: 18,
                              color: theme.textTheme.bodyLarge?.color ??
                                  PgColors.black,
                            ),
                            heightSpacing(8),
                            PgTexts.text400(
                              context,
                              text: "We're working hard to bring you this feature.",
                              textAlign: TextAlign.center,
                              color: (theme.textTheme.bodyMedium?.color ??
                                      PgColors.black)
                                  .withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
