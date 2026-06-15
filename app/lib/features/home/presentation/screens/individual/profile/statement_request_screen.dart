import 'package:app/core/theme/pg_colors.dart';
// import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class StatementRequestScreen extends StatefulWidget {
  const StatementRequestScreen({super.key});

  @override
  State<StatementRequestScreen> createState() => _StatementRequestScreenState();
}

class _StatementRequestScreenState extends State<StatementRequestScreen> {
  DateTimeRange? _selectedDateRange;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PgColors.primary,
              onPrimary: Colors.white,
              onSurface: PgColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

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
                heightSpacing(24),
                PgScaleButton(
                  onTap: () => Navigator.pop(context),
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
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Request Statement",
                  fontSize: 28,
                  color: theme.textTheme.titleLarge?.color ?? PgColors.black,
                ),
                heightSpacing(4),
                PgTexts.text400(
                  context,
                  text:
                      "Select a date range to receive your transaction history.",
                  fontSize: 16,
                  color:
                      (theme.textTheme.bodyMedium?.color ?? PgColors.black).withValues(alpha: 0.7),
                ),
                heightSpacing(32),
                _buildDatePicker(context),
                heightSpacing(24),
                PgTexts.text500(
                  context,
                  text: "Send to Email",
                  fontSize: 14,
                  color:
                      (theme.textTheme.bodyMedium?.color ?? PgColors.black).withValues(alpha: 0.5),
                ),
                heightSpacing(12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade100,
                    ),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: theme.textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: "Enter email address",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
                const Spacer(),
                PgScaleButton(
                  onTap: _selectedDateRange == null
                      ? null
                      : () {
                          // Handle request
                        },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _selectedDateRange == null ? 0.5 : 1.0,
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
                        text: "Request Statement",
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                heightSpacing(30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final theme = Theme.of(context);
    final dateString = _selectedDateRange == null
        ? "Select date range"
        : "${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}";

    return PgScaleButton(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.calendar_copy, color: PgColors.primary),
            widthSpacing(16),
            Expanded(
              child: PgTexts.text500(
                context,
                text: dateString,
                fontSize: 16,
                color: _selectedDateRange == null
                    ? Colors.black26
                    : (theme.textTheme.bodyLarge?.color ?? PgColors.black),
              ),
            ),
            const Icon(Iconsax.arrow_right_3_copy, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
