import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';

class OnboardingTitle extends StatelessWidget {
  final int index;

  const OnboardingTitle({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        if (index < 2) ...[
          PgTexts.gradientText(
            context,
            text: index == 0 ? "Pay" : "Trust ",
            fontSize: 43,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.bold,
            gradient: const LinearGradient(
              colors: [PgColors.primary, PgColors.secondary],
            ),
          ),
          PgTexts.text700(
            context,
            textAlign: TextAlign.start,
            text: index == 0 ? " with Confidence" : "while Money",
            fontSize: 38,
            color: Colors.white,
          ),
          if (index == 1)
            PgTexts.text700(
              context,
              textAlign: TextAlign.start,
              text: "Moves",
              fontSize: 38,
              color: Colors.white,
            ),
        ] else ...[
          PgTexts.text700(
            context,
            textAlign: TextAlign.start,
            text: "Built for Smarter ",
            color: PgColors.scaffoldBackground,
            fontSize: 43,
          ),
          PgTexts.gradientText(
            context,
            text: "Trade",
            fontSize: 46,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.bold,
            gradient: const LinearGradient(
              colors: [PgColors.primary, PgColors.secondary],
            ),
          ),
        ],
      ],
    );
  }
}
