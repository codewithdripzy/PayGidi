import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  int? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heightSpacing(40),
              // Logo
              SvgPicture.asset(
                "assets/logo/app cowry icon.svg",
                width: 50,
              ),
              heightSpacing(32),
              // Title
              PgTexts.text700(
                context,
                text: "Tell us who you are",
                fontSize: 32,
                color: PgColors.black,
              ),
              heightSpacing(48),

              // Role Options
              _buildRoleCard(
                index: 0,
                icon: Iconsax.user_copy,
                title: "Individual",
                description: "I want to pay and receive money securely.",
              ),
              heightSpacing(20),
              _buildRoleCard(
                index: 1,
                icon: Iconsax.shop_copy,
                title: "Merchant",
                description: "I want to sell products and manage payments.",
              ),

              const Spacer(),
              // Action Button (visible when a role is selected)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _selectedRole != null ? 1.0 : 0.0,
                child: PgScaleButton(
                  onTap: () {
                    if (_selectedRole != null) {
                      // Navigate to respective signup flow
                    }
                  },
                  child: Container(
                    height: objectHeight(size: 56, context: context),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [PgColors.primary, PgColors.secondary],
                      ),
                    ),
                    child: PgTexts.text600(
                      context,
                      text: "Continue",
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              heightSpacing(40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedRole == index;

    return PgScaleButton(
      onTap: () => setState(() => _selectedRole = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? PgColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? PgColors.primary.withValues(alpha: 0.1) 
                    : PgColors.scaffoldBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? PgColors.primary : PgColors.black,
                size: 28,
              ),
            ),
            widthSpacing(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text600(
                    context,
                    text: title,
                    fontSize: 18,
                    color: PgColors.black,
                  ),
                  heightSpacing(4),
                  PgTexts.text400(
                    context,
                    text: description,
                    fontSize: 14,
                    color: Colors.black54,
                    textOverflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: PgColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
