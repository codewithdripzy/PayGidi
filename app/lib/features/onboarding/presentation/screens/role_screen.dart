import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
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
      color: const Color(0xFFF6F7FB),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFFF6F7FB), Colors.white],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heightSpacing(32),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/logo/app_cowry_icon.svg',
                          width: 40,
                        ),
                        const Spacer(),
                        PgScaleButton(
                          onTap: () =>
                              context.pushNamed(PgRouteNames.individualLogin),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              // horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              // gradient: LinearGradient(
                              //   colors: [
                              //     PgColors.primary.withValues(alpha: 0.10),
                              //     PgColors.secondary.withValues(alpha: 0.10),
                              //   ],
                              // ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: PgTexts.gradientText(
                              context,
                              text: 'I have an Account',
                              fontSize: 14,
                              fontFamily: PgFonts.stackSans,
                              fontWeight: FontWeight.w600,
                              gradient: const LinearGradient(
                                colors: [PgColors.primary, PgColors.secondary],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    heightSpacing(30),
                    PgTexts.text700(
                      context,
                      text: 'Who are you?',
                      fontSize: 36,
                      color: PgColors.black,
                      fontFamily: PgFonts.stackSans,
                    ),
                    heightSpacing(2),
                    PgTexts.text400(
                      context,
                      text:
                          'Select the account type that best matches how you want to use PayGidi.',
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.6,
                      textOverflow: TextOverflow.clip,
                    ),
                    heightSpacing(32),
                    _buildRoleCard(
                      index: 0,
                      icon: Iconsax.user_copy,
                      title: 'Individual',
                      description: 'Pay and receive money securely.',
                      features: const [
                        'Escrow-backed protection',
                        'Fast identity verification',
                        'Dispute support when needed',
                      ],
                    ),
                    heightSpacing(16),
                    _buildRoleCard(
                      index: 1,
                      icon: Iconsax.shop_copy,
                      title: 'Merchant',
                      description: 'Sell products and manage payments.',
                      features: const [
                        'Track customer payments',
                        'Manage orders in one place',
                        'Monitor payouts clearly',
                      ],
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _selectedRole != null ? 1.0 : 0.45,
                      child: PgScaleButton(
                        onTap: () {
                          if (_selectedRole != null) {
                            context.pushNamed(PgRouteNames.countrySelection);
                          }
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PgTexts.text600(
                                context,
                                text: 'Continue',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // heightSpacing(16),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     PgTexts.text400(
                    //       context,
                    //       text: 'Already have an account? ',
                    //       fontSize: 16,
                    //       color: Colors.black54,
                    //     ),
                    //     GestureDetector(
                    //       onTap: () =>
                    //           context.pushNamed(PgRouteNames.individualLogin),
                    //       child: PgTexts.text600(
                    //         context,
                    //         text: 'Login',
                    //         fontSize: 16,
                    //         color: PgColors.primary,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    heightSpacing(24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
  }) {
    final isSelected = _selectedRole == index;

    return PgScaleButton(
      onTap: () => setState(() => _selectedRole = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(1),
        constraints: BoxConstraints(minHeight: isSelected ? 188 : 102),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [PgColors.primary, PgColors.secondary],
                )
              : null,
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE3E7EE), width: 0.5),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [PgColors.primary, PgColors.secondary],
                            )
                          : null,
                      color: isSelected ? null : const Color(0xFFF1F4F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : PgColors.black,
                      size: 26,
                    ),
                  ),
                  widthSpacing(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PgTexts.text600(
                          context,
                          text: title,
                          fontSize: 17,
                          color: PgColors.black,
                        ),
                        heightSpacing(2),
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
                      color: PgColors.secondary,
                      size: 22,
                    ),
                ],
              ),
              if (isSelected) ...[
                heightSpacing(20),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: PgColors.primary,
                        ),
                        widthSpacing(8),
                        Expanded(
                          child: PgTexts.text400(
                            context,
                            text: feature,
                            fontSize: 14,
                            color: Colors.black87,
                            textOverflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
