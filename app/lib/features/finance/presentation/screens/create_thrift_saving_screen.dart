import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_text_field.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CreateThriftSavingScreen extends StatefulWidget {
  const CreateThriftSavingScreen({super.key});

  @override
  State<CreateThriftSavingScreen> createState() => _CreateThriftSavingScreenState();
}

class _CreateThriftSavingScreenState extends State<CreateThriftSavingScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isPublic = false;

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
                const SizedBox(height: 24),
                PgScaleButton(
                  onTap: () => context.pop(),
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
                const SizedBox(height: 24),
                PgTexts.text700(
                  context,
                  text: "Thrift Saving",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                const SizedBox(height: 32),
                PgTextField(
                  label: "Thrift Name",
                  hintText: "e.g. Monthly Circle, Family Ajo",
                  controller: _nameController,
                ),
                const SizedBox(height: 24),
                PgTextField(
                  label: "Contribution Amount",
                  hintText: "₦ 0.00",
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                PgTexts.text600(
                  context,
                  text: "Privacy Type",
                  fontSize: 16,
                  color: theme.textTheme.titleMedium?.color ?? PgColors.black,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPrivacyOption(
                        context,
                        title: "Private",
                        icon: Iconsax.lock_copy,
                        isSelected: !_isPublic,
                        onTap: () => setState(() => _isPublic = false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPrivacyOption(
                        context,
                        title: "Public",
                        icon: Iconsax.global_copy,
                        isSelected: _isPublic,
                        onTap: () => setState(() => _isPublic = true),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                PgScaleButton(
                  onTap: () {
                    // Create thrift logic
                    context.pop();
                    context.pop();
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: PgColors.black,
                    ),
                    child: PgTexts.text600(
                      context,
                      text: "Start Thrift",
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return PgScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? PgColors.black.withValues(alpha: 0.1)
              : theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? PgColors.black : (theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? PgColors.black : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            PgTexts.text600(
              context,
              text: title,
              fontSize: 14,
              color: isSelected ? PgColors.black : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
