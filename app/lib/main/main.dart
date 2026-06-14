import 'package:app/core/network/api_service.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:app/features/auth/data/services/auth_storage_service.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/main/pg_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize core services
  final apiService = ApiService();
  final authStorageService = AuthStorageService();
  final authRepository = AuthRepository(apiService);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiService),
        Provider.value(value: authRepository),
        Provider.value(value: authStorageService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository, authStorageService),
        ),
      ],
      child: const PgApp(),
    ),
  );
}
