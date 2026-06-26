import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_snackbar.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchVirtualAccount();
    });
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    PgSnackBar.showSuccess(context, "$label copied to clipboard");
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final account = walletProvider.virtualAccount;

    final accountNumber = (account?.accountNumber ?? '').isNotEmpty
        ? account!.accountNumber
        : '-';
    final bankName = (account?.bankName ?? '').isNotEmpty
        ? account!.bankName
        : '-';
    final accountName = (account?.accountName ?? '').isNotEmpty
        ? account!.accountName
        : '-';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? theme.scaffoldBackgroundColor : PgColors.homeBackground;

    return buildPGAnnotatedRegion(
      brightness: isDark ? Brightness.light : Brightness.dark,
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: RefreshIndicator(
          onRefresh: () async {
            await walletProvider.fetchVirtualAccount();
          },
          color: PgColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: walletProvider.isLoadingVirtualAccount
                ? _buildSkeleton()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heightSpacing(24),
                      PgScaleButton(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: theme.dividerTheme.color ??
                                    Colors.grey.shade100),
                          ),
                          child: Icon(Icons.arrow_back_outlined,
                              size: 20,
                              color: theme.textTheme.bodyLarge?.color),
                        ),
                      ),
                      heightSpacing(18),
                      PgTexts.text700(
                        context,
                        text: "Deposit",
                        fontSize: 28,
                        color: PgColors.black,
                        fontFamily: PgFonts.stackSans,
                      ),
                      heightSpacing(4),
                      PgTexts.text400(
                        context,
                        text:
                            "Transfer money to your PayGidi account using the details below.",
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      heightSpacing(40),
                      _buildAccountDetailCard(
                        context,
                        label: "Account Number",
                        value: accountNumber,
                        onCopy: () => _copyToClipboard(
                            context, accountNumber, "Account number"),
                      ),
                      heightSpacing(24),
                      _buildAccountDetailCard(
                        context,
                        label: "Bank Name",
                        value: bankName,
                        onCopy: () =>
                            _copyToClipboard(context, bankName, "Bank name"),
                      ),
                      heightSpacing(24),
                      _buildAccountDetailCard(
                        context,
                        label: "Account Name",
                        value: accountName,
                        onCopy: () => _copyToClipboard(
                            context, accountName, "Account name"),
                      ),
                      heightSpacing(40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: PgColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: PgColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.info_circle_copy,
                              color: PgColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PgTexts.text400(
                                context,
                                text:
                                    "Please send money to the account details above. Once completed, check your wallet dashboard to verify your top-up.",
                                fontSize: 12,
                                color: PgColors.primary,
                                textOverflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                      ),
                    ),
                    if (kDebugMode) ...[
                      heightSpacing(24),
                      Center(
                        child: PgScaleButton(
                          onTap: () => _showSimulateBottomSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.flash_copy,
                                  size: 18,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 8),
                                PgTexts.text600(
                                  context,
                                  text: "Dev: Simulate Deposit",
                                  fontSize: 14,
                                  color: Colors.amber.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
          ),
        ),
      ),
    );
  }

  void _showSimulateBottomSheet(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final walletProvider = sheetContext.read<WalletProvider>();
        final account = walletProvider.virtualAccount;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Form(
              key: formKey,
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
                      sheetContext,
                      text: "Simulate Deposit",
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
                        color: theme.dividerTheme.color ??
                            Colors.grey.shade100,
                      ),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: "Amount",
                            hintText: "Enter amount",
                            prefixText: "₦ ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Enter an amount";
                            }
                            if (double.tryParse(v) == null ||
                                double.parse(v) <= 0) {
                              return "Enter a valid amount";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: "Description (optional)",
                            hintText: "e.g. Salary payment",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (account != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: PgColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.bank_copy,
                                    size: 16, color: PgColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: PgTexts.text400(
                                    sheetContext,
                                    text:
                                        "${account.accountNumber} - ${account.bankName}",
                                    fontSize: 12,
                                    color: PgColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PgTexts.text500(
                        sheetContext,
                        text: "Dev: Test Credit",
                        color: Colors.grey,
                      ),
                      PgTexts.text700(
                        sheetContext,
                        text:
                            "₦${amountController.text.isEmpty ? "0" : amountController.text}",
                        fontSize: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  PgScaleButton(
                    onTap: walletProvider.isSimulatingDeposit
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final amount = amountController.text.trim();
                            final response =
                                await walletProvider.simulateDeposit(
                              accountNumber:
                                  account?.accountNumber ?? '',
                              amount: amount,
                            );
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            if (response.isSuccess) {
                              PgSnackBar.showSuccess(
                                context,
                                "₦$amount deposited successfully",
                              );
                              walletProvider.refreshAll();
                            } else {
                              PgSnackBar.showError(
                                context,
                                response.error ??
                                    "Failed to simulate deposit",
                              );
                            }
                          },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [
                            PgColors.primary,
                            PgColors.secondary,
                          ],
                        ),
                      ),
                      child: walletProvider.isSimulatingDeposit
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : PgTexts.text600(
                              sheetContext,
                              text: "Deposit",
                              color: Colors.white,
                              fontSize: 16,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heightSpacing(24),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          heightSpacing(18),
          Container(
            width: 120,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          heightSpacing(4),
          Container(
            width: 300,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          heightSpacing(40),
          _buildSkeletonCard(),
          heightSpacing(24),
          _buildSkeletonCard(),
          heightSpacing(24),
          _buildSkeletonCard(),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailCard(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PgTexts.text400(
            context,
            text: label,
            fontSize: 12,
            color: Colors.black54,
          ),
          heightSpacing(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: PgTexts.text600(
                  context,
                  text: value,
                  fontSize: 18,
                  color: PgColors.black,
                  textOverflow: TextOverflow.visible,
                ),
              ),
              PgScaleButton(
                onTap: onCopy,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PgColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Iconsax.copy_copy,
                    color: PgColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
