import 'package:app/core/services/biometric_service.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_pin_sheet.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_snackbar.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/home/presentation/screens/individual/profile/block_account_screen.dart';
import 'package:app/features/home/presentation/screens/individual/profile/privacy_settings_screen.dart';
import 'package:app/features/home/presentation/screens/individual/profile/report_issue_screen.dart';
import 'package:app/features/home/presentation/screens/individual/profile/trusted_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  final _biometricService = BiometricService();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBiometricState();
    });
  }

  Future<void> _loadBiometricState() async {
    final available = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final hasPin = auth.hasPin;

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
                    icon: Iconsax.shield_tick_copy,
                    title: "Account Security",
                    subtitle: "Passwordless login & security settings",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "You're using passwordless login with OTP and biometrics.",
                          ),
                        ),
                      );
                    },
                  ),
                  _SecurityMenuItem(
                    icon: Iconsax.key_copy,
                    title: hasPin
                        ? "Update Transaction PIN"
                        : "Set Transaction PIN",
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
              if (_biometricAvailable && hasPin) ...[
                const SizedBox(height: 32),
                _buildSection(
                  context,
                  title: "Transaction Security",
                  items: [_buildBiometricToggle(context)],
                ),
              ],
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: "Account Control",
                items: [
                  _SecurityMenuItem(
                    icon: Iconsax.danger_copy,
                    title: "Report an Issue",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportIssueScreen(),
                        ),
                      );
                    },
                  ),
                  _SecurityMenuItem(
                    icon: Iconsax.user_minus_copy,
                    title: "Block Account",
                    isDangerous: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BlockAccountScreen(),
                        ),
                      );
                    },
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrustedDevicesScreen(),
                        ),
                      );
                    },
                  ),
                  _SecurityMenuItem(
                    icon: Iconsax.shield_search_copy,
                    title: "Privacy Settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySettingsScreen(),
                        ),
                      );
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

  _SecurityMenuItem _buildBiometricToggle(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isEnabled = auth.userData?.biometricEnabled ?? false;

    return _SecurityMenuItem(
      icon: Iconsax.finger_scan_copy,
      title: "Use Biometrics for Transactions",
      subtitle: isEnabled ? "Enabled" : "Disabled",
      trailingWidget: Switch(
        value: isEnabled,
        activeThumbColor: PgColors.primary,
        onChanged: (value) async {
          if (value) {
            final authenticated = await _biometricService.authenticateLocally();
            if (!authenticated) return;
            final biometricId = await _biometricService
                .generateAndStoreBiometricId();
            await _biometricService.setBiometricEnabled(true);
            await auth.registerBiometric(biometricId);
            if (mounted) PgSnackBar.showSuccess(context, "Biometrics enabled");
          } else {
            await _biometricService.setBiometricEnabled(false);
            if (mounted) {
              PgSnackBar.showSuccess(context, "Biometrics disabled");
            }
          }
          if (mounted) _loadBiometricState();
        },
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
      onVerify: (pin) async {
        if (pin == firstPin) {
          Navigator.pop(context);
          _showLoadingModal(context, "We're setting your pin...");
          final response = await context.read<AuthProvider>().setPin(
            pin: pin,
            confirmPin: pin,
          );

          if (!context.mounted) return;
          Navigator.pop(context);

          if (response.isSuccess) {
            _showSuccessBottomSheet(context, "PIN set successfully!");
          } else {
            PgSnackBar.showError(
              context,
              response.error ?? "Failed to set PIN",
            );
          }
        } else {
          Navigator.pop(context);
          PgSnackBar.showError(context, "PINs do not match. Try again.");
        }
      },
    );
  }

  void _showUpdatePinFlow(BuildContext context) {
    _showVerifyIdentitySheet(context);
  }

  void _showVerifyIdentitySheet(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.read<AuthProvider>();
    final phone = auth.authResponseData?.phone ?? auth.userData?.phone ?? '';
    final otpControllers = List.generate(5, (_) => TextEditingController());
    final focusNodes = List.generate(5, (_) => FocusNode());
    final formKey = GlobalKey<FormState>();

    if (phone.isEmpty) {
      PgSnackBar.showError(context, "Phone number not found");
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final authProv = sheetContext.read<AuthProvider>();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                PgTexts.text700(
                  sheetContext,
                  text: "Verify Your Identity",
                  fontSize: 22,
                ),
                const SizedBox(height: 8),
                PgTexts.text400(
                  sheetContext,
                  text: "Enter the 5-digit code sent to $phone",
                  fontSize: 14,
                  color: Colors.grey,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Form(
                  key: formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Container(
                        width: 52,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: otpControllers[index],
                          focusNode: focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 22),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (v) {
                            if (v.isNotEmpty && index < 4) {
                              focusNodes[index + 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: PgScaleButton(
                    onTap: authProv.isVerifyingIdentity
                        ? null
                        : () async {
                            final code = otpControllers
                                .map((c) => c.text)
                                .join();
                            if (code.length != 5) {
                              PgSnackBar.showError(
                                sheetContext,
                                "Enter the complete 5-digit code",
                              );
                              return;
                            }
                            final success = await authProv.verifyIdentity(
                              phone: phone,
                              code: code,
                            );
                            if (!sheetContext.mounted) return;
                            if (success) {
                              Navigator.pop(sheetContext);
                              _showCurrentPinForUpdate(context);
                            } else {
                              PgSnackBar.showError(
                                sheetContext,
                                authProv.errorMessage ?? "Verification failed",
                              );
                            }
                          },
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [PgColors.primary, PgColors.secondary],
                        ),
                      ),
                      child: authProv.isVerifyingIdentity
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : PgTexts.text600(
                              sheetContext,
                              text: "Verify",
                              color: Colors.white,
                              fontSize: 16,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final ok = await authProv.requestOtp(
                      phone: phone,
                      forWhat: 'updatePin',
                    );
                    if (sheetContext.mounted) {
                      if (ok) {
                        PgSnackBar.showSuccess(
                          sheetContext,
                          "OTP resent to $phone",
                        );
                      } else {
                        PgSnackBar.showError(
                          sheetContext,
                          authProv.errorMessage ?? "Failed to resend OTP",
                        );
                      }
                    }
                  },
                  child: PgTexts.text500(
                    sheetContext,
                    text: "Resend Code",
                    fontSize: 14,
                    color: PgColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    auth.requestOtp(phone: phone, forWhat: 'updatePin');
  }

  void _showCurrentPinForUpdate(BuildContext context) {
    PgPinSheet.show(
      context,
      title: "Current PIN",
      description: "Enter your current 4-digit PIN.",
      onVerify: (oldPin) {
        Navigator.pop(context);
        _showNewPinFlow(context, oldPin);
      },
    );
  }

  void _showNewPinFlow(BuildContext context, String oldPin) {
    PgPinSheet.show(
      context,
      title: "New PIN",
      description: "Enter your new 4-digit PIN.",
      onVerify: (newPin) {
        Navigator.pop(context);
        _showConfirmUpdatePinFlow(context, oldPin, newPin);
      },
    );
  }

  void _showConfirmUpdatePinFlow(
    BuildContext context,
    String oldPin,
    String newPin,
  ) {
    PgPinSheet.show(
      context,
      title: "Confirm New PIN",
      description: "Please re-enter your new 4-digit PIN to confirm.",
      onVerify: (pin) async {
        if (pin == newPin) {
          Navigator.pop(context);
          _showLoadingModal(context, "We're updating your pin...");
          final response = await context.read<AuthProvider>().updatePin(
            oldPin: oldPin,
            newPin: newPin,
            confirmPin: newPin,
          );

          if (!context.mounted) return;
          Navigator.pop(context);

          if (response.isSuccess) {
            _showSuccessBottomSheet(context, "PIN updated successfully!");
          } else {
            PgSnackBar.showError(
              context,
              response.error ?? "Failed to update PIN",
            );
          }
        } else {
          Navigator.pop(context);
          PgSnackBar.showError(context, "PINs do not match. Try again.");
        }
      },
    );
  }

  void _showLoadingModal(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
              decoration: BoxDecoration(
                color: Theme.of(ctx).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: PgColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PgTexts.text600(ctx, text: message, fontSize: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessBottomSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.tick_circle_copy,
                  size: 40,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 24),
              PgTexts.text700(
                context,
                text: message,
                fontSize: 20,
                color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
              ),
              const SizedBox(height: 8),
              PgTexts.text400(
                context,
                text: "Your transaction PIN has been configured.",
                fontSize: 14,
                color: Colors.grey,
              ),
              const SizedBox(height: 40),
              PgScaleButton(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [PgColors.primary, PgColors.secondary],
                    ),
                  ),
                  child: PgTexts.text600(
                    context,
                    text: "Done",
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
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
                    onTap: item.onTap ?? () {},
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: item.isDangerous
                                ? Colors.red
                                : (theme.textTheme.bodyLarge?.color ??
                                      PgColors.black),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PgTexts.text500(
                                  context,
                                  text: item.title,
                                  fontSize: 16,
                                  color: item.isDangerous
                                      ? Colors.red
                                      : (theme.textTheme.bodyLarge?.color ??
                                            PgColors.black),
                                ),
                                if (item.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  PgTexts.text400(
                                    context,
                                    text: item.subtitle!,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (item.trailingWidget != null)
                            item.trailingWidget!
                          else
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
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDangerous;
  final Widget? trailingWidget;

  _SecurityMenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.subtitle,
    this.isDangerous = false,
    this.trailingWidget,
  });
}
