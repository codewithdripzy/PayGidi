import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';

class HomeBalanceCard extends StatefulWidget {
  final double? balance;
  final bool isLoading;

  const HomeBalanceCard({super.key, this.balance, this.isLoading = false});

  @override
  State<HomeBalanceCard> createState() => _HomeBalanceCardState();
}

class _HomeBalanceCardState extends State<HomeBalanceCard> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? null : PgColors.black1,
        gradient: isDark
            ? const LinearGradient(
                colors: [PgColors.primary, PgColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  PgTexts.text500(
                    context,
                    text: "Total balance",
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _showBalance = !_showBalance),
                    child: Icon(
                      _showBalance ? Iconsax.eye_copy : Iconsax.eye_slash_copy,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ],
              ),
              SvgPicture.asset(
                "assets/logo/app_cowry_white.svg",
                width: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          widget.isLoading
              ? _buildShimmer(isDark)
              : PgTexts.text700(
                  context,
                  text: _showBalance
                      ? "₦${_formatBalance(widget.balance)}"
                      : "₦ **********",
                  fontSize: 36,
                  color: Colors.white,
                  fontFamily: PgFonts.googleSans,
                ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    final baseColor = isDark ? Colors.white24 : Colors.white30;
    final highlightColor = isDark ? Colors.white38 : Colors.white60;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 36,
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatBalance(double? balance) {
    if (balance == null) return "0.00";
    return balance.toStringAsFixed(2);
  }
}
