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
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

/// [IndividualLoginScreen] handles the authentication of existing individual users.
/// It verifies the phone number and redirects to the OTP screen.
class IndividualLoginScreen extends StatefulWidget {
  const IndividualLoginScreen({super.key});

  @override
  State<IndividualLoginScreen> createState() => _IndividualLoginScreenState();
}

class _IndividualLoginScreenState extends State<IndividualLoginScreen> {
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
        isLogin: true,
      );

      if (!mounted) return;

      if (success) {
        context.pushNamed(
          PgRouteNames.individualOtp,
          extra: {'isLogin': true, 'phone': "234${_phoneController.text}"},
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
                  text: "Login securely to your PayGidi account.",
                  fontSize: 14,
                  color: Colors.black54,
                ),
                heightSpacing(48),
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
                heightSpacing(48),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return PgScaleButton(
                      onTap: auth.isLoading
                          ? () {}
                          : () async {
                              await _submit();
                            },
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
                                text: "Continue",
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
                    PgTexts.text400(context, text: "Don't have an account? "),
                    GestureDetector(
                      onTap: () =>
                          context.pushNamed(PgRouteNames.individualSignUp),
                      child: PgTexts.text600(
                        context,
                        text: "Sign Up",
                        color: PgColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                heightSpacing(40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
