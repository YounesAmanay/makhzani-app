/// App Confirm Dialog
///
/// Standard confirmation dialog for destructive actions.
/// Always use this for delete, logout, discard operations.
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/localization/l10n_extension.dart';

class AppConfirmDialog extends StatelessWidget {
  /// Dialog title (use l10n)
  final String title;

  /// Dialog message (use l10n)
  final String message;

  /// Confirm button text (use l10n, defaults to common_confirm)
  final String? confirmLabel;

  /// Cancel button text (use l10n, defaults to common_cancel)
  final String? cancelLabel;

  /// Is this a destructive action (changes confirm button to red)
  final bool isDestructive;

  /// Optional hugeicon to show above title
  final List<List<dynamic>>? icon;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    this.icon,
  });

  /// Show the dialog and return true if confirmed
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    List<List<dynamic>>? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isDestructive ? AppColors.error : AppColors.primary;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          if (icon != null) ...[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon!,
                  size: 28,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
          ],
          // Title
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          // Message
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            // Cancel button
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Text(cancelLabel ?? context.l10n.common_cancel),
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            // Confirm button
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isDestructive ? AppColors.error : null,
                ),
                child: Text(confirmLabel ?? context.l10n.common_confirm),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
