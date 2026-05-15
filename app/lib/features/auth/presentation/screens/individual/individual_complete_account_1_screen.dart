import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_text_field.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class IndividualCompleteAccount1Screen extends StatefulWidget {
  const IndividualCompleteAccount1Screen({super.key});

  @override
  State<IndividualCompleteAccount1Screen> createState() => _IndividualCompleteAccount1ScreenState();
}

class _IndividualCompleteAccount1ScreenState extends State<IndividualCompleteAccount1Screen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heightSpacing(24),
              PgScaleButton(
                child: const Icon(Icons.arrow_back_outlined),
                onTap: () => context.pop(),
              ),
              heightSpacing(18),
              PgTexts.text700(
                context,
                text: "Complete Account",
                fontSize: 28,
                color: PgColors.black,
                fontFamily: PgFonts.stackSans,
              ),
              heightSpacing(12),
              PgTexts.text400(
                context,
                text: "Tell us a bit more about yourself to get started.",
                fontSize: 14,
                color: Colors.black54,
              ),
              heightSpacing(40),
              PgTextField(
                label: "First Name",
                hintText: "Enter your first name",
                controller: _firstNameController,
                prefixIcon: const Icon(Iconsax.user_copy, size: 20),
                textInputAction: TextInputAction.next,
              ),
              heightSpacing(20),
              PgTextField(
                label: "Last Name",
                hintText: "Enter your last name",
                controller: _lastNameController,
                prefixIcon: const Icon(Iconsax.user_copy, size: 20),
                textInputAction: TextInputAction.next,
              ),
              heightSpacing(20),
              PgTextField(
                label: "Email Address",
                hintText: "Enter your email address",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Iconsax.sms_copy, size: 20),
                textInputAction: TextInputAction.done,
              ),
              heightSpacing(40),
              PgScaleButton(
                onTap: () => context.pushNamed(PgRouteNames.individualCompleteAccount2),
                child: Container(
                  height: objectHeight(size: 56, context: context),
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [PgColors.primary, PgColors.secondary],
                    ),
                  ),
                  child: PgTexts.text600(
                    context,
                    text: "Next",
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              heightSpacing(40),
            ],
          ),
        ),
      ),
    );
  }
}
