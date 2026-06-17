import 'package:app/core/services/biometric_service.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_pin_sheet.dart';
import 'package:app/core/widgets/pg_phone_field.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_success_dialog.dart';
import 'package:app/core/widgets/pg_text_field.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class PaymentLinkScreen extends StatefulWidget {
  const PaymentLinkScreen({super.key});

  @override
  State<PaymentLinkScreen> createState() => _PaymentLinkScreenState();
}

class _PaymentLinkScreenState extends State<PaymentLinkScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _currentStep = 0;

  void _showReviewBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: PgTexts.text700(context, text: "Review Payment Link", fontSize: 22),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerTheme.color ?? Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildReviewItem("Amount", "₦${_amountController.text}"),
                  const Divider(),
                  _buildReviewItem("Merchant Email", _emailController.text),
                  if (_phoneController.text.isNotEmpty) ...[
                    const Divider(),
                    _buildReviewItem("Merchant Phone", _phoneController.text),
                  ],
                  const Divider(),
                  _buildReviewItem("Description", _descriptionController.text.isEmpty ? "No description" : _descriptionController.text),
                  const Divider(),
                  _buildReviewItem("Fee", "₦0.00"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PgTexts.text500(context, text: "Total Payable", color: Colors.grey),
                PgTexts.text700(context, text: "₦${_amountController.text}", fontSize: 20),
              ],
            ),
            const SizedBox(height: 40),
            PgScaleButton(
              onTap: () {
                Navigator.pop(context);
                _startVerificationFlow();
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
                child: PgTexts.text600(context, text: "Generate Link & Pay", color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PgTexts.text400(context, text: label, color: Colors.grey, fontSize: 14),
          Expanded(
            child: PgTexts.text600(
              context,
              text: value,
              textAlign: TextAlign.right,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startVerificationFlow() async {
    final auth = context.read<AuthProvider>();
    final biometricService = BiometricService();
    bool biometricEnabled = await biometricService.isBiometricEnabled();
    
    if (biometricEnabled) {
      bool authenticated = await biometricService.authenticateLocally();
      if (authenticated) { _executePayment(); return; }
    }

    if (auth.userData?.hasPin ?? false) {
      _showPinVerification();
    } else {
      _showCreatePinFlow();
    }
  }

  void _showPinVerification() {
    PgPinSheet.show(
      context,
      title: "Enter PIN",
      description: "Enter your 4-digit transaction PIN to generate payment link.",
      onVerify: (pin) {
        Navigator.pop(context);
        _executePayment();
      },
    );
  }

  void _showCreatePinFlow() {
    PgPinSheet.show(
      context,
      title: "Create PIN",
      description: "You haven't set a transaction PIN. Create one now to continue.",
      onVerify: (pin) {
        Navigator.pop(context);
        _showConfirmPinFlow(pin);
      },
    );
  }

  void _showConfirmPinFlow(String firstPin) {
    PgPinSheet.show(
      context,
      title: "Confirm PIN",
      description: "Re-enter your 4-digit PIN to confirm.",
      onVerify: (pin) {
        if (pin == firstPin) {
          Navigator.pop(context);
          _executePayment();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PINs do not match.")));
        }
      },
    );
  }

  void _executePayment() {
    PgSuccessDialog.show(
      context,
      title: "Link Generated",
      message: "Payment link for ₦${_amountController.text} has been generated and sent to the merchant.",
      buttonText: "Continue",
      onButtonPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : PgColors.homeBackground;

    return buildPGAnnotatedRegion(
      brightness: isDark ? Brightness.light : Brightness.dark,
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacing(24),
                PgScaleButton(
                  onTap: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep = 0);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.dividerTheme.color ?? Colors.grey.shade100),
                    ),
                    child: Icon(Icons.arrow_back_outlined, size: 20, color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
                heightSpacing(24),
                PgTexts.text700(context, text: "Payment Link", fontSize: 28),
                heightSpacing(4),
                PgTexts.text400(
                  context, 
                  text: _currentStep == 0 
                    ? "Enter merchant details to generate payment link." 
                    : "Enter payment amount and description.", 
                  fontSize: 16, 
                  color: Colors.grey
                ),
                heightSpacing(32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_currentStep == 0) ...[
                          PgTextField(
                            controller: _emailController,
                            hintText: "Merchant Email",
                            label: "Merchant Email",
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Iconsax.sms_copy, size: 20, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          PgPhoneField(
                            controller: _phoneController,
                            hintText: "800 000 0000",
                            label: "Merchant Phone Number",
                          ),
                        ] else ...[
                          PgTextField(
                            controller: _amountController,
                            hintText: "0.00",
                            label: "Amount",
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Iconsax.money_2_copy, size: 20, color: Colors.grey),
                            prefix: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text("₦", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          PgTextField(
                            controller: _descriptionController,
                            hintText: "What is this payment for?",
                            label: "Description",
                            maxLines: 3,
                            prefixIcon: const Icon(Iconsax.document_text_copy, size: 20, color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                PgScaleButton(
                  onTap: () {
                    if (_currentStep == 0) {
                      if (_emailController.text.isNotEmpty) {
                        setState(() => _currentStep = 1);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter merchant email.")));
                      }
                    } else {
                      if (_amountController.text.isNotEmpty) {
                        _showReviewBottomSheet();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter an amount.")));
                      }
                    }
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
                    child: PgTexts.text600(context, text: _currentStep == 0 ? "Continue" : "Proceed to Review", color: Colors.white, fontSize: 16),
                  ),
                ),
                heightSpacing(30),
              ],
            ),
          ),
      ),
    );
  }
}
