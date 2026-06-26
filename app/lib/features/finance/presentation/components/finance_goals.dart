import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/finance/data/models/savings_goal_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class FinanceGoals extends StatelessWidget {
  final List<SavingsGoal> goals;
  final VoidCallback? onSeeAll;

  const FinanceGoals({super.key, required this.goals, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      symbol: "₦",
      decimalDigits: 0,
    );

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
            if (onSeeAll != null && goals.isNotEmpty)
              GestureDetector(
                onTap: onSeeAll,
                child: PgTexts.gradientText(
                  context,
                  text: "See All",
                  fontSize: 14,
                  gradient: PgColors.primaryGradient,
                ),
              ),
          ],
        ),
        heightSpacing(8),
        goals.isEmpty
            ? _buildEmptyState(context)
            : SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: goals.map((goal) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: 16,
                        left: goals.first == goal ? 0 : 0,
                      ),
                      child: _buildGoalCard(
                        context,
                        goal: goal,
                        currencyFormatter: currencyFormatter,
                      ),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? PgColors.black1 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: PgColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.chart_2_copy,
              size: 32,
              color: PgColors.primary,
            ),
          ),
          heightSpacing(16),
          PgTexts.text600(
            context,
            text: "No savings goals yet",
            fontSize: 16,
            color: isDark ? Colors.white : PgColors.black,
          ),
          heightSpacing(4),
          PgTexts.text400(
            context,
            text:
                "Create a goal to start saving towards something you want.",
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required SavingsGoal goal,
    required NumberFormat currencyFormatter,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = goal.progress;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? PgColors.black1 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: PgColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PgColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.savings_outlined,
                  size: 32,
                  color: PgColors.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text500(
                    context,
                    text: goal.name,
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  PgTexts.text700(
                    context,
                    text: currencyFormatter.format(goal.currentAmount),
                    fontSize: 18,
                    color: isDark ? Colors.white : PgColors.black,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PgTexts.text400(
                        context,
                        text:
                            "Target: ${currencyFormatter.format(goal.targetAmount)}",
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.grey,
                      ),
                      PgTexts.text600(
                        context,
                        text: "${(percentage * 100).toInt()}%",
                        fontSize: 10,
                        color: isDark ? Colors.white70 : PgColors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : PgColors.black.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white : PgColors.black,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
