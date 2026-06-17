import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkLoginStatus();

      if (!mounted) return;

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        if (authProvider.isLoggedIn) {
          context.goNamed(PgRouteNames.individualMain);
        } else {
          context.goNamed(PgRouteNames.onboardingPage);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.light,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
        body: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              SvgPicture.asset('assets/logo/full logo.svg', width: 188),
              Spacer(),
              SvgPicture.asset('assets/logo/squad logo.svg', width: 80),
              heightSpacing(45),
            ],
          ),
        ),
      ),
    );
  }
}
