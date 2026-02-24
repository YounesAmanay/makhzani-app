/// Supplier List Tile Widget
///
/// Displays a single supplier in a list with avatar, phone and city info.
library;

import 'package:flutter/material.dart';

import '../../../../core/utils/url_helper.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/supplier.dart';

class SupplierListTile extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onTap;

  const SupplierListTile({
    super.key,
    required this.supplier,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingXSmall,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(child: _buildTextContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (supplier.avatarUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(
          UrlHelper.resolve(supplier.avatarUrl!),
        ),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                supplier.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (supplier.city != null) ...[
              const SizedBox(width: AppDimensions.marginSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Text(
                  supplier.city!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.marginXSmall),
        Text(
          supplier.businessName?.isNotEmpty == true
              ? supplier.businessName!
              : supplier.phoneNumber,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Row(
          children: [
            if (supplier.businessName?.isNotEmpty == true) ...[
              Text(
                supplier.phoneNumber,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              if (supplier.relationship != null)
                Text(
                  ' • ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
            if (supplier.relationship != null)
              Text(
                context.l10n.suppliers_totalOrders(
                  supplier.relationship!.totalOrders,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
