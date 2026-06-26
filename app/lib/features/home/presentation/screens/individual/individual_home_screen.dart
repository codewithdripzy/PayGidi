import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/features/home/presentation/components/home_balance_card.dart';
import 'package:app/features/home/presentation/components/home_banner.dart';
import 'package:app/features/home/presentation/components/home_header.dart';
import 'package:app/features/home/presentation/components/home_quick_actions.dart';
import 'package:app/features/home/presentation/components/home_recent_transactions.dart';
import 'package:app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The primary Home Screen for individual users.
/// It assembles the header, balance card, quick actions, promotional banner,
/// and recent transactions list.
class IndividualHomeScreen extends StatelessWidget {
  const IndividualHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : PgColors.homeBackground;

    return buildPGAnnotatedRegion(
      brightness: isDark ? Brightness.light : Brightness.dark,
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: RefreshIndicator(
          onRefresh: () async {
            await walletProvider.refreshAll();
          },
          color: PgColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
              const HomeHeader(),
              const SizedBox(height: 32),
              HomeBalanceCard(
                balance: walletProvider.balance?.totalBalance,
                isLoading: walletProvider.isLoadingBalance,
              ),
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
