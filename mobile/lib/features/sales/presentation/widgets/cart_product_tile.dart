import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/sale_cart_provider.dart';

class CartProductTile extends ConsumerWidget {
  final CartItem item;

  const CartProductTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.read(cartProvider.notifier);

    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        padding: const EdgeInsetsDirectional.only(end: AppDimensions.paddingLarge),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedDelete02,
          size: AppDimensions.iconMedium,
          color: AppColors.white,
        ),
      ),
      onDismissed: (_) => cart.removeItem(item.product.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingXSmall,
        ),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              child: Row(
              children: [
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.unitPrice.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.marginSmall),

                // Subtotal
                Text(
                  item.totalPrice.toStringAsFixed(2),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),

                // Qty stepper
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepButton(
                      icon: HugeIcons.strokeRoundedMinusSign,
                      onTap: () => cart.decrementQty(item.product.id),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity.toInt()}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StepButton(
                      icon: HugeIcons.strokeRoundedPlusSign,
                      onTap: () => cart.incrementQty(item.product.id),
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _StepButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Center(
          child: HugeIcon(
            icon: icon,
            size: 16,
            color: isPrimary ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
