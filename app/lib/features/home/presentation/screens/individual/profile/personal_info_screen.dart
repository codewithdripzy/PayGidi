import 'package:app/core/theme/pg_colors.dart';
// import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;
    final authData = auth.authResponseData;
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
                  text: "Personal Information",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                heightSpacing(32),
                _buildInfoItem(context, "First Name",
                    user?.firstName ?? authData?.firstName ?? ""),
                _buildInfoItem(context, "Last Name",
                    user?.lastName ?? authData?.lastName ?? ""),
                _buildInfoItem(context, "Phone Number",
                    user?.phone ?? authData?.phone ?? ""),
                _buildInfoItem(context, "Email Address",
                    user?.email ?? authData?.email ?? "Not set"),
                _buildInfoItem(
                    context, "Account Type", user?.accountType ?? "Individual"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
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
          PgTexts.text400(
            context,
            text: label,
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5) ??
                Colors.black38,
          ),
          heightSpacing(4),
          PgTexts.text600(
            context,
            text: value,
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
          ),
        ],
      ),
    );
  }
}
