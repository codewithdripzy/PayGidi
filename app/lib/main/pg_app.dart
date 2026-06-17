import 'package:app/core/theme/pg_theme.dart';
import 'package:app/core/theme/theme_provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/routes/pg_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PgApp extends StatelessWidget {
  const PgApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: "PayGidi",
      debugShowCheckedModeBanner: false,
      routerConfig: PayGidiRouter.router(context.read<AuthProvider>()),
      theme: PayGidiTheme.lightTheme(),
      darkTheme: PayGidiTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
    );
  }
}
