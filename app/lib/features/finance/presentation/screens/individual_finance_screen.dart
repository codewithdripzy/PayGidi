import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/finance/presentation/components/finance_goals.dart';
import 'package:app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IndividualFinanceScreen extends StatefulWidget {
  const IndividualFinanceScreen({super.key});

  @override
  State<IndividualFinanceScreen> createState() =>
      _IndividualFinanceScreenState();
}

class _IndividualFinanceScreenState extends State<IndividualFinanceScreen> {
  bool _showBalance = true;
  int _currentCardIndex = 0;
  int _selectedThriftTabIndex = 0;
  final _currencyFormatter =
      NumberFormat.currency(symbol: "₦", decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? theme.scaffoldBackgroundColor : PgColors.homeBackground;

    return buildPGAnnotatedRegion(
      brightness: isDark ? Brightness.light : Brightness.dark,
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
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
                            color:
                                theme.textTheme.titleLarge?.color ??
                                PgColors.black,
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
                        onTap: () =>
                            context.pushNamed(PgRouteNames.createSaving),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: PgColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSavingsCarousel(context),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child:
                      const FinanceGoals(), // Reusing existing goals component for Personal Savings
                ),
                const SizedBox(height: 32),
                _buildThriftTabs(context),
                const SizedBox(height: 24),
                _selectedThriftTabIndex == 0
                    ? _buildJoinedThrifts(context)
                    : _buildPublicThrifts(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsCarousel(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final balance = walletProvider.balance;

    return Column(
      children: [
        SizedBox(
          height: 150, // Shorter height
          child: PageView(
            onPageChanged: (index) {
              setState(() {
                _currentCardIndex = index;
              });
            },
            controller: PageController(viewportFraction: 0.9),
            children: [
              _buildBalanceCard(
                context,
                title: "Total Savings",
                amount: _currencyFormatter.format(balance?.totalBalance ?? 0),
              ),
              _buildBalanceCard(
                context,
                title: "Personal Savings",
                amount:
                    _currencyFormatter.format(balance?.personalSavings ?? 0),
              ),
              _buildBalanceCard(
                context,
                title: "Thrift Savings",
                amount: _currencyFormatter.format(balance?.thriftSavings ?? 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => _buildIndicator(index == _currentCardIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 20 : 6,
      decoration: BoxDecoration(
        color: isActive ? PgColors.secondary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context, {
    required String title,
    required String amount,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? null : PgColors.black1,
          gradient: isDark
              ? const LinearGradient(
                  colors: [PgColors.primary, PgColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PgTexts.text500(
                      context,
                      text: title,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showBalance = !_showBalance),
                      child: Icon(
                        _showBalance
                            ? Iconsax.eye_copy
                            : Iconsax.eye_slash_copy,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  "assets/logo/app_cowry_white.svg",
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PgTexts.text700(
              context,
              text: _showBalance ? amount : "₦ **********",
              fontSize: 36,
              fontFamily: PgFonts.googleSans,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThriftTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTabItem(context, "My Thrifts", 0),
          const SizedBox(width: 24),
          _buildTabItem(context, "Public Thrifts", 1),
          const Spacer(),
          PgScaleButton(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: PgColors.black,
                borderRadius: BorderRadius.circular(100),
              ),
              child: PgTexts.text600(
                context,
                text: "See All",
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String title, int index) {
    final isSelected = _selectedThriftTabIndex == index;
    final theme = Theme.of(context);

    return PgScaleButton(
      onTap: () => setState(() => _selectedThriftTabIndex = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PgTexts.text600(
            context,
            text: title,
            fontSize: 14,
            color: isSelected
                ? (theme.textTheme.titleLarge?.color ?? PgColors.black)
                : Colors.grey,
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 32 : 0,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [PgColors.primary, PgColors.secondary],
                    )
                  : null,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedThrifts(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildThriftCard(
            context,
            name: "Tech Bro Circle",
            description: "Monthly savings for tech professionals.",
            contribution: "₦100k/mo",
            members: 8,
            image: "assets/onboarding_images/page1.jpeg",
          ),
          const SizedBox(width: 16),
          _buildThriftCard(
            context,
            name: "Lagos Foodies",
            description: "Saving for culinary adventures.",
            contribution: "₦20k/mo",
            members: 15,
            image: "assets/onboarding_images/page2.jpeg",
          ),
        ],
      ),
    );
  }

  Widget _buildThriftCard(
    BuildContext context, {
    required String name,
    required String description,
    required String contribution,
    required int members,
    String? image,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PgScaleButton(
      onTap: () => context.pushNamed(
        PgRouteNames.thriftDetails,
        extra: {'thriftName': name},
      ),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: isDark ? PgColors.black1 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : PgColors.black.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.status_up_copy,
                    color: isDark ? Colors.white : PgColors.black,
                    size: 20,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PgTexts.text700(
                      context,
                      text: name,
                      fontSize: 14,
                      color: isDark ? Colors.white : PgColors.black,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    PgTexts.text400(
                      context,
                      text: description,
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.grey,
                      maxLines: 2,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PgTexts.gradientText(
                          context,
                          text: contribution,
                          fontSize: 11,
                          gradient: PgColors.primaryGradient,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : PgColors.black,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: PgTexts.text600(
                            context,
                            text: "Manage",
                            fontSize: 10,
                            color: isDark ? PgColors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicThrifts(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildPublicThriftItem(
            context,
            name: "Entrepreneurs Hub",
            description: "High volume monthly contribution.",
            contribution: "₦500k/mo",
            members: 42,
            image: "assets/onboarding_images/page3.jpeg",
          ),
          const SizedBox(width: 16),
          _buildPublicThriftItem(
            context,
            name: "Student Savings",
            description: "Small daily contributions.",
            contribution: "₦500/day",
            members: 128,
            image: "assets/onboarding_images/page1.jpeg",
          ),
          const SizedBox(width: 16),
          _buildPublicThriftItem(
            context,
            name: "Agro Investors",
            description: "Saving for the next harvest.",
            contribution: "₦50k/mo",
            members: 64,
            image: "assets/onboarding_images/page2.jpeg",
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
    String? image,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: isDark ? PgColors.black1 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : PgColors.black.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.status_up_copy,
                  color: isDark ? Colors.white : PgColors.black,
                  size: 20,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text700(
                    context,
                    text: name,
                    fontSize: 14,
                    color: isDark ? Colors.white : PgColors.black,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  PgTexts.text400(
                    context,
                    text: description,
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey,
                    maxLines: 2,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PgTexts.gradientText(
                        context,
                        text: contribution,
                        fontSize: 11,
                        gradient: PgColors.primaryGradient,
                      ),
                      PgScaleButton(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : PgColors.black,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: PgTexts.text600(
                            context,
                            text: "Join",
                            fontSize: 10,
                            color: isDark ? PgColors.black : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
