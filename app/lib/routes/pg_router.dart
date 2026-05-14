import 'package:app/features/auth/presentation/screens/individual/individual_forgot_password_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_login_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_otp_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_sign_up_screen.dart';
import 'package:app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:app/features/onboarding/presentation/screens/role_screen.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:app/routes/route_transitions.dart';
import 'package:go_router/go_router.dart';

class PayGidiRouter {
  static final returnRouter = GoRouter(
    initialLocation: "/${PgRouteNames.splashPage}",
    routes: [
      GoRoute(
        path: "/${PgRouteNames.splashPage}",
        name: PgRouteNames.splashPage,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RouteTransitions.fade(animation, child),
        ),
      ),
      GoRoute(
        path: "/${PgRouteNames.onboardingPage}",
        name: PgRouteNames.onboardingPage,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RouteTransitions.fade(animation, child),
        ),
      ),
      GoRoute(
        path: "/${PgRouteNames.rolePage}",
        name: PgRouteNames.rolePage,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RoleScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RouteTransitions.slideIn(animation, child),
        ),
      ),
      GoRoute(
        path: "/${PgRouteNames.individualSignUp}",
        name: PgRouteNames.individualSignUp,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const IndividualSignUpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RouteTransitions.slideRight(animation, child),
        ),
      ),
      GoRoute(
        path: "/${PgRouteNames.individualLogin}",
        name: PgRouteNames.individualLogin,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const IndividualLoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RouteTransitions.slideRight(animation, child),
        ),
      ),
      GoRoute(
        path: "/${PgRouteNames.individualOtp}",
        name: PgRouteNames.individualOtp,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const IndividualOtpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RouteTransitions.slideRight(animation, child),
        ),
      ),
      GoRoute(
        path: "/${PgRouteNames.individualForgotPassword}",
        name: PgRouteNames.individualForgotPassword,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const IndividualForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RouteTransitions.slideRight(animation, child),
        ),
      ),
    ],
  );
}
