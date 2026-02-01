/// App Confirm Dialog
///
/// Standard confirmation dialog for destructive actions.
/// Always use this for delete, logout, discard operations.
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
  });

  /// Show the dialog and return true if confirmed
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? context.l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: AppColors.error)
              : null,
          child: Text(confirmLabel ?? context.l10n.common_confirm),
        ),
      ],
    );
  }
}
