import 'package:app/core/theme/pg_colors.dart';
// import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    PgScaleButton(
                      onTap: () =>
                          context.pushNamed(PgRouteNames.statementRequest),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: PgColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: PgTexts.text600(
                          context,
                          text: "Request",
                          fontSize: 12,
                          color: PgColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Transaction History",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                heightSpacing(32),
                Expanded(
                  child: _buildTransactionList(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder for actual transaction data
    final List<dynamic> transactions = [];

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PgColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.receipt_copy,
                size: 48,
                color: PgColors.primary,
              ),
            ),
            heightSpacing(24),
            PgTexts.text600(
              context,
              text: "No transactions yet",
              fontSize: 18,
              color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
            ),
            heightSpacing(8),
            PgTexts.text400(
              context,
              text: "Your recent activities will show up here.",
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                  Colors.black54,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (context, index) => heightSpacing(12),
      itemBuilder: (context, index) {
        return const SizedBox(); // Actual transaction item would go here
      },
    );
  }
}
