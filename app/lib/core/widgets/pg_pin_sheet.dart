import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PgPinSheet extends StatefulWidget {
  final String title;
  final String description;
  final Function(String pin)? onVerify;
  final Function(String error)? onError;
  final VoidCallback? onCompleted;

  const PgPinSheet({
    super.key,
    required this.title,
    required this.description,
    this.onVerify,
    this.onError,
    this.onCompleted,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String description,
    Function(String pin)? onVerify,
    Function(String error)? onError,
    VoidCallback? onCompleted,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PgPinSheet(
        title: title,
        description: description,
        onVerify: onVerify,
        onError: onError,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PgPinSheet> createState() => _PgPinSheetState();
}

class _PgPinSheetState extends State<PgPinSheet> {
  String _pin = "";

  void _onKeyTap(String key) {
    if (_pin.length < 4) {
      setState(() {
        _pin += key;
      });
      if (_pin.length == 4) {
        if (widget.onVerify != null) {
          widget.onVerify!(_pin);
        }
        if (widget.onCompleted != null) {
          widget.onCompleted!();
        }
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ??
            (theme.brightness == Brightness.dark
                ? const Color(0xFF111111)
                : Colors.white),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          PgTexts.text700(
            context,
            text: widget.title,
            fontSize: 24,
            color: theme.textTheme.titleLarge?.color ?? PgColors.black,
            fontFamily: PgFonts.stackSans,
          ),
          const SizedBox(height: 8),
          PgTexts.text400(
            context,
            text: widget.description,
            fontSize: 14,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isActive = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? PgColors.primary
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          const SizedBox(height: 48),
          _buildKeypad(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey("1"),
            _buildKey("2"),
            _buildKey("3"),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey("4"),
            _buildKey("5"),
            _buildKey("6"),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey("7"),
            _buildKey("8"),
            _buildKey("9"),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80),
            _buildKey("0"),
            _buildDeleteKey(),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _onKeyTap(label),
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: PgTexts.text600(
            context,
            text: label,
            fontSize: 24,
            color: theme.textTheme.titleLarge?.color ?? PgColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: _onDelete,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Iconsax.arrow_left_copy,
            size: 24,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
