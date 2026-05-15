import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A horizontal list of quick actions (Pay, Deposit, Statement, Withdraw)
/// for easy access to core financial features.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAction(
          context,
          "Pay",
          PgAssets.customIcon(iconName: 'pay'),
          PgColors.secondary,
          gradient: LinearGradient(
            colors: [Color(0xffFE4B1F), Color(0xff9D0063)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _buildAction(
          context,
          "Deposit",
          PgAssets.customIcon(iconName: 'deposit'),
          Colors.grey.shade200,
        ),
        _buildAction(
          context,
          "Statement",
          PgAssets.customIcon(iconName: 'invoice'),
          Colors.grey.shade200,
        ),
        _buildAction(
          context,
          "Withdraw",
          PgAssets.customIcon(iconName: 'withdraw'),
          Colors.grey.shade200,
        ),
      ],
    );
  }

  /// Builds a single action item with an icon and label.
  Widget _buildAction(
    BuildContext context,
    String label,
    String iconPath,
    Color bgColor, {
    Gradient? gradient,
  }) {
    final bool isHighlighted = label == "Pay";

    return Column(
      children: [
        PgScaleButton(
          onTap: () {},
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              gradient: gradient,
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  isHighlighted ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
                width: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PgTexts.text500(
          context,
          text: label,
          fontSize: 12,
          color: PgColors.black,
        ),
      ],
    );
  }
}
