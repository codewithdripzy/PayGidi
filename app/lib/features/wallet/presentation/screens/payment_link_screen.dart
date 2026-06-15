import 'package:app/core/services/biometric_service.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_pin_sheet.dart';
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

  void _showReviewBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: PgTexts.text700(
                context,
                text: "Review Payment Link",
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 32),
            _buildReviewItem("Amount", "₦${_amountController.text}"),
            _buildReviewItem("Merchant Email", _emailController.text),
            if (_phoneController.text.isNotEmpty)
              _buildReviewItem("Merchant Phone", _phoneController.text),
            _buildReviewItem("Description", _descriptionController.text),
            _buildReviewItem("Fee", "₦0.00"),
            const Divider(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PgTexts.text500(context, text: "Total Payable"),
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
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: PgColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: PgTexts.text700(context, text: "Generate Link & Pay", color: Colors.white),
                ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PgTexts.text400(context, text: label, color: Colors.grey),
          Expanded(
            child: PgTexts.text600(
              context,
              text: value,
              textAlign: TextAlign.right,
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
      if (authenticated) {
        _executePayment();
        return;
      }
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PINs do not match.")),
          );
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
    return buildPGAnnotatedRegion(
      brightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Iconsax.arrow_left_copy, color: theme.textTheme.bodyLarge?.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: PgTexts.text600(context, text: "Payment Link", fontSize: 18),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PgTexts.text400(
                context,
                text: "Generate links to make payments to merchants instantly.",
                color: Colors.grey,
              ),
              const SizedBox(height: 32),
              PgTextField(
                controller: _emailController,
                hintText: "Merchant Email",
                label: "Merchant Email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              PgTextField(
                controller: _phoneController,
                hintText: "Merchant Phone Number (Optional)",
                label: "Merchant Phone Number",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              PgTextField(
                controller: _amountController,
                hintText: "0.00",
                label: "Amount",
                keyboardType: TextInputType.number,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("₦", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              PgTextField(
                controller: _descriptionController,
                hintText: "What is this payment for?",
                label: "Description",
                maxLines: 3,
              ),
              const SizedBox(height: 48),
              PgScaleButton(
                onTap: () {
                  if (_emailController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                    _showReviewBottomSheet();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all required fields.")),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: PgColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: PgTexts.text700(context, text: "Generate Link", color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
