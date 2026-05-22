import 'package:app/core/theme/pg_colors.dart';
import 'package:flutter/material.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const OnboardingIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: currentIndex == index ? 40 : 25,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: currentIndex == index
                  ? const LinearGradient(
                      colors: [PgColors.primary, PgColors.secondary],
                    )
                  : const LinearGradient(
                      colors: [PgColors.black3, PgColors.black3],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
