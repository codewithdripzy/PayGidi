import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key});

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchReferralInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AuthProvider>();
    final info = provider.referralInfo ?? ReferralInfo.empty();

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
            text: "Invite Friends",
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black,
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildHeader(theme, info),
            const SizedBox(height: 32),
            _buildReferralCodeCard(context, theme, info),
            const SizedBox(height: 24),
            _buildStatsCard(theme, info),
            const SizedBox(height: 32),
            _buildShareSection(context, theme, info),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ReferralInfo info) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PgColors.primary.withValues(alpha: 0.1),
                PgColors.secondary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PgColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.gift_copy,
                  size: 40,
                  color: PgColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              PgTexts.text600(
                context,
                text: info.bonusLabel,
                fontSize: 20,
                color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              PgTexts.text400(
                context,
                text: "Share your referral code with friends and earn rewards when they join PayGidi!",
                fontSize: 14,
                color: Colors.grey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCodeCard(BuildContext context, ThemeData theme, ReferralInfo info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PgTexts.text500(
            context,
            text: "Your Referral Code",
            fontSize: 14,
            color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: PgColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: PgColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child:                   Text(
                    info.referralCode.isNotEmpty
                        ? info.referralCode
                        : '------',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: PgColors.primary,
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Iconsax.copy_copy,
                  label: "Copy Code",
                  onTap: () {
                    if (info.referralCode.isNotEmpty) {
                      Clipboard.setData(
                        ClipboardData(text: info.referralCode),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Referral code copied!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Iconsax.share_copy,
                  label: "Share Link",
                  isPrimary: true,
                  onTap: () => _shareReferral(context, info),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? PgColors.primary
              : PgColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : PgColors.primary,
            ),
            const SizedBox(width: 8),
            PgTexts.text500(
              context,
              text: label,
              fontSize: 14,
              color: isPrimary ? Colors.white : PgColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme, ReferralInfo info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PgTexts.text500(
            context,
            text: "Referral Progress",
            fontSize: 14,
            color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(
                context,
                icon: Iconsax.people_copy,
                value: "${info.totalReferrals}",
                label: "Referrals",
              ),
              _buildDivider(),
              _buildStatItem(
                context,
                icon: Iconsax.money_copy,
                value: info.totalReferrals > 0
                    ? "₦${(info.bonusesEarned * info.bonusPerThreshold).toStringAsFixed(0)}"
                    : "₦0",
                label: "Earned",
              ),
              _buildDivider(),
              _buildStatItem(
                context,
                icon: Iconsax.more_copy,
                value: "${info.pendingReferrals}",
                label: "Pending",
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (info.totalReferrals > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: info.progress,
                minHeight: 6,
                backgroundColor: PgColors.primary.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(PgColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            PgTexts.text400(
              context,
              text: info.pendingReferrals > 0
                  ? "${info.nextBonusProgress}/${info.threshold.toStringAsFixed(0)} towards next bonus"
                  : "Bonus earned! Invite more friends to earn more.",
              fontSize: 12,
              color: Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: PgColors.primary),
          const SizedBox(height: 8),
          PgTexts.text700(
            context,
            text: value,
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? PgColors.black,
          ),
          const SizedBox(height: 2),
          PgTexts.text400(
            context,
            text: label,
            fontSize: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 60,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildShareSection(BuildContext context, ThemeData theme, ReferralInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PgTexts.text500(
          context,
          text: "Share via",
          fontSize: 14,
          color: (theme.textTheme.bodyMedium?.color ?? PgColors.black)
              .withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShareOption(
              context,
              icon: Iconsax.whatsapp_copy,
              color: const Color(0xFF25D366),
              label: "WhatsApp",
              onTap: () => _shareViaWhatsApp(context, info),
            ),
            _buildShareOption(
              context,
              icon: Iconsax.sms_copy,
              color: PgColors.primary,
              label: "Message",
              onTap: () => _shareViaMessage(context, info),
            ),
            _buildShareOption(
              context,
              icon: Iconsax.more_copy,
              color: Colors.grey,
              label: "More",
              onTap: () => _shareGeneric(context, info),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          PgTexts.text400(
            context,
            text: label,
            fontSize: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  String _shareText(ReferralInfo info) {
    return 'Join me on PayGidi! 🎉\n\n'
        'Use my referral code: ${info.referralCode} to sign up '
        'and we both earn rewards!\n\n'
        'Download the app now and start enjoying seamless payments.';
  }

  void _shareReferral(BuildContext context, ReferralInfo info) {
    _shareGeneric(context, info);
  }

  void _shareViaWhatsApp(BuildContext context, ReferralInfo info) async {
    final text = Uri.encodeComponent(_shareText(info));
    final url = 'https://wa.me/?text=$text';
    await _launchUrl(context, url);
  }

  void _shareViaMessage(BuildContext context, ReferralInfo info) async {
    final text = Uri.encodeComponent(_shareText(info));
    final url = 'sms:?body=$text';
    await _launchUrl(context, url);
  }

  void _shareGeneric(BuildContext context, ReferralInfo info) async {
    await _launchUrl(context, _shareText(info), isShare: true);
  }

  Future<void> _launchUrl(BuildContext context, String url, {bool isShare = false}) async {
    try {
      if (isShare) {
        await Clipboard.setData(ClipboardData(text: url));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Copied to clipboard!")),
          );
        }
      }
    } catch (_) {}
  }
}
