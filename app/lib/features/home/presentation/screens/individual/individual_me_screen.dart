import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
// import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/home/presentation/screens/individual/profile/personal_info_screen.dart';
import 'package:app/features/home/presentation/screens/individual/profile/profile_detail_screen.dart';
import 'package:app/features/home/presentation/screens/individual/profile/theme_selection_screen.dart';
import 'package:app/features/home/presentation/screens/individual/profile/transaction_history_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  title: "Account",
                  items: [
                    _ProfileMenuItem(
                      icon: Iconsax.user_edit_copy,
                      title: "Personal Information",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.receipt_2_copy,
                      title: "Transaction History",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionHistoryScreen(),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.status_up_copy,
                      title: "Account Limits",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualProfileDetailScreen(
                            title: "Account Limits",
                            description: "View and upgrade your transaction limits.",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                heightSpacing(24),
                _buildSection(
                  context,
                  title: "Security & Preferences",
                  items: [
                    _ProfileMenuItem(
                      icon: Iconsax.security_safe_copy,
                      title: "Security & PIN",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualProfileDetailScreen(
                            title: "Security & PIN",
                            description: "Manage your login password and transaction PIN.",
                          ),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.finger_scan_copy,
                      title: "Biometrics",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualProfileDetailScreen(
                            title: "Biometrics",
                            description: "Enable fingerprint or face recognition for faster access.",
                          ),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.notification_copy,
                      title: "Notifications",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualProfileDetailScreen(
                            title: "Notifications",
                            description: "Choose what alerts you want to receive.",
                          ),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.brush_2_copy,
                      title: "Appearance",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSelectionScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                heightSpacing(24),
                _buildSection(
                  context,
                  title: "Resources & Social",
                  items: [
                    _ProfileMenuItem(
                      icon: Iconsax.user_add_copy,
                      title: "Invitation",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualProfileDetailScreen(
                            title: "Invitation",
                            description: "Invite your friends and earn rewards.",
                          ),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.shield_tick_copy,
                      title: "Safety Center",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualProfileDetailScreen(
                            title: "Safety Center",
                            description: "Tips and tools to keep your account safe.",
                          ),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.info_circle_copy,
                      title: "Help Center",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualProfileDetailScreen(
                            title: "Help Center",
                            description: "Find answers to common questions.",
                          ),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.message_question_copy,
                      title: "Contact Us",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualProfileDetailScreen(
                            title: "Contact Us",
                            description: "Get in touch with our support team.",
                          ),
                        ),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Iconsax.star_copy,
                      title: "Rate Us",
                      onTap: () async {
                        const String androidPackageName = 'com.squad.paygidi'; // Placeholder
                        const String iosAppId = '6444000000'; // Placeholder
                        
                        final url = Uri.parse(
                          defaultTargetPlatform == TargetPlatform.iOS
                              ? 'https://apps.apple.com/app/id$iosAppId?action=write-review'
                              : 'market://details?id=$androidPackageName',
                        );

                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          final webUrl = Uri.parse(
                            defaultTargetPlatform == TargetPlatform.iOS
                                ? 'https://apps.apple.com/app/id$iosAppId'
                                : 'https://play.google.com/store/apps/details?id=$androidPackageName',
                          );
                          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                        }
                      },
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.grey.shade100,
        ),
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
                  color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                ),
                heightSpacing(2),
                PgTexts.text400(
                  context,
                  text: user?.phone ?? "",
                  fontSize: 14,
                  color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                      .withValues(alpha: 0.7),
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: PgTexts.text500(
            context,
            text: title,
            fontSize: 14,
            color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                .withValues(alpha: 0.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.grey.shade100,
            ),
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
                          Icon(
                            item.icon,
                            size: 22,
                            color: theme.textTheme.bodyLarge?.color ??
                                PgColors.black,
                          ),
                          widthSpacing(16),
                          Expanded(
                            child: PgTexts.text500(
                              context,
                              text: item.title,
                              fontSize: 16,
                              color: theme.textTheme.bodyLarge?.color ??
                                  PgColors.black,
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
                        color: theme.dividerTheme.color,
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
