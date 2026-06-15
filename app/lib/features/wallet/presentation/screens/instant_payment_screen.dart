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

class InstantPaymentScreen extends StatefulWidget {
  const InstantPaymentScreen({super.key});

  @override
  State<InstantPaymentScreen> createState() => _InstantPaymentScreenState();
}

class _InstantPaymentScreenState extends State<InstantPaymentScreen> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedBank;
  bool _addBeneficiary = false;
  bool _isValidatingAccount = false;
  String? _accountName;

  final List<String> _banks = [
    "Access Bank",
    "First Bank",
    "GTBank",
    "Kuda Bank",
    "Moniepoint",
    "OPay",
    "Palmpay",
    "UBA",
    "Zenith Bank",
  ];

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_onAccountChanged);
  }

  void _onAccountChanged() {
    if (_accountController.text.length == 10) {
      _autoFindBank();
    } else {
      setState(() {
        _accountName = null;
      });
    }
  }

  Future<void> _autoFindBank() async {
    setState(() {
      _isValidatingAccount = true;
    });
    // Mock API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isValidatingAccount = false;
      _accountName = "JOHN DOE";
      _selectedBank ??= "OPay"; // Mock auto-select
    });
  }

  void _showBankSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PgTextField(
                label: "Search",
                hintText: "Search Bank",
                prefixIcon: const Icon(Iconsax.search_normal_copy),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: _banks.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: PgTexts.text500(context, text: _banks[index]),
                  onTap: () {
                    setState(() {
                      _selectedBank = _banks[index];
                    });
                    Navigator.pop(context);
                    if (_accountController.text.length == 10) {
                      _autoFindBank();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                text: "Review Payment",
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 32),
            _buildReviewItem("Amount", "₦${_amountController.text}"),
            _buildReviewItem("Bank", _selectedBank ?? ""),
            _buildReviewItem("Account Number", _accountController.text),
            _buildReviewItem("Account Name", _accountName ?? ""),
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
                  child: PgTexts.text700(context, text: "Confirm & Pay", color: Colors.white),
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
          PgTexts.text600(context, text: value),
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

    // If biometric fails or not enabled, fallback to PIN
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
      description: "Enter your 4-digit transaction PIN to complete payment.",
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
      title: "Payment Successful",
      message: "You have successfully sent ₦${_amountController.text} to $_accountName",
      buttonText: "Continue",
      onButtonPressed: () {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Go back from payment screen
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
          title: PgTexts.text600(context, text: "Instant Payment", fontSize: 18),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PgTexts.text400(context, text: "Send money instantly to any bank account.", color: Colors.grey),
              const SizedBox(height: 32),
              PgTextField(
                controller: _accountController,
                hintText: "Account Number",
                label: "Account Number",
                keyboardType: TextInputType.number,
                maxLength: 10,
                suffixIcon: _isValidatingAccount ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
              ),
              if (_accountName != null) ...[
                const SizedBox(height: 8),
                PgTexts.text600(context, text: _accountName!, color: PgColors.primary, fontSize: 14),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _showBankSelection,
                child: AbsorbPointer(
                  child: PgTextField(
                    hintText: _selectedBank ?? "Select Bank",
                    label: "Bank",
                    suffixIcon: const Icon(Iconsax.arrow_down_1_copy),
                  ),
                ),
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
              Row(
                children: [
                  Checkbox(
                    value: _addBeneficiary,
                    onChanged: (val) => setState(() => _addBeneficiary = val ?? false),
                    activeColor: PgColors.primary,
                  ),
                  PgTexts.text500(context, text: "Add as beneficiary", fontSize: 14),
                ],
              ),
              const SizedBox(height: 48),
              PgScaleButton(
                onTap: () {
                  if (_accountController.text.length == 10 && _selectedBank != null && _amountController.text.isNotEmpty) {
                    _showReviewBottomSheet();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields correctly.")),
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
                    child: PgTexts.text700(context, text: "Continue", color: Colors.white),
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
