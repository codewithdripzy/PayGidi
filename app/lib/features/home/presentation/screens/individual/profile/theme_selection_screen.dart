import 'package:app/core/theme/pg_colors.dart';
// import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/theme/theme_provider.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
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
                  text: "Appearance",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                heightSpacing(4),
                PgTexts.text400(
                  context,
                  text: "Choose your preferred theme.",
                  fontSize: 16,
                  color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                      .withValues(alpha: 0.7),
                ),
                heightSpacing(32),
                _buildThemeOption(
                  context,
                  title: "System Default",
                  mode: ThemeMode.system,
                  currentMode: themeProvider.themeMode,
                  icon: Iconsax.setting_2_copy,
                ),
                heightSpacing(16),
                _buildThemeOption(
                  context,
                  title: "Light Mode",
                  mode: ThemeMode.light,
                  currentMode: themeProvider.themeMode,
                  icon: Iconsax.sun_1_copy,
                ),
                heightSpacing(16),
                _buildThemeOption(
                  context,
                  title: "Dark Mode",
                  mode: ThemeMode.dark,
                  currentMode: themeProvider.themeMode,
                  icon: Iconsax.moon_copy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
  }) {
    final isSelected = currentMode == mode;
    final theme = Theme.of(context);

    return PgScaleButton(
      onTap: () => context.read<ThemeProvider>().setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? PgColors.primary
                : (theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey.shade100),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? PgColors.primary
                  : (theme.textTheme.bodyLarge?.color ?? PgColors.black),
            ),
            widthSpacing(16),
            Expanded(
              child: PgTexts.text500(
                context,
                text: title,
                fontSize: 16,
                color: isSelected
                    ? PgColors.primary
                    : (theme.textTheme.bodyLarge?.color ?? PgColors.black),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: PgColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
