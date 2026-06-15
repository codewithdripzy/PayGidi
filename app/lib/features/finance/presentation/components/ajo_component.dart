import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AjoComponent extends StatelessWidget {
  const AjoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PgColors.primary.withValues(alpha: 0.9),
            PgColors.secondary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PgColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.refresh_copy, color: Colors.white, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PgTexts.text600(
                  context,
                  text: "Active",
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PgTexts.text700(
            context,
            text: "Ajo Contribution",
            fontSize: 22,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          PgTexts.text400(
            context,
            text: "Rotating savings with your trusted circle.",
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfo(context, "Next Payout", "June 25"),
              _buildInfo(context, "Contribution", "₦50,000/mo"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PgTexts.text400(
          context,
          text: label,
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 4),
        PgTexts.text600(
          context,
          text: value,
          fontSize: 16,
          color: Colors.white,
        ),
      ],
    );
  }
}
