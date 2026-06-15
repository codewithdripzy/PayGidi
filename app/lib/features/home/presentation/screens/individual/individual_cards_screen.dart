import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class IndividualCardsScreen extends StatelessWidget {
  const IndividualCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Your Cards",
                  fontSize: 28,
                  color: PgColors.black,
                  fontFamily: PgFonts.stackSans,
                ),
                heightSpacing(4),
                PgTexts.text400(
                  context,
                  text: "Manage your virtual and physical cards.",
                  fontSize: 16,
                  color: Colors.black54,
                ),
                heightSpacing(32),
                _buildEmptyState(context),
                const Spacer(),
                PgScaleButton(
                  onTap: () {
                    // Navigate to create card
                  },
                  child: Container(
                    height: objectHeight(size: 60, context: context),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [PgColors.primary, PgColors.secondary],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        PgTexts.text600(
                          context,
                          text: "Create New Card",
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                heightSpacing(30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: PgColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.card_copy,
              size: 40,
              color: PgColors.primary,
            ),
          ),
          heightSpacing(24),
          PgTexts.text600(
            context,
            text: "No active cards",
            fontSize: 18,
            color: PgColors.black,
          ),
          heightSpacing(8),
          PgTexts.text400(
            context,
            text: "You haven't created any virtual cards yet. Get one to start making secure online payments.",
            fontSize: 14,
            color: Colors.black54,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
