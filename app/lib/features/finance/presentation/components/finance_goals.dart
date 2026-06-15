import 'package:app/core/theme/pg_colors.dart';
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
            PgTexts.text700(
              context,
              text: "Savings Goals",
              fontSize: 18,
              color: theme.textTheme.titleLarge?.color ?? PgColors.black,
            ),
            TextButton(
              onPressed: () {},
              child: PgTexts.text600(
                context,
                text: "See All",
                fontSize: 14,
                color: PgColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
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
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PgTexts.text600(
                  context,
                  text: title,
                  fontSize: 16,
                  color: theme.textTheme.titleMedium?.color ?? PgColors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          PgTexts.text400(
            context,
            text: "Saved",
            fontSize: 12,
            color: Colors.grey,
          ),
          PgTexts.text700(
            context,
            text: saved,
            fontSize: 18,
            color: PgColors.primary,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PgTexts.text400(
                context,
                text: "Target: $target",
                fontSize: 10,
                color: Colors.grey,
              ),
              PgTexts.text600(
                context,
                text: "${(percentage * 100).toInt()}%",
                fontSize: 10,
                color: theme.textTheme.titleMedium?.color ?? PgColors.black,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: PgColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(PgColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
