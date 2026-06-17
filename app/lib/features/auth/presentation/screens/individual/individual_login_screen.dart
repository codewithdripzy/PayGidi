import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_phone_field.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_snackbar.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/data/models/country_model.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
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
  Country _selectedCountry = Country.countries.first;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final dialCode = _selectedCountry.dialCode.replaceAll('+', '');
      final fullPhone = "$dialCode${_phoneController.text}";
      
      final success = await authProvider.initiateIndividualAuth(
        phone: fullPhone,
        isLogin: true,
      );

      if (!mounted) return;

      if (success) {
        context.pushNamed(
          PgRouteNames.individualOtp,
          extra: {
            'isLogin': true,
            'phone': fullPhone,
            'country': _selectedCountry,
          },
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
                      "assets/logo/app_cowry_icon.svg",
                      height: 32,
                    ),
                  ],
                ),
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Welcome Back!",
                  fontSize: 32,
                  color: PgColors.black,
                  fontFamily: PgFonts.stackSans,
                ),
                heightSpacing(2),
                PgTexts.text400(
                  context,
                  text: "Login securely to your PayGidi account.",
                  fontSize: 14,
                  color: Colors.black54,
                ),
                heightSpacing(48),
                PgPhoneField(
                  label: "Phone Number",
                  hintText: "800 000 0000",
                  controller: _phoneController,
                  initialCountry: _selectedCountry,
                  onCountryChanged: (country) {
                    setState(() {
                      _selectedCountry = country;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone number is required";
                    }
                    if (value.length < 7) {
                      return "Enter a valid phone number";
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
                                fontSize: 16,
                              ),
                      ),
                    );
                  },
                ),
                heightSpacing(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PgTexts.text400(context, text: "Don't have an account? "),
                    GestureDetector(
                      onTap: () =>
                          context.pushNamed(PgRouteNames.countrySelection),
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
