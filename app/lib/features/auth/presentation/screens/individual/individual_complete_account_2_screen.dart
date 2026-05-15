import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_text_field.dart';
import 'package:app/core/widgets/pg_success_dialog.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class IndividualCompleteAccount2Screen extends StatefulWidget {
  const IndividualCompleteAccount2Screen({super.key});

  @override
  State<IndividualCompleteAccount2Screen> createState() => _IndividualCompleteAccount2ScreenState();
}

class _IndividualCompleteAccount2ScreenState extends State<IndividualCompleteAccount2Screen> {
  final _bvnController = TextEditingController();
  final _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  DateTime? _birthDate;

  @override
  void dispose() {
    _bvnController.dispose();
    _dobController.dispose();
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
        _dobController.text = "${picked.day} / ${picked.month} / ${picked.year}";
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select your date of birth")),
        );
        return;
      }

      final age = DateTime.now().difference(_birthDate!).inDays / 365;
      if (age < 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be at least 18 years old")),
        );
        return;
      }

      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select your gender")),
        );
        return;
      }

      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    PgSuccessDialog.show(
      context,
      title: "Success!",
      message: "Your account has been created successfully. Welcome to PayGidi!",
      buttonText: "Go to Home",
      onButtonPressed: () => context.goNamed(PgRouteNames.individualHome),
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
                heightSpacing(12),
                PgTexts.text400(
                  context,
                  text: "Provide your BVN and other details to secure your account.",
                  fontSize: 14,
                  color: Colors.black54,
                ),
                heightSpacing(40),
                PgTextField(
                  label: "BVN (Bank Verification Number)",
                  hintText: "Enter your 11-digit BVN",
                  controller: _bvnController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Iconsax.shield_tick_copy, size: 20),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "BVN is required";
                    }
                    if (value.length != 11) {
                      return "BVN must be 11 digits";
                    }
                    return null;
                  },
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
                  text: "Gender",
                  fontSize: 14,
                  color: PgColors.black,
                ),
                heightSpacing(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: PgTexts.text400(context, text: "Select Gender", color: Colors.grey),
                      isExpanded: true,
                      items: ["Male", "Female", "Other"]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: PgTexts.text400(context, text: e),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                  ),
                ),
    
                heightSpacing(40),
                PgScaleButton(
                  onTap: _submit,
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
                      text: "Submit",
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
      ),
    );
  }
}

