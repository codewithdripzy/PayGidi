import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/data/models/country_model.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  Country? _selectedCountry;
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredCountries = Country.countries
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.dialCode.contains(_searchQuery))
        .toList();

    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacing(24),
                PgScaleButton(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_outlined,
                      size: 20,
                    ),
                  ),
                ),
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Where are you?",
                  fontSize: 28,
                  color: PgColors.black,
                  fontFamily: PgFonts.stackSans,
                ),
                heightSpacing(3),
                PgTexts.text400(
                  context,
                  text: "Select your country to get started.",
                  fontSize: 16,
                  color: Colors.black54,
                ),
                heightSpacing(32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: "Search country",
                      border: InputBorder.none,
                      icon: Icon(Iconsax.search_normal_copy, size: 20),
                    ),
                  ),
                ),
                heightSpacing(24),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredCountries.length,
                    separatorBuilder: (context, index) => heightSpacing(12),
                    itemBuilder: (context, index) {
                      final country = filteredCountries[index];
                      final isSelected = _selectedCountry == country;

                      return PgScaleButton(
                        onTap: () => setState(() => _selectedCountry = country),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? PgColors.primary
                                  : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                country.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              widthSpacing(16),
                              Expanded(
                                child: PgTexts.text600(
                                  context,
                                  text: country.name,
                                  fontSize: 16,
                                  color: PgColors.black,
                                ),
                              ),
                              PgTexts.text400(
                                context,
                                text: country.dialCode,
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              if (isSelected) ...[
                                widthSpacing(12),
                                const Icon(
                                  Icons.check_circle,
                                  color: PgColors.primary,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                heightSpacing(24),
                PgScaleButton(
                  onTap: _selectedCountry == null
                      ? null
                      : () {
                          context.pushNamed(
                            PgRouteNames.individualSignUp,
                            extra: {'country': _selectedCountry},
                          );
                        },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _selectedCountry == null ? 0.5 : 1.0,
                    child: Container(
                      height: objectHeight(size: 60, context: context),
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [PgColors.primary, PgColors.secondary],
                        ),
                      ),
                      child: PgTexts.text600(
                        context,
                        text: "Continue",
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                heightSpacing(30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
