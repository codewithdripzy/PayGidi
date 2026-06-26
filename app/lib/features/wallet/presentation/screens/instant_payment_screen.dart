import 'package:app/core/network/api_service.dart';
import 'package:app/core/services/biometric_service.dart';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_pin_sheet.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_text_field.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/wallet/data/models/bank_model.dart';
import 'package:app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:app/routes/pg_route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class InstantPaymentScreen extends StatefulWidget {
  const InstantPaymentScreen({super.key});

  @override
  State<InstantPaymentScreen> createState() => _InstantPaymentScreenState();
}

class _InstantPaymentScreenState extends State<InstantPaymentScreen> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  Bank? _selectedBank;
  bool _isValidatingAccount = false;
  bool _isProcessingPayment = false;
  String? _accountName;
  int _currentStep = 0;
  String _searchQuery = "";
  String _rawAmount = "";

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_onAccountChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchBanks();
    });
  }

  void _onAccountChanged() {
    if (_accountController.text.length == 10 && _selectedBank != null) {
      _verifyAccount();
    } else {
      setState(() {
        _accountName = null;
      });
    }
  }

  Future<void> _verifyAccount() async {
    if (_selectedBank == null) return;
    setState(() => _isValidatingAccount = true);

    final walletProvider = context.read<WalletProvider>();
    // Assuming WalletProvider has a corresponding method or needs one added.
    // The previous code called `walletProvider.verifyAccount`.
    // I need to make sure this maps to the `/transfer/lookup` endpoint.
    final response = await walletProvider.lookupAccount(
      accountNumber: _accountController.text,
      bankCode: _selectedBank!.code,
    );

    if (mounted) {
      setState(() {
        _isValidatingAccount = false;
        if (response.data != null) {
          _accountName =
              response.data!['accountName'] ?? response.data!['account_name'];
        } else {
          _accountName = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? "Failed to verify account"),
            ),
          );
        }
      });
    }
  }

  void _showBankSelection() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
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
                  onChanged: (val) {
                    setModalState(() => _searchQuery = val);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<WalletProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoadingBanks) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          itemCount: 8,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Container(
                              height: 16,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    final filteredBanks = provider.banks
                        .where(
                          (bank) => bank.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();

                    if (filteredBanks.isEmpty) {
                      return Center(
                        child: PgTexts.text400(context, text: "No banks found"),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: filteredBanks.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: PgTexts.text500(
                          context,
                          text: filteredBanks[index].name,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedBank = filteredBanks[index];
                            _accountName = null;
                          });
                          Navigator.pop(context);
                          if (_accountController.text.length == 10) {
                            _verifyAccount();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.dividerTheme.color ?? Colors.grey.shade100,
                ),
              ),
              child: Column(
                children: [
                  _buildReviewItem("Amount", "₦${_formatComma(_rawAmount)}"),
                  const Divider(),
                  _buildReviewItem("Bank", _selectedBank?.name ?? ""),
                  const Divider(),
                  _buildReviewItem("Account Number", _accountController.text),
                  const Divider(),
                  _buildReviewItem("Account Name", _accountName ?? ""),
                  const Divider(),
                  _buildReviewItem("Fee", "₦0.00"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PgTexts.text500(
                  context,
                  text: "Total Payable",
                  color: Colors.grey,
                ),
                PgTexts.text700(
                  context,
                  text: "₦${_formatComma(_rawAmount)}",
                  fontSize: 20,
                ),
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
                child: PgTexts.text600(
                  context,
                  text: "Confirm & Pay",
                  color: Colors.white,
                  fontSize: 16,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PgTexts.text400(
            context,
            text: label,
            color: Colors.grey,
            fontSize: 14,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PgTexts.text600(
              context,
              text: value,
              fontSize: 14,
              textOverflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatComma(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  Future<void> _startVerificationFlow() async {
    final auth = context.read<AuthProvider>();
    final biometricService = context.read<BiometricService>();
    bool biometricEnabled = await biometricService.isBiometricEnabled();

    if (biometricEnabled) {
      bool authenticated = await biometricService.authenticateLocally();
      if (authenticated) {
        _executePayment();
        return;
      }
    }

    if (auth.hasPin) {
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
      description:
          "You haven't set a transaction PIN. Create one now to continue.",
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("PINs do not match.")));
        }
      },
    );
  }

  Future<void> _executePayment() async {
    setState(() => _isProcessingPayment = true);

    final walletProvider = context.read<WalletProvider>();
    final amount = double.tryParse(_rawAmount) ?? 0;
    final response = await walletProvider.transfer(
      amount: amount,
      accountNumber: _accountController.text,
      bankCode: _selectedBank!.code,
      accountName: _accountName,
      narration: "Instant Payment",
      currencyId: "NGN",
    );

    if (mounted) {
      setState(() => _isProcessingPayment = false);
      if (response.error == null) {
        _sendReceiptEmail(amount);
        if (!mounted) return;
        context.goNamed(
          PgRouteNames.paymentSuccess,
          extra: {
            'amount': _formatComma(_rawAmount),
            'recipientName': _accountName ?? '',
            'bankName': _selectedBank?.name ?? '',
            'accountNumber': _accountController.text,
          },
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? "Payment failed")),
        );
      }
    }
  }

  Future<void> _sendReceiptEmail(double amount) async {
    try {
      final auth = context.read<AuthProvider>();
      final email = auth.userData?.email;
      final notifyEnabled =
          auth.userData?.preferences?.notificationsEnabled ?? false;
      if (email == null || email.isEmpty || !notifyEnabled) return;

      final apiService = context.read<ApiService>();
      await apiService.post(
        '/notification/email',
        data: {
          'to': email,
          'subject': 'Payment Receipt - PayGidi',
          'body':
              '''
Dear ${auth.userData?.person?.firstName ?? 'Valued Customer'},

Your payment of ₦${_formatComma(_rawAmount)} to $_accountName has been successful.

Transaction Details:
- Amount: ₦${_formatComma(_rawAmount)}
- Recipient: $_accountName
- Bank: ${_selectedBank?.name ?? ''}
- Account Number: ${_accountController.text}
- Reference: PAYGIDI_${DateTime.now().millisecondsSinceEpoch}

Thank you for using PayGidi.

Best regards,
PayGidi Team
''',
          'type': 'receipt',
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.scaffoldBackgroundColor
        : PgColors.homeBackground;

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
                    border: Border.all(
                      color: theme.dividerTheme.color ?? Colors.grey.shade100,
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
              PgTexts.text700(context, text: "Instant Payment", fontSize: 28),
              heightSpacing(4),
              PgTexts.text400(
                context,
                text: _currentStep == 0
                    ? "Enter recipient details to send money."
                    : "How much would you like to send to $_accountName?",
                fontSize: 16,
                color: Colors.grey,
              ),
              heightSpacing(32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_currentStep == 0) ...[
                        GestureDetector(
                          onTap: _showBankSelection,
                          child: AbsorbPointer(
                            child: PgTextField(
                              // Use a controller or just display text to control color
                              // Since PgTextField takes 'hintText', and we want it to look "filled",
                              // we might need to adjust PgTextField or just use 'controller'
                              controller: TextEditingController(
                                text: _selectedBank?.name ?? "",
                              ),
                              hintText: "Select Bank",
                              label: "Bank",
                              prefixIcon: const Icon(
                                Iconsax.bank_copy,
                                size: 20,
                                color: Colors.grey,
                              ),
                              suffixIcon: const Icon(Iconsax.arrow_down_1_copy),
                              // This is a trick to make it look "greyed out" if we can't change the field style
                              // enabled: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PgTextField(
                          controller: _accountController,
                          hintText: "Account Number",
                          label: "Account Number",
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          prefixIcon: const Icon(
                            Iconsax.card_copy,
                            size: 20,
                            color: Colors.grey,
                          ),
                          suffixIcon: _isValidatingAccount
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        if (_accountName != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: PgTexts.text600(
                                    context,
                                    text: _accountName!,
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: PgFonts.googleSans,
                          ),
                          decoration: InputDecoration(
                            labelText: "Amount",
                            labelStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade400,
                              fontFamily: PgFonts.googleSans,
                            ),
                            prefixIcon: Container(
                              alignment: Alignment.centerLeft,
                              width: 40,
                              padding: const EdgeInsets.only(left: 16, top: 0),
                              child: Text(
                                "₦",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                  fontFamily: PgFonts.googleSans,
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 0,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: PgColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            final digits = value.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            if (digits.isEmpty) {
                              _rawAmount = '';
                              if (_amountController.text.isNotEmpty) {
                                _amountController.text = '';
                                _amountController.selection =
                                    TextSelection.collapsed(offset: 0);
                              }
                              return;
                            }
                            _rawAmount = digits;
                            final formatted = _formatComma(digits);
                            final prev = _amountController.text;
                            if (formatted != prev) {
                              _amountController.text = formatted;
                              _amountController.selection =
                                  TextSelection.collapsed(
                                    offset: formatted.length,
                                  );
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              PgScaleButton(
                onTap: _isProcessingPayment
                    ? null
                    : () {
                        if (_currentStep == 0) {
                          if (_accountController.text.length == 10 &&
                              _selectedBank != null &&
                              _accountName != null) {
                            setState(() => _currentStep = 1);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Please enter valid account details."),
                              ),
                            );
                          }
                        } else {
                          if (_amountController.text.isNotEmpty) {
                            _showReviewBottomSheet();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter an amount."),
                              ),
                            );
                          }
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: _isProcessingPayment ||
                            (_currentStep == 0
                                ? (_selectedBank == null ||
                                    _accountController.text.length != 10 ||
                                    _accountName == null)
                                : _rawAmount.isEmpty)
                        ? const LinearGradient(
                            colors: [Colors.grey, Colors.grey],
                          )
                        : const LinearGradient(
                            colors: [PgColors.primary, PgColors.secondary],
                          ),
                  ),
                  child: _isProcessingPayment
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : PgTexts.text600(
                          context,
                          text: _currentStep == 0
                              ? "Continue"
                              : "Proceed to Review",
                          color: Colors.white,
                          fontSize: 16,
                        ),
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
