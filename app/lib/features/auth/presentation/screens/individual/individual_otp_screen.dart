import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_snackbar.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// [IndividualOtpScreen] verifies the 5-digit code sent to the user's phone.
/// It directs the user either to the dashboard (if returning) or to complete account setup (if new).
class IndividualOtpScreen extends StatefulWidget {
  final bool isLogin;
  final String phone;

  const IndividualOtpScreen({
    super.key,
    this.isLogin = false,
    required this.phone,
  });

  @override
  State<IndividualOtpScreen> createState() => _IndividualOtpScreenState();
}

class _IndividualOtpScreenState extends State<IndividualOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 5) {
      PgSnackBar.show(
        context,
        message: "Please enter the full 5-digit code",
        isError: true,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(
      phone: widget.phone,
      code: _otp,
    );

    if (!mounted) return;

    if (success) {
      final needsOnboarding = authProvider.userData?.needsOnboarding ?? false;
      if (!needsOnboarding) {
        context.goNamed(PgRouteNames.individualMain);
      } else {
        context.pushNamed(PgRouteNames.individualCompleteAccount1);
      }
    } else {
      PgSnackBar.show(
        context,
        message: authProvider.errorMessage ?? "Verification failed",
        isError: true,
      );
    }
  }

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
              heightSpacing(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PgScaleButton(
                    onTap: () => context.pop(),
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
                  SvgPicture.asset(
                    "assets/logo/app_cowry_icon.svg",
                    height: 32,
                  ),
                ],
              ),
              heightSpacing(24),
              PgTexts.text700(
                context,
                text: "Verification",
                fontSize: 28,
                color: PgColors.black,
                fontFamily: PgFonts.stackSans,
              ),
              heightSpacing(3),
              PgTexts.text400(
                context,
                text: "We've sent a 5-digit code to ${widget.phone}.",
                fontSize: 14,
                color: Colors.black54,
              ),
              heightSpacing(48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => _buildOtpBox(context, index),
                ),
              ),
              heightSpacing(24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 3.0,
                  children: [
                    PgTexts.text400(context, text: "Didn't receive the code?"),
                    // heightSpacing(8),
                    PgScaleButton(
                      onTap: () {
                        // Resend OTP logic could be added here
                      },
                      child: PgTexts.text600(
                        context,
                        text: "Resend Code",
                        color: PgColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return PgScaleButton(
                    onTap: auth.isLoading ? () {} : _verify,
                    child: Container(
                      height: objectHeight(size: 60, context: context),
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                          colors: auth.isLoading
                              ? [
                                  PgColors.primary.withValues(alpha: 0.5),
                                  PgColors.secondary.withValues(alpha: 0.5),
                                ]
                              : [PgColors.primary, PgColors.secondary],
                        ),
                        boxShadow: [
                          if (!auth.isLoading)
                            BoxShadow(
                              color: PgColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : PgTexts.text600(
                              context,
                              text: "Verify Account",
                              color: Colors.white,
                              fontSize: 15,
                            ),
                    ),
                  );
                },
              ),
              heightSpacing(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, int index) {
    return SizedBox(
      width: 60,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        autofocus: index == 0,
        onChanged: (value) {
          if (value.length == 1 && index < 4) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (_otp.length == 5) {
            _verify();
          }
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        cursorHeight: 24,
        style: PgStyles.textStyle(
          context: context,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: PgColors.black,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PgColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
