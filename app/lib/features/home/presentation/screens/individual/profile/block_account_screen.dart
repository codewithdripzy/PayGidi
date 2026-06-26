import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class BlockAccountScreen extends StatefulWidget {
  const BlockAccountScreen({super.key});

  @override
  State<BlockAccountScreen> createState() => _BlockAccountScreenState();
}

class _BlockAccountScreenState extends State<BlockAccountScreen> {
  bool _isConfirmed = false;
  bool _isLoading = false;

  Future<void> _blockAccount() async {
    setState(() => _isLoading = true);

    final response = await context.read<AuthProvider>().blockAccount();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account blocked successfully"),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to block account'),
          backgroundColor: Colors.red,
        ),
      );
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
            text: "Block Account",
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.user_minus_copy,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    PgTexts.text600(
                      context,
                      text: "Block Your Account?",
                      fontSize: 20,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    PgTexts.text400(
                      context,
                      text:
                          "This will temporarily disable all transactions on your account. You will need to contact support to unblock it.",
                      fontSize: 14,
                      color: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade100,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWarningRow(
                      context,
                      icon: Iconsax.info_circle_copy,
                      text: "No transactions can be made while blocked",
                    ),
                    const SizedBox(height: 16),
                    _buildWarningRow(
                      context,
                      icon: Iconsax.info_circle_copy,
                      text: "Funds remain safe in your account",
                    ),
                    const SizedBox(height: 16),
                    _buildWarningRow(
                      context,
                      icon: Iconsax.info_circle_copy,
                      text: "Contact support to reactivate your account",
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isConfirmed,
                      onChanged: (v) =>
                          setState(() => _isConfirmed = v ?? false),
                      activeColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PgTexts.text400(
                      context,
                      text: "I understand and want to block my account",
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PgScaleButton(
                onTap:
                    (!_isConfirmed || _isLoading) ? null : _blockAccount,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: (!_isConfirmed || _isLoading)
                        ? Colors.grey.shade300
                        : Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : PgTexts.text600(
                            context,
                            text: "Block Account",
                            fontSize: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: PgTexts.text400(
            context,
            text: text,
            fontSize: 13,
            color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
