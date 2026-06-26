import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _expandedIndex;

  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: "How do I create a PayGidi account?",
      answer:
          "Download the PayGidi app, enter your phone number, and follow the verification process. "
          "You'll need to provide your BVN and personal details to complete registration.",
    ),
    _FaqItem(
      question: "How do I fund my wallet?",
      answer:
          "Go to the Deposit section on your dashboard. You can fund your wallet via bank transfer "
          "to your unique virtual account number, or use a debit card.",
    ),
    _FaqItem(
      question: "How do I send money?",
      answer:
          "Tap on 'Send Money' from the dashboard. Enter the recipient's details or select from "
          "your contacts, enter the amount, and confirm with your transaction PIN.",
    ),
    _FaqItem(
      question: "What is a savings goal?",
      answer:
          "A savings goal lets you set a target amount and save towards it over time. "
          "You can create multiple goals, track your progress, and withdraw when you reach your target.",
    ),
    _FaqItem(
      question: "What is a thrift savings plan?",
      answer:
          "Thrift savings plans are group or individual recurring savings that help you build "
          "discipline. You can join an existing thrift group or create your own with custom rules.",
    ),
    _FaqItem(
      question: "How do I reset my transaction PIN?",
      answer:
          "Go to Settings > Security & PIN. You can update your PIN if you remember the current one. "
          "If you've forgotten it, contact support for assistance with resetting it.",
    ),
    _FaqItem(
      question: "Is my money safe with PayGidi?",
      answer:
          "Yes. PayGidi uses industry-standard encryption and security measures. Your funds are "
          "held in licensed financial institutions. Enable biometrics and two-factor authentication "
          "for extra security.",
    ),
    _FaqItem(
      question: "How do I withdraw money?",
      answer:
          "Go to the Withdraw section and enter the amount. You can withdraw to your linked bank "
          "account. Processing usually takes 1-24 hours depending on your bank.",
    ),
    _FaqItem(
      question: "What are the transaction limits?",
      answer:
          "Transaction limits depend on your account level and verification status. "
          "Check your Account Limits in the Settings menu for your specific limits.",
    ),
    _FaqItem(
      question: "How do I contact support?",
      answer:
          "You can reach us through the Contact Us page in Settings, send an email to "
          "support@paygidi.com, or call our helpline. We're available 24/7 to assist you.",
    ),
  ];

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
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Iconsax.arrow_left_copy,
              color: theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: PgTexts.text600(
            context,
            text: "Help Center",
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black,
          ),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: _faqs.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: PgColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.info_circle_copy,
                          color: PgColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PgTexts.text600(
                              context,
                              text: "Frequently Asked Questions",
                              fontSize: 16,
                              color:
                                  theme.textTheme.bodyLarge?.color ??
                                  PgColors.black,
                            ),
                            PgTexts.text400(
                              context,
                              text:
                                  "Find answers to common questions about PayGidi.",
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (index == 1) {
              return const SizedBox(height: 0);
            }

            final faqIndex = index - 2;
            final faq = _faqs[faqIndex];
            final isExpanded = _expandedIndex == faqIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpansionTileTheme(
                data: ExpansionTileThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  childrenPadding: EdgeInsets.zero,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  backgroundColor: theme.cardTheme.color,
                  collapsedBackgroundColor: theme.cardTheme.color,
                  initiallyExpanded: isExpanded,
                  splashColor: Colors.transparent,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedIndex = expanded ? faqIndex : null;
                    });
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PgColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.message_question_copy,
                      size: 18,
                      color: PgColors.primary,
                    ),
                  ),
                  title: PgTexts.text500(
                    context,
                    text: faq.question,
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                  ),
                  trailing: Icon(
                    isExpanded ? Iconsax.minus_copy : Iconsax.add_copy,
                    size: 18,
                    color: PgColors.primary,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: PgTexts.text400(
                        context,
                        text: faq.answer,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
