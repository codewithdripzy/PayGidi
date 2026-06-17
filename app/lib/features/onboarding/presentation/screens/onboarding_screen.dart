import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/features/onboarding/presentation/components/onboarding_indicator.dart';
import 'package:app/features/onboarding/presentation/components/onboarding_title.dart';
import 'package:app/routes/pg_route_names.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoPlay());
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextIndex = (_currentIndex + 1) % 3;

      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 950),
        curve: Curves.easeInOutCubicEmphasized,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0;
                    if (_pageController.position.haveDimensions) {
                      value = index - (_pageController.page ?? 0);
                    }

                    final double opacity = (1 - (value.abs() * 0.75)).clamp(
                      0.0,
                      1.0,
                    );
                    final double scale = (1 + (value.abs() * 0.08)).clamp(
                      1.0,
                      1.18,
                    );

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRect(
                          child: Transform.scale(
                            scale: scale,
                            child: Image.asset(
                              'assets/onboarding_images/page${index + 1}.jpeg',
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x99000000),
                                Color(0x33000000),
                                Color(0xE6000000),
                              ],
                              stops: [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: opacity,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/logo/app_cowry_white.svg",
                        width: 40,
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offsetTween = Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: animation.drive(offsetTween),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey<int>(_currentIndex),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OnboardingTitle(index: _currentIndex),
                        heightSpacing(5),
                        Text(
                          'Secure every transaction with escrow-backed payments and smart trust protection.',
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: PgStyles.textStyle(
                            context: context,
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: PgFonts.googleSans9,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  heightSpacing(18),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: OnboardingIndicator(
                          currentIndex: _currentIndex,
                          totalCount: 3,
                        ),
                      ),
                      const Spacer(),
                      PgScaleButton(
                        onTap: () {
                          context.pushNamed(PgRouteNames.rolePage);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [PgColors.primary, PgColors.secondary],
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Get Started',
                                style: PgStyles.textStyle(
                                  context: context,
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: PgFonts.googleSans9,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
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
