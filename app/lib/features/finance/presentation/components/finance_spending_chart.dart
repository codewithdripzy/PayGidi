import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';

class FinanceSpendingChart extends StatelessWidget {
  const FinanceSpendingChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        boxShadow: theme.brightness == Brightness.dark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text400(
                    context,
                    text: "Total Spending",
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  PgTexts.text700(
                    context,
                    text: "₦458,000.00",
                    fontSize: 24,
                    color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PgColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PgTexts.text600(
                  context,
                  text: "-12.5%",
                  fontSize: 12,
                  color: PgColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Placeholder for Chart
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(context, 0.4, "Mon"),
                _buildBar(context, 0.7, "Tue"),
                _buildBar(context, 0.5, "Wed"),
                _buildBar(context, 0.9, "Thu", isPrimary: true),
                _buildBar(context, 0.6, "Fri"),
                _buildBar(context, 0.3, "Sat"),
                _buildBar(context, 0.4, "Sun"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, double heightFactor, String label, {bool isPrimary = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: isPrimary ? PgColors.primary : PgColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        PgTexts.text400(
          context,
          text: label,
          fontSize: 12,
          color: Colors.grey,
        ),
      ],
    );
  }
}
