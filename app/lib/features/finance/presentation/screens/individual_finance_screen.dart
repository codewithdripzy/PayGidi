import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/finance/presentation/components/ajo_component.dart';
import 'package:app/features/finance/presentation/components/finance_goals.dart';
import 'package:flutter/material.dart';

class IndividualFinanceScreen extends StatelessWidget {
  const IndividualFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return buildPGAnnotatedRegion(
      brightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                PgTexts.text700(
                  context,
                  text: "Finance",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                  fontFamily: PgFonts.stackSans,
                ),
                const SizedBox(height: 2),
                PgTexts.text400(
                  context,
                  text:
                      "Grow your wealth with smart savings and community Ajo.",
                  fontSize: 16,
                  color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                      .withValues(alpha: 0.7),
                ),
                const SizedBox(height: 32),
                const AjoComponent(),
                const SizedBox(height: 32),
                const FinanceGoals(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
