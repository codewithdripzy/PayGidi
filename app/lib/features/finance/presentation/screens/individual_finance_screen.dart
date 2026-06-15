import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/finance/presentation/components/finance_goals.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PgTexts.text700(
                            context,
                            text: "Finance",
                            fontSize: 28,
                            color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                            fontFamily: PgFonts.stackSans,
                          ),
                          PgTexts.text400(
                            context,
                            text: "Manage your savings & thrifts.",
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      PgScaleButton(
                        onTap: () => context.pushNamed(PgRouteNames.createSaving),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: PgColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSavingsSummary(context),
                const SizedBox(height: 32),
                const FinanceGoals(), // Reusing existing goals component for Personal Savings
                const SizedBox(height: 32),
                _buildJoinedThrifts(context),
                const SizedBox(height: 32),
                _buildPublicThrifts(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [PgColors.primary, PgColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: PgColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PgTexts.text400(
              context,
              text: "Total Savings",
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 8),
            PgTexts.text700(
              context,
              text: "₦1,850,000.00",
              fontSize: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildMiniStat(context, "Personal", "₦1,200,000"),
                const SizedBox(width: 32),
                _buildMiniStat(context, "Thrifts", "₦650,000"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PgTexts.text400(
          context,
          text: label,
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        PgTexts.text600(
          context,
          text: value,
          fontSize: 14,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildJoinedThrifts(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PgTexts.text700(
            context,
            text: "My Thrifts (Ajo)",
            fontSize: 18,
            color: theme.textTheme.titleLarge?.color ?? PgColors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildThriftCard(
                context,
                name: "Tech Bro Circle",
                contribution: "₦100,000/mo",
                members: 8,
                isPublic: false,
              ),
              const SizedBox(width: 16),
              _buildThriftCard(
                context,
                name: "Lagos Foodies",
                contribution: "₦20,000/mo",
                members: 15,
                isPublic: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThriftCard(
    BuildContext context, {
    required String name,
    required String contribution,
    required int members,
    required bool isPublic,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PgColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PgTexts.text600(
                  context,
                  text: isPublic ? "Public" : "Private",
                  fontSize: 10,
                  color: PgColors.primary,
                ),
              ),
              Icon(Iconsax.share_copy, size: 18, color: Colors.grey.shade400),
            ],
          ),
          const Spacer(),
          PgTexts.text700(
            context,
            text: name,
            fontSize: 16,
            color: theme.textTheme.titleMedium?.color ?? PgColors.black,
          ),
          const SizedBox(height: 4),
          PgTexts.text600(
            context,
            text: contribution,
            fontSize: 14,
            color: PgColors.primary,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Iconsax.people_copy, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              PgTexts.text400(
                context,
                text: "$members members",
                fontSize: 12,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPublicThrifts(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PgTexts.text700(
                context,
                text: "Discover Public Thrifts",
                fontSize: 18,
                color: theme.textTheme.titleLarge?.color ?? PgColors.black,
              ),
              TextButton(
                onPressed: () {},
                child: PgTexts.text600(
                  context,
                  text: "See All",
                  fontSize: 14,
                  color: PgColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPublicThriftItem(
            context,
            name: "Entrepreneurs Hub",
            description: "High volume monthly contribution for business growth.",
            contribution: "₦500,000/mo",
            members: 42,
          ),
          const SizedBox(height: 16),
          _buildPublicThriftItem(
            context,
            name: "Student Savings",
            description: "Small daily contributions for students.",
            contribution: "₦500/day",
            members: 128,
          ),
        ],
      ),
    );
  }

  Widget _buildPublicThriftItem(
    BuildContext context, {
    required String name,
    required String description,
    required String contribution,
    required int members,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: PgColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.status_up_copy, color: PgColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text700(
                  context,
                  text: name,
                  fontSize: 16,
                  color: theme.textTheme.titleMedium?.color ?? PgColors.black,
                ),
                PgTexts.text400(
                  context,
                  text: description,
                  fontSize: 12,
                  color: Colors.grey,
                  textOverflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    PgTexts.text600(
                      context,
                      text: contribution,
                      fontSize: 12,
                      color: PgColors.primary,
                    ),
                    const SizedBox(width: 12),
                    PgTexts.text400(
                      context,
                      text: "$members members",
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PgScaleButton(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: PgColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: PgTexts.text600(
                context,
                text: "Join",
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
