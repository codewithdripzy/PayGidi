import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// A card component that displays the user's total balance.
/// It includes a toggle to show or hide the balance amount for privacy.
class HomeBalanceCard extends StatefulWidget {
  const HomeBalanceCard({super.key});

  @override
  State<HomeBalanceCard> createState() => _HomeBalanceCardState();
}

/// State class for [HomeBalanceCard] to manage balance visibility.
class _HomeBalanceCardState extends State<HomeBalanceCard> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PgColors.black1,
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
          PgTexts.text700(
            context,
            text: _showBalance ? "₦450,000.00" : "₦ **********",
            fontSize: 36,
            color: Colors.white,
            fontFamily: PgFonts.googleSans,
          ),
        ],
      ),
    );
  }
}
