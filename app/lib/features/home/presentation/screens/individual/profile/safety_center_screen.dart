import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return buildPGAnnotatedRegion(
      brightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Iconsax.arrow_left_copy,
              color: theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: PgTexts.text600(
            context,
            text: "Safety Center",
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black,
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PgColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.shield_tick_copy,
                      color: PgColors.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PgTexts.text600(
                          context,
                          text: "Your safety matters",
                          fontSize: 16,
                          color:
                              theme.textTheme.bodyLarge?.color ??
                              PgColors.black,
                        ),
                        PgTexts.text400(
                          context,
                          text:
                              "Tips and best practices to keep your account secure.",
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              spacing: 5.0,
              children: [
                _buildTip(
                  context,
                  icon: Iconsax.password_check_copy,
                  title: "Strong Password",
                  description:
                      "Use a combination of letters, numbers, and special characters. Never share your password with anyone.",
                ),
                _buildTip(
                  context,
                  icon: Iconsax.shield_tick_copy,
                  title: "Enable Biometrics",
                  description:
                      "Add fingerprint or face ID for faster and more secure login. This adds an extra layer of protection.",
                ),
                _buildTip(
                  context,
                  icon: Iconsax.shield_cross_copy,
                  title: "Beware of Phishing",
                  description:
                      "PayGidi will never ask for your PIN, password, or OTP via call, SMS, or email. Stay vigilant.",
                ),
                _buildTip(
                  context,
                  icon: Iconsax.lock_1_copy,
                  title: "Secure Your Device",
                  description:
                      "Keep your phone locked with a PIN or pattern. Enable remote wipe in case of loss or theft.",
                ),
                _buildTip(
                  context,
                  icon: Iconsax.notification_bing_copy,
                  title: "Monitor Notifications",
                  description:
                      "Keep transaction notifications enabled to spot unauthorized activity immediately.",
                ),
                _buildTip(
                  context,
                  icon: Iconsax.hierarchy_copy,
                  title: "Regular Account Review",
                  description:
                      "Check your transaction history regularly and report any suspicious activity right away.",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.warning_2_copy,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PgTexts.text400(
                      context,
                      text:
                          "If you suspect unauthorized access, block your account immediately from Security & PIN settings.",
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PgColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: PgColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text500(
                  context,
                  text: title,
                  fontSize: 15,
                  color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                ),
                const SizedBox(height: 4),
                PgTexts.text400(
                  context,
                  text: description,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
