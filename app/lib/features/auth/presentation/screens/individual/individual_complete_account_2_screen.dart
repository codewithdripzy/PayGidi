import 'package:app/core/config/app_config.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_snackbar.dart';
import 'package:app/core/widgets/pg_text_field.dart';
import 'package:app/core/widgets/pg_success_dialog.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';
import 'package:google_maps_places_autocomplete_widgets/model/place.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

/// [IndividualCompleteAccount2Screen] is the final step of the account completion process.
/// It collects verification data like NIN and BVN to finalize account registration.
class IndividualCompleteAccount2Screen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  const IndividualCompleteAccount2Screen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  State<IndividualCompleteAccount2Screen> createState() =>
      _IndividualCompleteAccount2ScreenState();
}

class _IndividualCompleteAccount2ScreenState
    extends State<IndividualCompleteAccount2Screen> {
  final _bvnController = TextEditingController();
  final _ninController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  DateTime? _birthDate;

  @override
  void dispose() {
    _bvnController.dispose();
    _ninController.dispose();
    _dobController.dispose();
    _addressController.dispose();
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
        _birthDate = picked;
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        PgSnackBar.show(
          context,
          message: "Please select your date of birth",
          isError: true,
        );
        return;
      }

      if (_selectedGender == null) {
        PgSnackBar.show(
          context,
          message: "Please select your gender",
          isError: true,
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final request = IndividualCompleteAccountRequest(
        firstName: widget.firstName,
        lastName: widget.lastName,
        email: widget.email,
        dateOfBirth: _dobController.text,
        nin: _ninController.text,
        address: _addressController.text,
        bvn: _bvnController.text.isNotEmpty ? _bvnController.text : null,
        gender: _selectedGender == "Male"
            ? "1"
            : "2", // Based on backend 1=Male, 2=Female
      );

      final success = await authProvider.completeIndividualAccount(request);

      if (!mounted) return;

      if (success) {
        _showSuccessDialog();
      } else {
        PgSnackBar.show(
          context,
          message: authProvider.errorMessage ?? "Failed to complete account",
          isError: true,
        );
      }
    }
  }

  void _showSuccessDialog() {
    PgSuccessDialog.show(
      context,
      title: "Success!",
      message:
          "Your account has been created successfully. Welcome to PayGidi!",
      buttonText: "Go to Home",
      onButtonPressed: () => context.goNamed(PgRouteNames.individualMain),
    );
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
                  text: "Final Step",
                  fontSize: 28,
                  color: PgColors.black,
                  fontFamily: PgFonts.stackSans,
                ),
                heightSpacing(5),
                PgTexts.text400(
                  context,
                  text:
                      "Provide your NIN and other details to secure your account.",
                  fontSize: 14,
                  color: Colors.black54,
                ),
                heightSpacing(40),
                PgTextField(
                  label: "NIN (National Identification Number)",
                  hintText: "Enter your 10-digit NIN",
                  controller: _ninController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Iconsax.shield_tick_copy, size: 20),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "NIN is required";
                    }
                    if (value.length < 11) {
                      return "NIN must be at least 11 digits";
                    }
                    return null;
                  },
                ),
                heightSpacing(20),
                PgTextField(
                  label: "BVN (Optional)",
                  hintText: "Enter your 11-digit BVN",
                  controller: _bvnController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Iconsax.shield_security, size: 20),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
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
                PgTexts.text500(
                  context,
                  text: "Residential Address",
                  fontSize: 12,
                  color: PgColors.black,
                  fontFamily: PgFonts.googleSans,
                ),
                heightSpacing(5),
                AddressAutocompleteTextFormField(
                  mapsApiKey: AppConfig.googleMapsApiKey,
                  controller: _addressController,
                  onSuggestionClick: (Place place) {
                    _addressController.text = place.formattedAddress ?? "";
                  },
                  componentCountry: 'ng',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Address is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Search your address",
                    hintStyle: PgStyles.textStyle(
                      context: context,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                      fontFamily: PgFonts.googleSans,
                    ),
                    prefixIcon: const Icon(Iconsax.location_copy, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: PgColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                ),
                heightSpacing(20),
                PgTexts.text500(
                  context,
                  text: "Gender",
                  fontSize: 14,
                  color: PgColors.black,
                ),
                heightSpacing(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: PgTexts.text400(
                        context,
                        text: "Select Gender",
                        color: Colors.grey,
                      ),
                      isExpanded: true,
                      items: ["Male", "Female"]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: PgTexts.text400(context, text: e),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                  ),
                ),
                heightSpacing(40),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return PgScaleButton(
                      onTap: auth.isLoading ? () {} : _submit,
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
                                text: "Complete Account",
                                color: Colors.white,
                                fontSize: 16,
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
      ),
    );
  }
}
