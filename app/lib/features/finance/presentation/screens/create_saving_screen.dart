import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CreateSavingScreen extends StatelessWidget {
  const CreateSavingScreen({super.key});

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
                  text: "Create Saving",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                const SizedBox(height: 8),
                PgTexts.text400(
                  context,
                  text: "Choose how you want to save your money.",
                  fontSize: 16,
                  color: Colors.grey,
                ),
                const SizedBox(height: 40),
                _buildOptionCard(
                  context,
                  icon: Iconsax.user_copy,
                  title: "Personal Saving",
                  description: "Set a goal and save alone at your own pace.",
                  onTap: () => context.pushNamed(PgRouteNames.createPersonalSaving),
                ),
                const SizedBox(height: 20),
                _buildOptionCard(
                  context,
                  icon: Iconsax.people_copy,
                  title: "Thrift Saving (Ajo)",
                  description: "Save with friends or join a public community thrift.",
                  onTap: () => context.pushNamed(PgRouteNames.createThriftSaving),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return PgScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PgColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: PgColors.primary, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text700(
                    context,
                    text: title,
                    fontSize: 18,
                    color: theme.textTheme.titleMedium?.color ?? PgColors.black,
                  ),
                  const SizedBox(height: 4),
                  PgTexts.text400(
                    context,
                    text: description,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
