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

class IndividualSignUpScreen extends StatefulWidget {
  const IndividualSignUpScreen({super.key});

  @override
  State<IndividualSignUpScreen> createState() => _IndividualSignUpScreenState();
}

class _IndividualSignUpScreenState extends State<IndividualSignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PgColors.primary,
              onPrimary: Colors.white,
              onSurface: PgColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day} / ${picked.month} / ${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                text: "Create an Individual Account",
                fontSize: 28,
                color: PgColors.black,
                textOverflow: TextOverflow.clip,
                fontFamily: PgFonts.stackSans,
              ),
              heightSpacing(12),
              PgTexts.text400(
                context,
                text: "Join PayGidi and start transacting with confidence.",
                fontSize: 14,
                color: Colors.black54,
                fontFamily: PgFonts.googleSans36,
              ),
              heightSpacing(40),

              PgTextField(
                label: "Full Name",
                hintText: "Enter your full name",
                controller: _nameController,
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
                textInputAction: TextInputAction.next,
              ),
              heightSpacing(20),
              PgTextField(
                label: "Phone Number",
                hintText: "Enter your phone number",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Iconsax.call_copy, size: 20),
                textInputAction: TextInputAction.next,
              ),
              heightSpacing(20),
              PgTextField(
                label: "Date of Birth",
                hintText: "Select your date of birth",
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                prefixIcon: const Icon(Iconsax.calendar_1_copy, size: 20),
              ),
              heightSpacing(20),
              PgTextField(
                label: "Password",
                hintText: "Create a strong password",
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(Iconsax.lock_copy, size: 20),
                textInputAction: TextInputAction.done,
              ),
              
              heightSpacing(40),
              PgScaleButton(
                onTap: () => context.pushNamed(PgRouteNames.individualOtp),
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
                    text: "Sign Up",
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              heightSpacing(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PgTexts.text400(context, text: "Already have an account? "),
                  GestureDetector(
                    onTap: () => context.pushNamed(PgRouteNames.individualLogin),
                    child: PgTexts.text600(
                      context,
                      text: "Login",
                      color: PgColors.primary,
                    ),
                  ),
                ],
              ),
              heightSpacing(40),
            ],
          ),
        ),
      ),
    );
  }
}
