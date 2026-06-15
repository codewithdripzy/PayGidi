import 'dart:math';
import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ThriftDetailsScreen extends StatelessWidget {
  final String thriftName;
  const ThriftDetailsScreen({super.key, required this.thriftName});

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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildHeader(context),
                const SizedBox(height: 32),
                Center(
                  child: ThriftTurnVisualizer(
                    membersCount: 8,
                    currentTurnIndex: 2,
                  ),
                ),
                const SizedBox(height: 32),
                _buildThriftInfo(context),
                const SizedBox(height: 32),
                _buildMembersList(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PgScaleButton(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey.shade200,
                ),
              ),
              child: Icon(
                Icons.arrow_back_outlined,
                size: 20,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          PgTexts.text700(
            context,
            text: thriftName,
            fontSize: 20,
          ),
          PgScaleButton(
            onTap: () {
              // Share logic
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PgColors.black.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.share_copy,
                size: 20,
                color: PgColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThriftInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
          ),
        ),
        child: Column(
          children: [
            _buildInfoRow(context, "Contribution", "₦100,000/mo"),
            const Divider(height: 32),
            _buildInfoRow(context, "Total Pot", "₦800,000"),
            const Divider(height: 32),
            _buildInfoRow(context, "Your Turn", "August 2026"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isAmount = value.startsWith('₦');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PgTexts.text400(context, text: label, color: Colors.grey),
        if (isAmount)
          PgTexts.gradientText(
            context,
            text: value,
            fontSize: 16,
            gradient: PgColors.primaryGradient,
          )
        else
          PgTexts.text600(context, text: value, fontSize: 16),
      ],
    );
  }

  Widget _buildMembersList(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PgTexts.text700(context, text: "Members (8)", fontSize: 18),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: PgColors.black.withValues(alpha: 0.1),
                      child: PgTexts.text600(
                        context,
                        text: "${index + 1}",
                        fontSize: 14,
                        color: PgColors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PgTexts.text600(
                        context,
                        text: "Member ${index + 1}",
                        fontSize: 16,
                      ),
                    ),
                    if (index == 2)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PgTexts.text600(
                          context,
                          text: "Collecting",
                          fontSize: 10,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ThriftTurnVisualizer extends StatelessWidget {
  final int membersCount;
  final int currentTurnIndex;

  const ThriftTurnVisualizer({
    super.key,
    required this.membersCount,
    required this.currentTurnIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The ring
          CustomPaint(
            size: const Size(220, 220),
            painter: CircleRingPainter(
              color: PgColors.black.withValues(alpha: 0.1),
              highlightColor: PgColors.black,
              membersCount: membersCount,
              currentTurnIndex: currentTurnIndex,
            ),
          ),
          // Current person in center
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PgTexts.text400(context, text: "Current Collector", color: Colors.grey, fontSize: 12),
              const SizedBox(height: 4),
              PgTexts.text700(context, text: "Member ${currentTurnIndex + 1}", fontSize: 18),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PgColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PgTexts.gradientText(
                  context,
                  text: "₦800,000",
                  fontSize: 14,
                  gradient: PgColors.primaryGradient,
                ),
              ),
            ],
          ),
          // Members around the ring
          ...List.generate(membersCount, (index) {
            final angle = (index * 2 * pi / membersCount) - pi / 2;
            final radius = 110.0;
            final x = radius * cos(angle);
            final y = radius * sin(angle);
            final isCurrent = index == currentTurnIndex;

            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCurrent ? PgColors.black : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent ? PgColors.black : Colors.grey.shade200,
                    width: 2,
                  ),
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: PgColors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Center(
                  child: PgTexts.text600(
                    context,
                    text: "${index + 1}",
                    fontSize: 14,
                    color: isCurrent ? Colors.white : PgColors.black,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CircleRingPainter extends CustomPainter {
  final Color color;
  final Color highlightColor;
  final int membersCount;
  final int currentTurnIndex;

  CircleRingPainter({
    required this.color,
    required this.highlightColor,
    required this.membersCount,
    required this.currentTurnIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, paint);

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    final sweepAngle = 2 * pi / membersCount;
    final startAngle = (currentTurnIndex * sweepAngle) - pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle - (sweepAngle / 2),
      sweepAngle,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
