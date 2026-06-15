import 'package:app/core/services/biometric_service.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  bool _isBiometricEnabled = false;
  bool _isAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final biometricService = context.read<BiometricService>();
    final isAvailable = await biometricService.isBiometricAvailable();
    final isEnabled = await biometricService.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _isAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final biometricService = context.read<BiometricService>();

    if (value) {
      final authenticated = await biometricService.authenticateLocally();

      if (authenticated) {
        setState(() => _isLoading = true);
        final biometricId =
            await biometricService.generateAndStoreBiometricId();
        final authRepo = context.read<AuthRepository>();

        final response = await authRepo.registerBiometric(
          BiometricRegisterRequest(biometricID: biometricId),
        );

        if (response.error == null) {
          await biometricService.setBiometricEnabled(true);
          if (mounted) {
            setState(() {
              _isBiometricEnabled = true;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      response.error ?? "Failed to register biometric")),
            );
          }
        }
      }
    } else {
      await biometricService.setBiometricEnabled(false);
      if (mounted) {
        setState(() {
          _isBiometricEnabled = false;
        });
      }
    }
  }

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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacing(24),
                PgScaleButton(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_outlined,
                      size: 20,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Biometrics",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                heightSpacing(4),
                PgTexts.text400(
                  context,
                  text:
                      "Use biometrics for faster and secure access to your account.",
                  fontSize: 16,
                  color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                      .withValues(alpha: 0.7),
                ),
                heightSpacing(32),
                if (_isLoading)
                  const Center(
                      child: CircularProgressIndicator(color: PgColors.primary))
                else if (!_isAvailable)
                  _buildNotAvailable(context)
                else
                  _buildToggle(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotAvailable(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Iconsax.info_circle_copy,
              size: 48, color: Colors.grey.withValues(alpha: 0.5)),
          heightSpacing(16),
          PgTexts.text400(
            context,
            text: "Biometric authentication is not available on this device.",
            textAlign: TextAlign.center,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
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
          const Icon(Iconsax.finger_scan_copy,
              color: PgColors.primary, size: 24),
          widthSpacing(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text600(
                  context,
                  text: "Touch ID / Face ID",
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                ),
                PgTexts.text400(
                  context,
                  text: "Enable biometric login",
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isBiometricEnabled,
            onChanged: _toggleBiometric,
            activeColor: PgColors.primary,
          ),
        ],
      ),
    );
  }
}
