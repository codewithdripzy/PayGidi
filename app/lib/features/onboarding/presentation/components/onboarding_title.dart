import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';

class OnboardingTitle extends StatelessWidget {
  final int index;

  const OnboardingTitle({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (index < 2) ...[
              PgTexts.gradientText(
                context,
                text: index == 0 ? 'Pay' : 'Trust',
                fontSize: 34,
                textAlign: TextAlign.start,
                fontWeight: FontWeight.bold,
                gradient: const LinearGradient(
                  colors: [PgColors.primary, PgColors.secondary],
                ),
              ),
              const SizedBox(width: 8),
              PgTexts.text700(
                context,
                textAlign: TextAlign.start,
                text: index == 0 ? 'with Confidence' : 'while Money Moves',
                fontSize: 34,
                color: Colors.white,
              ),
            ] else ...[
              PgTexts.text700(
                context,
                textAlign: TextAlign.start,
                text: 'Built for Smarter',
                color: Colors.white,
                fontSize: 34,
              ),
              const SizedBox(width: 8),
              PgTexts.gradientText(
                context,
                text: 'Trade',
                fontSize: 34,
                textAlign: TextAlign.start,
                fontWeight: FontWeight.bold,
                gradient: const LinearGradient(
                  colors: [PgColors.primary, PgColors.secondary],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
