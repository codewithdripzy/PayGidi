import 'package:app/features/finance/presentation/screens/create_personal_saving_screen.dart';
import 'package:app/features/finance/presentation/screens/create_saving_screen.dart';
import 'package:app/features/finance/presentation/screens/create_thrift_saving_screen.dart';
import 'package:app/features/finance/presentation/screens/thrift_details_screen.dart';
import 'package:app/features/wallet/presentation/screens/transaction_detail_screen.dart';
import 'package:app/features/wallet/data/models/transaction_model.dart';
import 'package:app/features/wallet/presentation/screens/instant_payment_screen.dart';

import 'package:app/features/wallet/presentation/screens/payment_link_screen.dart';
import 'package:app/features/auth/data/models/country_model.dart';
import 'package:app/features/auth/presentation/screens/country_selection_screen.dart';
import 'package:app/features/home/presentation/screens/individual/individual_home_screen.dart';
import 'package:app/features/home/presentation/screens/individual/individual_main_screen.dart';
import 'package:app/features/home/presentation/screens/individual/profile/statement_request_screen.dart';
import 'package:app/features/wallet/presentation/screens/deposit_screen.dart';
import 'package:app/features/wallet/presentation/screens/withdrawal_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_forgot_password_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_login_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_otp_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_sign_up_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_complete_account_1_screen.dart';
import 'package:app/features/auth/presentation/screens/individual/individual_complete_account_2_screen.dart';
import 'package:app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:app/features/onboarding/presentation/screens/role_screen.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:app/routes/route_transitions.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class PayGidiRouter {
  static GoRouter? _router;

  static GoRouter router(AuthProvider authProvider) {
    _router ??= GoRouter(
      initialLocation: "/${PgRouteNames.splashPage}",
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isSplash = state.matchedLocation == "/${PgRouteNames.splashPage}";
        final isOnboarding =
            state.matchedLocation == "/${PgRouteNames.onboardingPage}";
        final isRole = state.matchedLocation == "/${PgRouteNames.rolePage}";
        final isSignUp =
            state.matchedLocation == "/${PgRouteNames.individualSignUp}";
        final isLogin =
            state.matchedLocation == "/${PgRouteNames.individualLogin}";
        final isOtp =
            state.matchedLocation == "/${PgRouteNames.individualOtp}";
        final isForgotPassword =
            state.matchedLocation == "/${PgRouteNames.individualForgotPassword}";
        final isCountry =
            state.matchedLocation == "/${PgRouteNames.countrySelection}";

        final isAuthPage = isOnboarding ||
            isRole ||
            isSignUp ||
            isLogin ||
            isOtp ||
            isForgotPassword ||
            isCountry;

        if (isSplash) return null;

        if (!isLoggedIn && !isAuthPage) {
          return "/${PgRouteNames.onboardingPage}";
        }

        if (isLoggedIn && isAuthPage) {
          return "/${PgRouteNames.individualMain}";
        }

        return null;
      },
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
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final country = extra?['country'] as Country?;
            return CustomTransitionPage(
              child: IndividualSignUpScreen(country: country),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      RouteTransitions.slideRight(animation, child),
            );
          },
        ),
        GoRoute(
          path: "/${PgRouteNames.countrySelection}",
          name: PgRouteNames.countrySelection,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const CountrySelectionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.individualLogin}",
          name: PgRouteNames.individualLogin,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const IndividualLoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.individualOtp}",
          name: PgRouteNames.individualOtp,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final isLogin = extra?['isLogin'] ?? false;
            final phone = extra?['phone'] ?? "";
            return CustomTransitionPage(
              child: IndividualOtpScreen(isLogin: isLogin, phone: phone),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      RouteTransitions.slideRight(animation, child),
            );
          },
        ),
        GoRoute(
          path: "/${PgRouteNames.individualCompleteAccount1}",
          name: PgRouteNames.individualCompleteAccount1,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const IndividualCompleteAccount1Screen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.individualCompleteAccount2}",
          name: PgRouteNames.individualCompleteAccount2,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return CustomTransitionPage(
              child: IndividualCompleteAccount2Screen(
                firstName: extra?['firstName'] ?? "",
                lastName: extra?['lastName'] ?? "",
                email: extra?['email'] ?? "",
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      RouteTransitions.slideRight(animation, child),
            );
          },
        ),
        GoRoute(
          path: "/${PgRouteNames.individualForgotPassword}",
          name: PgRouteNames.individualForgotPassword,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const IndividualForgotPasswordScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.individualHome}",
          name: PgRouteNames.individualHome,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const IndividualHomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.fade(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.individualMain}",
          name: PgRouteNames.individualMain,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const IndividualMainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.fade(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.deposit}",
          name: PgRouteNames.deposit,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const DepositScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.withdrawal}",
          name: PgRouteNames.withdrawal,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const WithdrawalScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.statementRequest}",
          name: PgRouteNames.statementRequest,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const StatementRequestScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.instantPayment}",
          name: PgRouteNames.instantPayment,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const InstantPaymentScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.paymentLink}",
          name: PgRouteNames.paymentLink,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const PaymentLinkScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.createSaving}",
          name: PgRouteNames.createSaving,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const CreateSavingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.createPersonalSaving}",
          name: PgRouteNames.createPersonalSaving,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const CreatePersonalSavingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.createThriftSaving}",
          name: PgRouteNames.createThriftSaving,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const CreateThriftSavingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    RouteTransitions.slideRight(animation, child),
          ),
        ),
        GoRoute(
          path: "/${PgRouteNames.thriftDetails}",
          name: PgRouteNames.thriftDetails,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return CustomTransitionPage(
              child: ThriftDetailsScreen(
                  thriftName: extra?['thriftName'] ?? "Thrift"),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      RouteTransitions.slideRight(animation, child),
            );
          },
        ),
        GoRoute(
          path: "/${PgRouteNames.transactionDetails}",
          name: PgRouteNames.transactionDetails,
          pageBuilder: (context, state) {
            final transaction = state.extra as Transaction;
            return CustomTransitionPage(
              child: TransactionDetailScreen(transaction: transaction),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      RouteTransitions.slideRight(animation, child),
            );
          },
        ),
      ],
    );
    return _router!;
  }
}
