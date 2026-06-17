import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/features/home/presentation/components/home_balance_card.dart';
import 'package:app/features/home/presentation/components/home_banner.dart';
import 'package:app/features/home/presentation/components/home_header.dart';
import 'package:app/features/home/presentation/components/home_quick_actions.dart';
import 'package:app/features/home/presentation/components/home_recent_transactions.dart';
import 'package:flutter/material.dart';

/// The primary Home Screen for individual users.
/// It assembles the header, balance card, quick actions, promotional banner,
/// and recent transactions list.
class IndividualHomeScreen extends StatelessWidget {
  const IndividualHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: RefreshIndicator(
          onRefresh: () async {
            // Add refresh logic here
            await Future.delayed(const Duration(seconds: 2));
          },
          color: PgColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
              const HomeHeader(),
              const SizedBox(height: 32),
              const HomeBalanceCard(),
              const SizedBox(height: 32),
              const HomeQuickActions(),
              const SizedBox(height: 32),
              const HomeBanner(),
              const SizedBox(height: 32),
              const HomeRecentTransactions(),
            ],
          ),
        ),
      ),
    ),
  );
}
}
