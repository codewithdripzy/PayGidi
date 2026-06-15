import 'dart:math' as math;
import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A list of the user's most recent transactions.
/// Displays transaction title, date, and amount with credit/debit indicators.
class HomeRecentTransactions extends StatelessWidget {
  const HomeRecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = [
      _buildTransaction(
        context,
        title: "Payment - Arike Pre-Order",
        date: "May 14th, 2026 • 10:30 PM",
        amount: "-₦50,000",
        isCredit: false,
      ),
      _buildTransaction(
        context,
        title: "Deposit - Opay",
        date: "May 14th, 2026 • 10:30 PM",
        amount: "+₦200,000",
        isCredit: true,
      ),
      _buildTransaction(
        context,
        title: "Deposit - Opay",
        date: "May 14th, 2026 • 10:30 PM",
        amount: "+₦200,000",
        isCredit: true,
      ),
    ];

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
              onTap: () {},
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
          ),
          itemBuilder: (context, index) => transactions[index],
        ),
      ],
    );
  }

  Widget _buildTransaction(
    BuildContext context, {
    required String title,
    required String date,
    required String amount,
    required bool isCredit,
  }) {
    final theme = Theme.of(context);
    final statusColor = isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Padding(
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
              angle: isCredit ? 0 : math.pi / 2,
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
                  text: title,
                  fontSize: 15,
                  color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                  fontFamily: PgFonts.googleSans,
                ),
                const SizedBox(height: 4),
                PgTexts.text400(
                  context,
                  text: date,
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: PgFonts.googleSans,
                ),
              ],
            ),
          ),
          PgTexts.text500(
            context,
            text: amount,
            fontSize: 16,
            color: statusColor,
            fontFamily: PgFonts.googleSans,
          ),
        ],
      ),
    );
  }
}

