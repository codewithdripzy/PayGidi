import 'dart:io';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String amount;
  final String recipientName;
  final String bankName;
  final String accountNumber;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.recipientName,
    required this.bankName,
    required this.accountNumber,
  });

  String get _receiptText {
    return 'PAYGIDI PAYMENT RECEIPT\n'
        '═══════════════════════════\n\n'
        'Amount: ₦$amount\n'
        'Recipient: $recipientName\n'
        'Bank: $bankName\n'
        'Account Number: $accountNumber\n'
        'Reference: PAYGIDI_${DateTime.now().millisecondsSinceEpoch}\n'
        'Date: ${DateTime.now().toLocal()}\n\n'
        'Thank you for using PayGidi.';
  }

  Future<void> _shareReceipt(BuildContext context) async {
    final text = _receiptText;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receipt copied to clipboard")),
      );
    }
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final dir = Directory.systemTemp;
      final ref = 'PAYGIDI_${DateTime.now().millisecondsSinceEpoch}';
      final file = File('${dir.path}/$ref.txt');
      await file.writeAsString(_receiptText);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Receipt saved")),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to download receipt")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return buildPGAnnotatedRegion(
      brightness: isDark ? Brightness.light : Brightness.dark,
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 32),
                PgTexts.text700(
                  context,
                  text: "Payment Successful",
                  fontSize: 28,
                  fontFamily: PgFonts.stackSans,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ??
                        (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      PgTexts.text400(
                        context,
                        text: "Amount Sent",
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      PgTexts.text700(
                        context,
                        text: "₦$amount",
                        fontSize: 32,
                        color: const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      _detailRow(context, "Recipient", recipientName),
                      _detailRow(context, "Bank", bankName),
                      _detailRow(context, "Account Number", accountNumber),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                Row(
                  children: [
                    Expanded(
                      child: PgScaleButton(
                        onTap: () => _downloadReceipt(context),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: PgColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.document_download_copy,
                                color: PgColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              PgTexts.text600(
                                context,
                                text: "Download",
                                fontSize: 14,
                                color: PgColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PgScaleButton(
                        onTap: () => _shareReceipt(context),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: PgColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.share_copy,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              PgTexts.text600(
                                context,
                                text: "Share",
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PgScaleButton(
                    onTap: () {
                      context.goNamed(PgRouteNames.individualHome);
                    },
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [PgColors.primary, PgColors.secondary],
                        ),
                      ),
                      child: PgTexts.text600(
                        context,
                        text: "Done",
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PgTexts.text400(
            context,
            text: label,
            fontSize: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PgTexts.text600(
              context,
              text: value,
              fontSize: 14,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
