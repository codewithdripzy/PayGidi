import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class FinanceCategories extends StatelessWidget {
  const FinanceCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PgTexts.text700(
          context,
          text: "Top Categories",
          fontSize: 18,
          color: theme.textTheme.titleLarge?.color ?? PgColors.black,
        ),
        const SizedBox(height: 16),
        _buildCategoryItem(
          context,
          icon: Iconsax.grammerly_copy,
          title: "Food & Drinks",
          amount: "₦120,000",
          percentage: 0.45,
          color: PgColors.black,
        ),
        const SizedBox(height: 16),
        _buildCategoryItem(
          context,
          icon: Iconsax.truck_copy,
          title: "Transport",
          amount: "₦45,000",
          percentage: 0.25,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildCategoryItem(
          context,
          icon: Iconsax.shop_copy,
          title: "Shopping",
          amount: "₦85,000",
          percentage: 0.35,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String amount,
    required double percentage,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.cardTheme.color ??
            (theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white10
              : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PgTexts.text600(
                      context,
                      text: title,
                      fontSize: 16,
                      color:
                          theme.textTheme.titleMedium?.color ?? PgColors.black,
                    ),
                    PgTexts.text400(
                      context,
                      text: "12 Transactions",
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              PgTexts.gradientText(
                context,
                text: amount,
                fontSize: 16,
                gradient: PgColors.primaryGradient,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
