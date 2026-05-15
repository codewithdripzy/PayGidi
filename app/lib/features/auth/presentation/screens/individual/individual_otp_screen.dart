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
      if (widget.isLogin && !needsOnboarding) {
        context.goNamed(PgRouteNames.individualHome);
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
              heightSpacing(24),
              PgScaleButton(
                child: const Icon(Icons.arrow_back_outlined),
                onTap: () => context.pop(),
              ),
              heightSpacing(18),
              PgTexts.text700(
                context,
                text: "Verification",
                fontSize: 28,
                color: PgColors.black,
                fontFamily: PgFonts.stackSans,
              ),
              heightSpacing(12),
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
              heightSpacing(32),
              Center(
                child: Column(
                  children: [
                    PgTexts.text400(context, text: "Didn't receive the code?"),
                    heightSpacing(8),
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
                      height: objectHeight(size: 56, context: context),
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: auth.isLoading
                              ? [
                                  PgColors.primary.withValues(alpha: 0.5),
                                  PgColors.secondary.withValues(alpha: 0.5),
                                ]
                              : [PgColors.primary, PgColors.secondary],
                        ),
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
                              text: "Verify Now",
                              color: Colors.white,
                              fontSize: 18,
                            ),
                    ),
                  );
                },
              ),
              heightSpacing(40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, int index) {
    return SizedBox(
      height: 60,
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
        style: PgStyles.textStyle(
          context: context,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: PgColors.black,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
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
