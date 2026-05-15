import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeRecentTransactions extends StatelessWidget {
  const HomeRecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PgTexts.text600(
              context,
              text: "Recent Transactions",
              fontSize: 18,
              color: PgColors.black,
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
                  SvgPicture.asset(
                    PgAssets.customIcon(iconName: "arrow_right"),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
        _buildTransaction(
          context,
          title: "Deposit - Opay",
          date: "May 14th, 2026 • 10:30 PM",
          amount: "+₦200,000",
          isCredit: true,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              PgAssets.customIcon(iconName: 'arrow_trend'),
              colorFilter: ColorFilter.mode(
                isCredit ? Colors.green : Colors.red,
                BlendMode.srcIn,
              ),
              width: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text600(
                  context,
                  text: title,
                  fontSize: 14,
                  color: PgColors.black,
                  fontFamily: PgFonts.googleSans,
                ),
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
          PgTexts.text700(
            context,
            text: amount,
            fontSize: 14,
            color: isCredit ? Colors.green : Colors.red,
            fontFamily: PgFonts.googleSans,
          ),
        ],
      ),
    );
  }
}
