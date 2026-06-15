import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class IndividualMeScreen extends StatelessWidget {
  const IndividualMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Account",
                  fontSize: 28,
                  color: PgColors.black,
                  fontFamily: PgFonts.stackSans,
                ),
                heightSpacing(24),
                _buildProfileCard(context),
                heightSpacing(32),
                _buildSection(
                  context,
                  title: "Settings",
                  items: [
                    _ProfileMenuItem(
                      icon: Iconsax.user_edit_copy,
                      title: "Personal Information",
                      onTap: () {},
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.security_safe_copy,
                      title: "Security & PIN",
                      onTap: () {},
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.notification_copy,
                      title: "Notifications",
                      onTap: () {},
                    ),
                  ],
                ),
                heightSpacing(24),
                _buildSection(
                  context,
                  title: "Support",
                  items: [
                    _ProfileMenuItem(
                      icon: Iconsax.info_circle_copy,
                      title: "Help Center",
                      onTap: () {},
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.message_question_copy,
                      title: "Contact Us",
                      onTap: () {},
                    ),
                  ],
                ),
                heightSpacing(32),
                PgScaleButton(
                  onTap: () => context.read<AuthProvider>().logout(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                    ),
                    child: PgTexts.text600(
                      context,
                      text: "Logout",
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
                heightSpacing(40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PgColors.primary, PgColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: PgTexts.text700(
                context,
                text: (user?.firstName?.isNotEmpty ?? false) 
                    ? user!.firstName![0].toUpperCase() 
                    : "U",
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          widthSpacing(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text600(
                  context,
                  text: "${user?.firstName ?? 'User'} ${user?.lastName ?? ''}",
                  fontSize: 18,
                  color: PgColors.black,
                ),
                heightSpacing(2),
                PgTexts.text400(
                  context,
                  text: user?.phone ?? "",
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3_copy, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_ProfileMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: PgTexts.text500(
            context,
            text: title,
            fontSize: 14,
            color: Colors.black38,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  PgScaleButton(
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 22, color: PgColors.black),
                          widthSpacing(16),
                          Expanded(
                            child: PgTexts.text500(
                              context,
                              text: item.title,
                              fontSize: 16,
                              color: PgColors.black,
                            ),
                          ),
                          const Icon(
                            Iconsax.arrow_right_3_copy,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        height: 1,
                        color: Colors.grey.shade100,
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
