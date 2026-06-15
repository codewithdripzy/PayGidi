import 'package:app/core/theme/assets.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/home/presentation/screens/individual/individual_main_screen.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// A horizontal list of quick actions (Pay, Deposit, Statement, Withdraw)
/// for easy access to core financial features.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  void _showPaymentSelection(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardTheme.color,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text700(
                  context,
                  text: "Select Payment Type",
                  fontSize: 20,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                heightSpacing(24),
                _buildPaymentOption(
                  context,
                  icon: Iconsax.send_1_copy,
                  title: "Instant Payment",
                  subtitle: "Send money instantly to anyone",
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(PgRouteNames.instantPayment);
                  },
                ),
                heightSpacing(16),
                _buildPaymentOption(
                  context,
                  icon: Iconsax.link_1_copy,
                  title: "Payment Link",
                  subtitle: "Create link to make payments to merchants",
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(PgRouteNames.paymentLink);
                  },
                ),
                heightSpacing(16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return PgScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PgColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: PgColors.primary, size: 24),
            ),
            widthSpacing(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text600(
                    context,
                    text: title,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                  ),
                  PgTexts.text400(
                    context,
                    text: subtitle,
                    fontSize: 14,
                    color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                        .withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionBg = theme.cardTheme.color;

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
          onTap: () {
            // Trigger the payment selection from any context
            final state = context.findAncestorStateOfType<State<IndividualMainScreen>>();
            if (state != null) {
              // This is a hacky way if we don't have a global state, 
              // but since it's on the main screen it might work.
              // Better approach is to use a static method or a provider.
            }
            // For now, let's just use the logic from the main screen if possible 
            // or use a generic modal.
            _showPaymentSelection(context);
          },
        ),
        _buildAction(
          context,
          "Deposit",
          PgAssets.customIcon(iconName: 'deposit'),
          actionBg ?? Colors.grey.shade200,
          onTap: () => context.pushNamed(PgRouteNames.deposit),
        ),
        _buildAction(
          context,
          "Statement",
          PgAssets.customIcon(iconName: 'invoice'),
          actionBg ?? Colors.grey.shade200,
          onTap: () => context.pushNamed(PgRouteNames.statementRequest),
        ),
        _buildAction(
          context,
          "Withdraw",
          PgAssets.customIcon(iconName: 'withdraw'),
          actionBg ?? Colors.grey.shade200,
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
