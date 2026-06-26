import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _showBalanceOnHome = true;
  bool _showTransactionDetails = true;
  bool _profileVisible = true;
  bool _dataCollection = false;

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
            text: "Privacy Settings",
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                title: "Visibility",
                children: [
                  _buildToggleItem(
                    context,
                    icon: Iconsax.eye_copy,
                    title: "Show Balance on Home",
                    subtitle: "Display your account balance on the home screen",
                    value: _showBalanceOnHome,
                    onChanged: (v) =>
                        setState(() => _showBalanceOnHome = v),
                  ),
                  _buildDivider(context),
                  _buildToggleItem(
                    context,
                    icon: Iconsax.receipt_copy,
                    title: "Show Transaction Details",
                    subtitle: "Display transaction amounts in transaction list",
                    value: _showTransactionDetails,
                    onChanged: (v) =>
                        setState(() => _showTransactionDetails = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: "Profile",
                children: [
                  _buildToggleItem(
                    context,
                    icon: Iconsax.user_copy,
                    title: "Public Profile",
                    subtitle: "Make your profile visible to other users",
                    value: _profileVisible,
                    onChanged: (v) => setState(() => _profileVisible = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: "Data & Analytics",
                children: [
                  _buildToggleItem(
                    context,
                    icon: Iconsax.chart_2_copy,
                    title: "Usage Data Collection",
                    subtitle:
                        "Help us improve by sharing anonymous usage data",
                    value: _dataCollection,
                    onChanged: (v) => setState(() => _dataCollection = v),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: PgColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: PgColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.shield_search_copy,
                        color: PgColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PgTexts.text500(
                            context,
                            text: "Your data is safe with us",
                            fontSize: 14,
                            color: theme.textTheme.bodyLarge?.color ??
                                PgColors.black,
                          ),
                          const SizedBox(height: 4),
                          PgTexts.text400(
                            context,
                            text:
                                "We use industry-standard encryption to protect your information.",
                            fontSize: 12,
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
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: theme.dividerTheme.color,
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text500(
                  context,
                  text: title,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                ),
                const SizedBox(height: 2),
                PgTexts.text400(
                  context,
                  text: subtitle,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: PgColors.primary,
          ),
        ],
      ),
    );
  }
}
