import 'dart:math' as math;
import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/wallet/data/models/transaction_model.dart';
import 'package:app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// A list of the user's most recent transactions.
/// Displays transaction title, date, and amount with credit/debit indicators.
class HomeRecentTransactions extends StatefulWidget {
  const HomeRecentTransactions({super.key});

  @override
  State<HomeRecentTransactions> createState() => _HomeRecentTransactionsState();
}

class _HomeRecentTransactionsState extends State<HomeRecentTransactions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletProvider = context.watch<WalletProvider>();
    final transactions = walletProvider.transactions;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PgTexts.text600(
              context,
              text: "Recent Transactions",
              fontSize: 18,
              color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
            ),
            GestureDetector(
              onTap: () => context.pushNamed(PgRouteNames.statementRequest),
              child: Row(
                children: [
                  PgTexts.text600(
                    context,
                    text: "See All",
                    fontSize: 14,
                    color: PgColors.secondary,
                    fontFamily: PgFonts.googleSans,
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    PgAssets.customIcon(iconName: "arrow_right"),
                    colorFilter: const ColorFilter.mode(PgColors.secondary, BlendMode.srcIn),
                    width: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (walletProvider.isLoadingTransactions)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: PgTexts.text400(context, text: "No transactions yet", color: Colors.grey),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 5 ? 5 : transactions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
            ),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransaction(
                context,
                transaction: tx,
              );
            },
          ),
      ],
    );
  }

  Widget _buildTransaction(
    BuildContext context, {
    required Transaction transaction,
  }) {
    final theme = Theme.of(context);
    final statusColor = transaction.isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return InkWell(
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
                    textOverflow: TextOverflow.ellipsis,
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
              text: "${transaction.isCredit ? '+' : '-'}₦${transaction.amount}",
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


