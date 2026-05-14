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

class IndividualLoginScreen extends StatelessWidget {
  const IndividualLoginScreen({super.key});

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
                text: "Welcome Back!",
                fontSize: 32,
                color: PgColors.black,
                fontFamily: PgFonts.stackSans,
              ),
              heightSpacing(12),
              PgTexts.text400(
                context,
                text: "Securely login to your PayGidi account.",
                fontSize: 14,
                color: Colors.black54,
              ),
              heightSpacing(48),

              const PgTextField(
                label: "Email or Phone Number",
                hintText: "Enter your email or phone",
                prefixIcon: Icon(Iconsax.user_copy, size: 20),
              ),
              heightSpacing(20),
              const PgTextField(
                label: "Password",
                hintText: "Enter your password",
                isPassword: true,
                prefixIcon: Icon(Iconsax.lock_copy, size: 20),
              ),

              heightSpacing(12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () =>
                      context.pushNamed(PgRouteNames.individualForgotPassword),
                  child: PgTexts.text500(
                    context,
                    text: "Forgot Password?",
                    color: PgColors.primary,
                  ),
                ),
              ),

              heightSpacing(48),
              PgScaleButton(
                onTap: () {
                  // Handle login
                },
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
                    text: "Login",
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              heightSpacing(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PgTexts.text400(context, text: "Don't have an account? "),
                  GestureDetector(
                    onTap: () =>
                        context.pushNamed(PgRouteNames.individualSignUp),
                    child: PgTexts.text600(
                      context,
                      text: "Sign Up",
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
