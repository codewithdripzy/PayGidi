import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/main/pg_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const PgApp(),
    ),
  );
}
