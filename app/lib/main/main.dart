import 'package:app/core/network/api_service.dart';
import 'package:app/core/services/biometric_service.dart';
import 'package:app/core/theme/theme_provider.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:app/features/auth/data/services/auth_storage_service.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/finance/data/repositories/finance_repository.dart';
import 'package:app/features/finance/presentation/providers/finance_provider.dart';
import 'package:app/features/wallet/data/repositories/transaction_repository.dart';
import 'package:app/features/wallet/data/repositories/wallet_repository.dart';
import 'package:app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:app/main/pg_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize core services
  final authStorageService = AuthStorageService();
  final apiService = ApiService(authStorageService);
  final authRepository = AuthRepository(apiService);
  final walletRepository = WalletRepository(apiService);
  final transactionRepository = TransactionRepository(apiService);
  final financeRepository = FinanceRepository(apiService);
  final biometricService = BiometricService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider.value(value: apiService),
        Provider.value(value: authRepository),
        Provider.value(value: walletRepository),
        Provider.value(value: transactionRepository),
        Provider.value(value: financeRepository),
        Provider.value(value: authStorageService),
        Provider.value(value: biometricService),
        ChangeNotifierProxyProvider3<
          AuthRepository,
          AuthStorageService,
          BiometricService,
          AuthProvider
        >(
          create: (context) {
            final authProvider = AuthProvider(
              context.read<AuthRepository>(),
              context.read<AuthStorageService>(),
              context.read<BiometricService>(),
            );
            // Set up global 401 logout
            context.read<ApiService>().onUnauthorized = authProvider.logout;
            return authProvider;
          },
          update: (context, repo, storage, biometric, previous) {
            if (previous != null) return previous;
            final authProvider = AuthProvider(repo, storage, biometric);
            context.read<ApiService>().onUnauthorized = authProvider.logout;
            return authProvider;
          },
        ),
        ChangeNotifierProxyProvider2<
          WalletRepository,
          TransactionRepository,
          WalletProvider
        >(
          create: (context) => WalletProvider(
            context.read<WalletRepository>(),
            context.read<TransactionRepository>(),
          ),
          update: (context, walletRepo, transRepo, previous) =>
              previous ?? WalletProvider(walletRepo, transRepo),
        ),
        ChangeNotifierProvider<FinanceProvider>(
          create: (context) => FinanceProvider(
            context.read<FinanceRepository>(),
          ),
        ),
      ],
      child: const PgApp(),
    ),
  );
}
