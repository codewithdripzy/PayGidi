import 'dart:math' as math;
import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/wallet/data/models/transaction_model.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
                      onTap: () => context.pop(),
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
    final transactions = Transaction.dummyTransactions;

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
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: theme.brightness == Brightness.dark
            ? Colors.white10
            : Colors.grey.shade100,
      ),
      itemBuilder: (context, index) =>
          _buildTransactionItem(context, transactions[index]),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final theme = Theme.of(context);
    final statusColor =
        transaction.isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return PgScaleButton(
      onTap: () => context.pushNamed(
        PgRouteNames.transactionDetails,
        extra: transaction,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: transaction.isCredit ? 0 : math.pi / 2,
                child: SvgPicture.asset(
                  PgAssets.customIcon(iconName: 'arrow_trend'),
                  colorFilter: ColorFilter.mode(
                    statusColor,
                    BlendMode.srcIn,
                  ),
                  width: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text500(
                    context,
                    text: transaction.title,
                    fontSize: 15,
                    color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                    fontFamily: PgFonts.googleSans,
                  ),
                  const SizedBox(height: 4),
                  PgTexts.text400(
                    context,
                    text: transaction.date,
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: PgFonts.googleSans,
                  ),
                ],
              ),
            ),
            PgTexts.text500(
              context,
              text: transaction.amount,
              fontSize: 16,
              color: statusColor,
              fontFamily: PgFonts.googleSans,
            ),
          ],
        ),
      ),
    );
  }
}
