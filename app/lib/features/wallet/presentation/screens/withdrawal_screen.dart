import 'package:app/core/theme/pg_colors.dart';
// import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _amountController = TextEditingController();
  bool _isTapToPayActive = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildPGAnnotatedRegion(
      brightness: Brightness.dark,
      color: PgColors.scaffoldBackground,
      child: Scaffold(
        backgroundColor: PgColors.scaffoldBackground,
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.arrow_back_outlined, size: 20),
                  ),
                ),
                heightSpacing(24),
                PgTexts.text700(
                  context,
                  text: "Withdraw",
                  fontSize: 28,
                  color: PgColors.black,
                ),
                heightSpacing(4),
                PgTexts.text400(
                  context,
                  text:
                      "Move money from your wallet to your bank account or use Tap to Pay.",
                  fontSize: 16,
                  color: Colors.black54,
                ),
                heightSpacing(32),
                _buildAmountInput(context),
                heightSpacing(32),
                _buildTapToPayToggle(context),
                if (_isTapToPayActive) ...[
                  heightSpacing(32),
                  _buildTapToPayUI(context),
                ],
                const Spacer(),
                if (!_isTapToPayActive)
                  PgScaleButton(
                    onTap: () {
                      // Handle withdrawal
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
                        text: "Withdraw Funds",
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
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PgTexts.text500(
          context,
          text: "Amount to Withdraw",
          fontSize: 14,
          color: Colors.black38,
        ),
        heightSpacing(12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              PgTexts.text700(
                context,
                text: "₦",
                fontSize: 24,
                color: PgColors.black,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: PgColors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: "0.00",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTapToPayToggle(BuildContext context) {
    return PgScaleButton(
      onTap: () => setState(() => _isTapToPayActive = !_isTapToPayActive),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isTapToPayActive
              ? PgColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isTapToPayActive ? PgColors.primary : Colors.grey.shade100,
            width: _isTapToPayActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.mobile_copy,
              color: _isTapToPayActive ? PgColors.primary : PgColors.black,
            ),
            widthSpacing(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text600(
                    context,
                    text: "Tap to Pay",
                    fontSize: 16,
                    color: PgColors.black,
                  ),
                  PgTexts.text400(
                    context,
                    text: "Withdraw by tapping your phone.",
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _isTapToPayActive,
              onChanged: (value) => setState(() => _isTapToPayActive = value),
              activeColor: PgColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapToPayUI(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PgColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.radar_copy,
              size: 64,
              color: PgColors.primary,
            ),
          ),
          heightSpacing(24),
          PgTexts.text600(
            context,
            text: "Ready to Tap",
            fontSize: 18,
            color: PgColors.black,
          ),
          heightSpacing(8),
          PgTexts.text400(
            context,
            text:
                "Hold your phone near the contactless terminal to complete the withdrawal.",
            textAlign: TextAlign.center,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }
}
