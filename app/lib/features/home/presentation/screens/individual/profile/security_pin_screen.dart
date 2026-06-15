import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_pin_sheet.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class SecurityPinScreen extends StatelessWidget {
  const SecurityPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final hasPin = auth.userData?.hasPin ?? false;

    return buildPGAnnotatedRegion(
      brightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
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
            text: "Security & PIN",
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
                title: "Authentication",
                items: [
                  _SecurityMenuItem(
                    icon: Iconsax.lock_copy,
                    title: "Change Password",
                    onTap: () {
                      // Implement change password
                    },
                  ),
                  _SecurityMenuItem(
                    icon: Iconsax.key_copy,
                    title: hasPin ? "Update Transaction PIN" : "Set Transaction PIN",
                    onTap: () {
                      if (!hasPin) {
                        _showSetPinFlow(context);
                      } else {
                        _showUpdatePinFlow(context);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: "Account Control",
                items: [
                  _SecurityMenuItem(
                    icon: Iconsax.danger_copy,
                    title: "Report an Issue",
                    onTap: () {
                      // Implement report
                    },
                  ),
                  _SecurityMenuItem(
                    icon: Iconsax.user_minus_copy,
                    title: "Block Account",
                    onTap: () {
                      _showBlockAccountDialog(context);
                    },
                    isDangerous: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: "Other Options",
                items: [
                  _SecurityMenuItem(
                    icon: Iconsax.device_message_copy,
                    title: "Trusted Devices",
                    onTap: () {
                      // Implement trusted devices
                    },
                  ),
                  _SecurityMenuItem(
                    icon: Iconsax.shield_search_copy,
                    title: "Privacy Settings",
                    onTap: () {
                      // Implement privacy settings
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetPinFlow(BuildContext context) {
    PgPinSheet.show(
      context,
      title: "Set Your PIN",
      description: "Create a 4-digit PIN for your transactions.",
      onVerify: (pin) {
        Navigator.pop(context);
        _showConfirmPinFlow(context, pin);
      },
    );
  }

  void _showConfirmPinFlow(BuildContext context, String firstPin) {
    PgPinSheet.show(
      context,
      title: "Confirm Your PIN",
      description: "Please re-enter your 4-digit PIN to confirm.",
      onVerify: (pin) {
        if (pin == firstPin) {
          // Success
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PIN set successfully!")),
          );
          // In a real app, call backend here
        } else {
          // Error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PINs do not match. Try again.")),
          );
        }
      },
    );
  }

  void _showUpdatePinFlow(BuildContext context) {
    PgPinSheet.show(
      context,
      title: "Current PIN",
      description: "Enter your current 4-digit PIN.",
      onVerify: (pin) {
        Navigator.pop(context);
        _showSetPinFlow(context);
      },
    );
  }

  void _showBlockAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Block Account?"),
        content: const Text(
          "This will temporarily disable all transactions on your account. You will need to contact support to unblock it.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Implement block logic
              Navigator.pop(context);
            },
            child: const Text("Block", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_SecurityMenuItem> items,
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
                            color: item.isDangerous
                                ? Colors.red
                                : (theme.textTheme.bodyLarge?.color ?? PgColors.black),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PgTexts.text500(
                              context,
                              text: item.title,
                              fontSize: 16,
                              color: item.isDangerous
                                  ? Colors.red
                                  : (theme.textTheme.bodyLarge?.color ?? PgColors.black),
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

class _SecurityMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDangerous;

  _SecurityMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDangerous = false,
  });
}
