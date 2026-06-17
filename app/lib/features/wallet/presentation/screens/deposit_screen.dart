import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_snackbar.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

    final accountNumber = account?.accountNumber ?? "8123456789";
    final bankName = account?.bankName ?? "Wema Bank (PayGidi)";
    final accountName = account?.accountName ?? "Joel Onuoha / PayGidi";

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
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: CircularProgressIndicator(),
                  ))
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
                    ],
                  ),
          ),
        ),
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
