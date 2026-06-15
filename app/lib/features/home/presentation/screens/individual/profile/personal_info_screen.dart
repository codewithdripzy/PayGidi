import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;

    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.arrow_back_outlined, size: 20),
                  ),
                ),
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Personal Information",
                  fontSize: 28,
                  color: PgColors.black,
                ),
                heightSpacing(32),
                _buildInfoItem(context, "First Name", user?.firstName ?? ""),
                _buildInfoItem(context, "Last Name", user?.lastName ?? ""),
                _buildInfoItem(context, "Phone Number", user?.phone ?? ""),
                _buildInfoItem(context, "Email Address", user?.email ?? "Not set"),
                _buildInfoItem(context, "Account Type", user?.accountType ?? "Individual"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PgTexts.text400(
            context,
            text: label,
            fontSize: 12,
            color: Colors.black38,
          ),
          heightSpacing(4),
          PgTexts.text600(
            context,
            text: value,
            fontSize: 16,
            color: PgColors.black,
          ),
        ],
      ),
    );
  }
}
