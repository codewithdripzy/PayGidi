import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_text_field.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePersonalSavingScreen extends StatefulWidget {
  const CreatePersonalSavingScreen({super.key});

  @override
  State<CreatePersonalSavingScreen> createState() => _CreatePersonalSavingScreenState();
}

class _CreatePersonalSavingScreenState extends State<CreatePersonalSavingScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return buildPGAnnotatedRegion(
      brightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                PgScaleButton(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_outlined,
                      size: 20,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PgTexts.text700(
                  context,
                  text: "Personal Saving",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                const SizedBox(height: 32),
                PgTextField(
                  label: "Goal Name",
                  hintText: "e.g. New Laptop, Vacation",
                  controller: _nameController,
                ),
                const SizedBox(height: 24),
                PgTextField(
                  label: "Target Amount",
                  hintText: "₦ 0.00",
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                ),
                const Spacer(),
                PgScaleButton(
                  onTap: () {
                    // Create saving logic
                    context.pop();
                    context.pop();
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [PgColors.primary, PgColors.secondary],
                      ),
                    ),
                    child: PgTexts.text600(
                      context,
                      text: "Create Saving Goal",
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
