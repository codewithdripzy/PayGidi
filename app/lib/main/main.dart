import 'package:app/core/network/api_service.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:app/features/auth/data/services/auth_storage_service.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/main/pg_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
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
            create: (_) => AuthProvider(authRepository, authStorageService)),
      ],
      child: const PgApp(),
    ),
  );
}
