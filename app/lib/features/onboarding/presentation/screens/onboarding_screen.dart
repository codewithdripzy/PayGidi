import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/onboarding/presentation/components/onboarding_indicator.dart';
import 'package:app/features/onboarding/presentation/components/onboarding_title.dart';
import 'package:app/routes/pg_route_names.dart';
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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: 3,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0;
              if (_pageController.position.haveDimensions) {
                value = index - (_pageController.page ?? 0);
              }

              // Transition values
              final double opacity = (1 - (value.abs() * 0.8)).clamp(0.0, 1.0);
              final double scale = (1 + (value.abs() * 0.15)).clamp(1.0, 1.5);
              final double horizontalOffset = value * 200;

              return Stack(
                children: [
                  // Background with Zoom/Parallax
                  Transform.scale(
                    scale: scale,
                    child: SizedBox.expand(
                      child: Image.asset(
                        'assets/onboarding_images/page${index + 1}.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Dark Overlay
                  Transform.scale(
                    scale: scale,
                    child: Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Logo & Indicators
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              "assets/logo/app cowry icon white.svg",
                              width: 40,
                            ),
                            const Spacer(),
                            OnboardingIndicator(
                              currentIndex: _currentIndex,
                              totalCount: 3,
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Animating Title and Description
                        Transform.translate(
                          offset: Offset(horizontalOffset, 0),
                          child: Opacity(
                            opacity: opacity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OnboardingTitle(index: index),
                                heightSpacing(10),
                                PgTexts.text400(
                                  context,
                                  textAlign: TextAlign.start,
                                  text:
                                      "Secure every transaction with escrow-backed payments and smart trust protection.",
                                  fontSize: 14,
                                  fontFamily: PgFonts.googleSans9,
                                  color: Colors.white,
                                  textOverflow: TextOverflow.clip,
                                ),
                              ],
                            ),
                          ),
                        ),
                        heightSpacing(20),

                        // Bottom Action Button with Micro-interactions
                        Align(
                          alignment: Alignment.centerRight,
                          child: PgScaleButton(
                            onTap: () {
                              if (_currentIndex < 2) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                );
                              } else {
                                context.pushNamed(PgRouteNames.rolePage);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              alignment: Alignment.center,
                              height: objectHeight(size: 50, context: context),
                              width: _currentIndex == 2
                                  ? objectWidth(size: 160, context: context)
                                  : objectWidth(size: 50, context: context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: PgColors.black1,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: _currentIndex == 2
                                  ? PgTexts.text600(
                                      context,
                                      text: "Get Started",
                                      color: Colors.white,
                                      fontSize: 16,
                                    )
                                  : const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
