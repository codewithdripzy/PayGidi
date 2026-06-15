import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';

class FinanceGoals extends StatelessWidget {
  const FinanceGoals({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PgTexts.text500(
              context,
              text: "Savings Goals",
              fontSize: 14,
              color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                  .withValues(alpha: 0.5),
            ),
            PgTexts.gradientText(
              context,
              text: "See All",
              fontSize: 14,
              gradient: PgColors.primaryGradient,
            ),
          ],
        ),
        heightSpacing(8),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildGoalCard(
                context,
                title: "New Car",
                target: "₦5,000,000",
                saved: "₦1,200,000",
                percentage: 0.24,
                image: "assets/onboarding_images/page1.jpeg",
              ),
              const SizedBox(width: 16),
              _buildGoalCard(
                context,
                title: "Vacation",
                target: "₦800,000",
                saved: "₦650,000",
                percentage: 0.81,
                image: "assets/onboarding_images/page2.jpeg",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required String title,
    required String target,
    required String saved,
    required double percentage,
    required String image,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? null : PgColors.black1,
        gradient: isDark
            ? const LinearGradient(
                colors: [PgColors.secondary, Color(0xFF6B0043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text500(
                  context,
                  text: title,
                  fontSize: 14,
                  color: Colors.white70,
                ),
                const SizedBox(height: 4),
                PgTexts.text700(
                  context,
                  text: saved,
                  fontSize: 18,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PgTexts.text400(
                      context,
                      text: "Target: $target",
                      fontSize: 10,
                      color: Colors.white60,
                    ),
                    PgTexts.text600(
                      context,
                      text: "${(percentage * 100).toInt()}%",
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
