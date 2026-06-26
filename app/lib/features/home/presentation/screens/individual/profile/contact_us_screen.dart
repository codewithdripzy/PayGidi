import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
            text: "Contact Us",
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black,
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PgColors.secondary.withValues(alpha: 0.1),
                    PgColors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: PgColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.message_question_copy,
                      color: PgColors.secondary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PgTexts.text600(
                    context,
                    text: "We're here to help",
                    fontSize: 18,
                    color:
                        theme.textTheme.bodyLarge?.color ?? PgColors.black,
                  ),
                  const SizedBox(height: 8),
                  PgTexts.text400(
                    context,
                    text:
                        "Reach out to us through any of the channels below. "
                        "Our support team is available 24/7.",
                    fontSize: 14,
                    color: Colors.grey,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildContactOption(
              context,
              icon: Iconsax.message_2_copy,
              title: "Email Us",
              subtitle: "support@paygidi.com",
              onTap: () => _launchEmail(context),
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Iconsax.call_copy,
              title: "Call Us",
              subtitle: "+234 800 PAYGIDI",
              onTap: () => _launchPhone(context),
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Iconsax.message_edit_copy,
              title: "Report an Issue",
              subtitle: "Submit a detailed report",
              onTap: () {
                Navigator.pushNamed(context, '/report-issue');
              },
            ),
            const SizedBox(height: 32),
            PgTexts.text500(
              context,
              text: "Office Address",
              fontSize: 14,
              color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey.shade100,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PgColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.location_copy,
                      size: 22,
                      color: PgColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PgTexts.text400(
                      context,
                      text:
                          "123, PayGidi House, Victoria Island, Lagos, Nigeria.",
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PgTexts.text500(
              context,
              text: "Working Hours",
              fontSize: 14,
              color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey.shade100,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PgColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.clock_copy,
                      size: 22,
                      color: PgColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PgTexts.text400(
                          context,
                          text: "Monday - Friday: 8:00 AM - 6:00 PM",
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        PgTexts.text400(
                          context,
                          text: "Saturday: 9:00 AM - 4:00 PM",
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        PgTexts.text400(
                          context,
                          text: "Sunday: Closed",
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ],
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

  Widget _buildContactOption(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.grey.shade100,
          ),
        ),
        child: Row(
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
                    color:
                        theme.textTheme.bodyLarge?.color ?? PgColors.black,
                  ),
                  const SizedBox(height: 2),
                  PgTexts.text400(
                    context,
                    text: subtitle,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@paygidi.com',
      queryParameters: {
        'subject': 'PayGidi Support Request',
      },
    );
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    try {
      await launchUrl(Uri.parse('tel:+2348007294434'));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    }
  }
}
