import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class IndividualOtpScreen extends StatelessWidget {
  const IndividualOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: Padding(
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
                text: "Verify your Account",
                fontSize: 28,
                color: PgColors.black,
                fontFamily: PgFonts.stackSans,
              ),
              heightSpacing(12),
              PgTexts.text400(
                context,
                text:
                    "We've sent a 4-digit code to your email and phone number.",
                fontSize: 14,
                color: Colors.black54,
              ),
              heightSpacing(48),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (index) => _buildOtpBox(context, index == 0),
                ),
              ),

              heightSpacing(32),
              Center(
                child: Column(
                  children: [
                    PgTexts.text400(context, text: "Didn't receive the code?"),
                    heightSpacing(8),
                    PgScaleButton(
                      onTap: () {
                        // Resend OTP
                      },
                      child: PgTexts.text600(
                        context,
                        text: "Resend Code",
                        color: PgColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              PgScaleButton(
                onTap: () {
                  // Navigate to success or dashboard
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
                    text: "Verify Now",
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

  Widget _buildOtpBox(BuildContext context, bool autoFocus) {
    return SizedBox(
      height: 70,
      width: 70,
      child: TextFormField(
        autofocus: autoFocus,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: PgStyles.textStyle(
          context: context,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: PgColors.black,
          fontFamily: PgFonts.googleSans,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: PgColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
