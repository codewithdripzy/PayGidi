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
    ],
  );
}
