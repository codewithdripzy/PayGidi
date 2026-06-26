import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_snackbar.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/auth/data/models/auth_models.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class TrustedDevicesScreen extends StatefulWidget {
  const TrustedDevicesScreen({super.key});

  @override
  State<TrustedDevicesScreen> createState() => _TrustedDevicesScreenState();
}

class _TrustedDevicesScreenState extends State<TrustedDevicesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().fetchDevices();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _removeDevice(DeviceInfoModel device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text(
          'Are you sure you want to remove "${device.deviceDisplayName}"? '
          'This will log them out of your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final provider = context.read<AuthProvider>();
    final response = await provider.removeDevice(device.id);
    if (mounted) {
      if (response.isSuccess) {
        PgSnackBar.showSuccess(context, 'Device removed successfully');
      } else {
        PgSnackBar.showError(
          context,
          response.error ?? 'Failed to remove device',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AuthProvider>();
    final devices = provider.devices;
    final currentDevice = devices.where((d) => d.isCurrent).firstOrNull;
    final otherDevices = devices.where((d) => !d.isCurrent).toList();

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
            text: "Trusted Devices",
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black,
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDevices,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: PgColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: PgColors.secondary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.shield_tick_copy,
                              color: PgColors.secondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PgTexts.text400(
                              context,
                              text:
                                  "Devices you trust will have access to your account without additional verification.",
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (currentDevice != null) ...[
                      PgTexts.text500(
                        context,
                        text: "Current Device",
                        fontSize: 14,
                        color: (theme.textTheme.bodyMedium?.color ??
                                PgColors.black)
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      _buildDeviceItem(
                        context,
                        device: currentDevice,
                        isCurrent: true,
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (otherDevices.isNotEmpty) ...[
                      PgTexts.text500(
                        context,
                        text: "Other Devices",
                        fontSize: 14,
                        color: (theme.textTheme.bodyMedium?.color ??
                                PgColors.black)
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      ...otherDevices.map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDeviceItem(
                            context,
                            device: d,
                            isCurrent: false,
                            onRemove: () => _removeDevice(d),
                          ),
                        ),
                      ),
                    ] else if (currentDevice != null) ...[
                      _buildEmptyState(context),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PgColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.device_message_copy,
                size: 32,
                color: PgColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            PgTexts.text600(
              context,
              text: "No other trusted devices",
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color ?? PgColors.black,
            ),
            const SizedBox(height: 4),
            PgTexts.text400(
              context,
              text: "Other devices you log into will appear here.",
              fontSize: 13,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context, {
    required DeviceInfoModel device,
    bool isCurrent = false,
    VoidCallback? onRemove,
  }) {
    final theme = Theme.of(context);
    final icon = isCurrent
        ? (device.deviceType == 'desktop'
            ? Iconsax.monitor_copy
            : Iconsax.mobile_copy)
        : Iconsax.device_message_copy;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? PgColors.secondary.withValues(alpha: 0.3)
              : (theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrent
                  ? PgColors.secondary.withValues(alpha: 0.1)
                  : PgColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isCurrent ? PgColors.secondary : PgColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PgTexts.text500(
                        context,
                        text: device.deviceDisplayName,
                        fontSize: 15,
                        color:
                            theme.textTheme.bodyLarge?.color ?? PgColors.black,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: PgColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: PgTexts.text500(
                          context,
                          text: "Current",
                          fontSize: 10,
                          color: PgColors.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                PgTexts.text400(
                  context,
                  text: device.deviceOs.isNotEmpty
                      ? '${device.deviceOs} • Last active ${_formatDate(device.updatedAt)}'
                      : 'Last active ${_formatDate(device.updatedAt)}',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          if (!isCurrent && onRemove != null)
            IconButton(
              icon: const Icon(Iconsax.close_circle_copy, color: Colors.red),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Unknown';
    try {
      final dt = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return 'Unknown';
    }
  }
}
