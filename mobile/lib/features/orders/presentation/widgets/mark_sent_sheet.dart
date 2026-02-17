/// Mark Sent Bottom Sheet
///
/// Bottom sheet for selecting how the order was sent.
library;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class MarkSentSheet extends StatelessWidget {
  final Function(String) onSelect;

  const MarkSentSheet({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.orders_markSentTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            context.l10n.orders_markSentDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // WhatsApp
          _buildOption(
            context,
            icon: Icons.chat,
            label: context.l10n.orders_sentViaWhatsApp,
            color: AppColors.success,
            onTap: () => onSelect('whatsapp'),
          ),
          const SizedBox(height: AppDimensions.marginSmall),

          // Email
          _buildOption(
            context,
            icon: Icons.email_outlined,
            label: context.l10n.orders_sentViaEmail,
            color: AppColors.info,
            onTap: () => onSelect('email'),
          ),
          const SizedBox(height: AppDimensions.marginSmall),

          // Phone
          _buildOption(
            context,
            icon: Icons.phone_outlined,
            label: context.l10n.orders_sentViaPhone,
            color: AppColors.success,
            onTap: () => onSelect('phone'),
          ),
          const SizedBox(height: AppDimensions.marginSmall),

          // In Person
          _buildOption(
            context,
            icon: Icons.person_outlined,
            label: context.l10n.orders_sentViaInPerson,
            color: AppColors.textSecondary,
            onTap: () => onSelect('in_person'),
          ),

          const SizedBox(height: AppDimensions.marginMedium),

          // Cancel button
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.common_cancel),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }

  static Future<String?> show({
    required BuildContext context,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => MarkSentSheet(
        onSelect: (sentVia) => Navigator.of(context).pop(sentVia),
      ),
    );
  }
}
