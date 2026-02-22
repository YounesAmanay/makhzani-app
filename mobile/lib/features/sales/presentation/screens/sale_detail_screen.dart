import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/sale.dart';
import '../providers/sales_provider.dart';

class SaleDetailScreen extends ConsumerWidget {
  final Sale sale;

  const SaleDetailScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.l10n.sales_saleNumber(sale.saleNumber)),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedShare01,
              size: AppDimensions.iconMedium,
              color: AppColors.primary,
            ),
            tooltip: context.l10n.sales_shareReceipt,
            onPressed: () => _shareReceipt(context),
          ),
          if (!sale.isCancelled)
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                size: AppDimensions.iconMedium,
                color: AppColors.error,
              ),
              tooltip: context.l10n.sales_cancelTitle,
              onPressed: () => _confirmCancel(context, ref),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          // Summary card
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                children: [
                  _InfoRow(
                    label: context.l10n.sales_saleNumber(''),
                    value: sale.saleNumber,
                  ),
                  const Divider(height: AppDimensions.marginMedium),
                  _InfoRow(
                    label: context.l10n.sales_items(sale.totalItems),
                    value: '${sale.totalItems}',
                  ),
                  const Divider(height: AppDimensions.marginMedium),
                  _InfoRow(
                    label: context.l10n.sales_total,
                    value: '${sale.totalAmount.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                    valueStyle: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                    const Divider(height: AppDimensions.marginMedium),
                    _InfoRow(label: context.l10n.sales_notes, value: sale.notes!),
                  ],
                ],
              ),
            ),
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          // Items
          Text(
            context.l10n.sales_items(sale.items.length),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          ...sale.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingXSmall),
                child: Material(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productNameSnapshot,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.productUnitSnapshot} × ${item.unitPrice.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.totalPrice.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _shareReceipt(BuildContext context) {
    final date = '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}';
    final text = context.l10n.sales_receiptText(
      sale.saleNumber,
      date,
      sale.totalAmount.toStringAsFixed(2),
    );
    SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.sales_cancelTitle,
      message: context.l10n.sales_cancelMessage,
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(salesProvider.notifier).cancelSale(sale.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.sales_cancelSuccess)),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        Text(value, style: valueStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
