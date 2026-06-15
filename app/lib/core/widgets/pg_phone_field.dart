import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/features/auth/data/models/country_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PgPhoneField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Country? initialCountry;
  final Function(Country)? onCountryChanged;
  final String? Function(String?)? validator;

  const PgPhoneField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.initialCountry,
    this.onCountryChanged,
    this.validator,
  });

  @override
  State<PgPhoneField> createState() => _PgPhoneFieldState();
}

class _PgPhoneFieldState extends State<PgPhoneField> {
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? Country.countries.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: PgStyles.textStyle(
            context: context,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: PgColors.black,
            fontFamily: PgFonts.googleSans,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.phone,
          validator: widget.validator,
          style: PgStyles.textStyle(
            context: context,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: PgColors.black,
            fontFamily: PgFonts.googleSans,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: PgStyles.textStyle(
              context: context,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade400,
              fontFamily: PgFonts.googleSans,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 15.0, right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<Country>(
                      value: _selectedCountry,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      onChanged: (Country? value) {
                        if (value != null) {
                          setState(() {
                            _selectedCountry = value;
                          });
                          if (widget.onCountryChanged != null) {
                            widget.onCountryChanged!(value);
                          }
                        }
                      },
                      items: Country.countries.map((Country country) {
                        return DropdownMenuItem<Country>(
                          value: country,
                          child: Text(
                            "${country.flag} ${country.dialCode}",
                            style: PgStyles.textStyle(
                              context: context,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: PgColors.black,
                              fontFamily: PgFonts.googleSans,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
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
              borderSide: const BorderSide(color: PgColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
