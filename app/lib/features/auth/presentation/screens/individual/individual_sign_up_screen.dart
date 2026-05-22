import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_snackbar.dart';
import 'package:app/core/widgets/pg_text_field.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

/// [IndividualSignUpScreen] is the starting point for the registration flow.
/// It captures the user's phone number and initiates the OTP verification process.
class IndividualSignUpScreen extends StatefulWidget {
  const IndividualSignUpScreen({super.key});

  @override
  State<IndividualSignUpScreen> createState() => _IndividualSignUpScreenState();
}

class _IndividualSignUpScreenState extends State<IndividualSignUpScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.initiateIndividualAuth(
        phone: "234${_phoneController.text}",
        isLogin: false,
      );

      if (!mounted) return;

      if (success) {
        context.pushNamed(
          PgRouteNames.individualOtp,
          extra: {'isLogin': false, 'phone': "234${_phoneController.text}"},
        );
      } else {
        PgSnackBar.show(
          context,
          message: authProvider.errorMessage ?? "An error occurred",
          isError: true,
        );
      }
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacing(24),
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
                      "assets/logo/app cowry icon.svg",
                      height: 32,
                    ),
                  ],
                ),
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Verify Phone Number",
                  fontSize: 28,
                  color: PgColors.black,
                  fontFamily: PgFonts.stackSans,
                ),
                heightSpacing(12),
                PgTexts.text400(
                  context,
                  text:
                      "Enter your phone number to receive a verification code.",
                  fontSize: 14,
                  color: Colors.black54,
                ),
                heightSpacing(40),
                PgTextField(
                  label: "Phone Number",
                  hintText: "800 000 0000",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Iconsax.call_copy, size: 20),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PgTexts.text600(
                      context,
                      text: "+234",
                      fontSize: 16,
                      color: PgColors.black,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone number is required";
                    }
                    if (value.length != 10) {
                      return "Phone number must be 10 digits";
                    }
                    return null;
                  },
                ),
                heightSpacing(40),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return PgScaleButton(
                      onTap: auth.isLoading ? () {} : _submit,
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
                                text: "Send Code",
                                color: Colors.white,
                                fontSize: 18,
                              ),
                      ),
                    );
                  },
                ),
                heightSpacing(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PgTexts.text400(context, text: "Already have an account? "),
                    GestureDetector(
                      onTap: () =>
                          context.pushNamed(PgRouteNames.individualLogin),
                      child: PgTexts.text600(
                        context,
                        text: "Login",
                        color: PgColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
