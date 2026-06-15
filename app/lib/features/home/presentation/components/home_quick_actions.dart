import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// A horizontal list of quick actions (Pay, Deposit, Statement, Withdraw)
/// for easy access to core financial features.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionBg = theme.brightness == Brightness.dark
        ? const Color(0xFF1A1A1A)
        : Colors.grey.shade200;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAction(
          context,
          "Pay",
          PgAssets.customIcon(iconName: 'pay'),
          PgColors.secondary,
          gradient: const LinearGradient(
            colors: [Color(0xffFE4B1F), Color(0xff9D0063)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _buildAction(
          context,
          "Deposit",
          PgAssets.customIcon(iconName: 'deposit'),
          actionBg,
          onTap: () => context.pushNamed(PgRouteNames.deposit),
        ),
        _buildAction(
          context,
          "Statement",
          PgAssets.customIcon(iconName: 'invoice'),
          actionBg,
          onTap: () => context.pushNamed(PgRouteNames.statementRequest),
        ),
        _buildAction(
          context,
          "Withdraw",
          PgAssets.customIcon(iconName: 'withdraw'),
          actionBg,
          onTap: () => context.pushNamed(PgRouteNames.withdrawal),
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
    VoidCallback? onTap,
  }) {
    final bool isHighlighted = label == "Pay";
    final theme = Theme.of(context);

    return Column(
      children: [
        PgScaleButton(
          onTap: onTap ?? () {},
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              gradient: gradient,
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : Colors.transparent,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  isHighlighted
                      ? Colors.white
                      : (theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
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
          color: theme.textTheme.bodyMedium?.color ?? PgColors.black,
        ),
      ],
    );
  }
}
