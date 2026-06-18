import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: PgColors.primary),
            const SizedBox(height: 16),
            PgTexts.text700(context, text: "$title Coming Soon", fontSize: 24),
            const SizedBox(height: 8),
            PgTexts.text400(context, text: "We're working on it!", color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
