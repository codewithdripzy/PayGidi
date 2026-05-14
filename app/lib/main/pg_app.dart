import 'package:app/core/theme/pg_theme.dart';
import 'package:app/routes/pg_router.dart';
import 'package:flutter/material.dart';

class PgApp extends StatelessWidget {
  const PgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "PayGidi",
      debugShowCheckedModeBanner: false,
      routerConfig: PayGidiRouter.returnRouter,
      theme: PayGidiTheme.lightTheme(),
      darkTheme: PayGidiTheme.darkTheme(),
      themeMode: ThemeMode.light,
    );
  }
}
