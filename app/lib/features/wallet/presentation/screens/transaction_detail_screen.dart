import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/wallet/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : PgColors.homeBackground;

    return buildPGAnnotatedRegion(
      brightness: isDark ? Brightness.light : Brightness.dark,
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildReceiptCard(context),
                const SizedBox(height: 32),
                _buildActions(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
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
        PgTexts.text700(
          context,
          text: "Transaction Receipt",
          fontSize: 18,
        ),
        const SizedBox(width: 40), // Spacing to balance the back button
      ],
    );
  }

  Widget _buildReceiptCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = transaction.isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isCredit ? Iconsax.arrow_down_copy : Iconsax.arrow_up_3_copy,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          PgTexts.text700(
            context,
            text: transaction.amount,
            fontSize: 28,
            color: statusColor,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: PgTexts.text600(
              context,
              text: transaction.status,
              fontSize: 12,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1),
          ),
          const SizedBox(height: 24),
          _buildDetailRow(context, "Transaction Type", transaction.type),
          _buildDetailRow(context, transaction.isCredit ? "Sender" : "Recipient", transaction.recipientOrSender),
          _buildDetailRow(context, "Date & Time", transaction.date),
          _buildDetailRow(context, "Reference", transaction.reference),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PgTexts.text400(
            context,
            text: label,
            fontSize: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PgTexts.text600(
              context,
              text: value,
              fontSize: 14,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PgScaleButton(
            onTap: () {},
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: PgColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.document_download_copy, color: PgColors.primary, size: 20),
                  const SizedBox(width: 8),
                  PgTexts.text600(
                    context,
                    text: "Download",
                    fontSize: 14,
                    color: PgColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PgScaleButton(
            onTap: () {},
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: PgColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.share_copy, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  PgTexts.text600(
                    context,
                    text: "Share",
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
