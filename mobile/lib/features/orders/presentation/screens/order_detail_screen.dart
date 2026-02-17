/// Order Detail Screen
///
/// Displays full order details with line items and action buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_status.dart';
import '../providers/order_detail_provider.dart';
import '../widgets/mark_sent_sheet.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(state.order?.orderNumber ?? context.l10n.orders_orderDetails),
        actions: [
          if (state.order != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(orderDetailProvider(orderId).notifier).refresh();
              },
              tooltip: context.l10n.common_refresh,
            ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    OrderDetailState state,
  ) {
    switch (state.status) {
      case OrderDetailStatus.loading:
        return const AppLoadingScreen();
      case OrderDetailStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_unknown,
          onRetry: () {
            ref.read(orderDetailProvider(orderId).notifier).refresh();
          },
        );
      case OrderDetailStatus.loaded:
        if (state.order == null) {
          return AppErrorState(
            message: context.l10n.orders_orderNotFound,
            onRetry: () {
              ref.read(orderDetailProvider(orderId).notifier).refresh();
            },
          );
        }
        return _buildContent(context, ref, state);
    }
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    OrderDetailState state,
  ) {
    final order = state.order!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Section
                _buildStatusSection(context, order),
                const SizedBox(height: AppDimensions.marginMedium),

                // Supplier Card
                _buildSupplierCard(context, order),
                const SizedBox(height: AppDimensions.marginMedium),

                // Items List
                _buildItemsList(context, order),
                const SizedBox(height: AppDimensions.marginMedium),

                // Notes
                if (order.notes != null) ...[
                  _buildNotesCard(context, order),
                  const SizedBox(height: AppDimensions.marginMedium),
                ],

                // Summary
                _buildSummaryCard(context, order),
              ],
            ),
          ),
        ),

        // Action Buttons
        _buildActionButtons(context, ref, state),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.orders_orderNumber,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginXSmall),
                      Text(
                        order.orderNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, order.status),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              _formatDate(context, order.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    final (label, color) = _getStatusData(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  (String, Color) _getStatusData(BuildContext context, OrderStatus status) {
    if (status.isDraft) {
      return (context.l10n.orders_statusDraft, AppColors.textSecondary);
    }
    if (status.isGenerated) {
      return (context.l10n.orders_statusGenerated, AppColors.info);
    }
    if (status.isSent) {
      return (context.l10n.orders_statusSent, AppColors.success);
    }
    return (context.l10n.orders_statusDraft, AppColors.textSecondary);
  }

  Widget _buildSupplierCard(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);
    final supplier = order.supplier;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.orders_supplier,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              supplier.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.marginXSmall),
                Text(
                  supplier.phoneNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (supplier.businessName != null) ...[
              const SizedBox(height: AppDimensions.marginXSmall),
              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.marginXSmall),
                  Text(
                    supplier.businessName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.orders_items,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            ...order.items.map((item) => _buildItemRow(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, OrderItem item) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginXSmall),
                Text(
                  '${item.quantity.toStringAsFixed(2)} ${item.productUnit} × ${item.unitPrice.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.total.toStringAsFixed(2)} ${context.l10n.currency_mad}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.orders_notes,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              order.notes!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.orders_totalItems,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${order.totalItems}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.orders_totalQuantity,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  order.totalQuantity.toStringAsFixed(2),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: AppDimensions.marginLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.orders_totalValue,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.totalValue.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    OrderDetailState state,
  ) {
    final order = state.order!;
    final status = order.status;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Draft state: Generate PDF button
          if (status.isDraft)
            ElevatedButton.icon(
              onPressed: state.isGeneratingPdf
                  ? null
                  : () => _onGeneratePdf(context, ref),
              icon: state.isGeneratingPdf
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(context.l10n.orders_generatePdf),
            ),

          // Generated state: Download PDF + Mark as Sent
          if (status.isGenerated) ...[
            ElevatedButton.icon(
              onPressed: () => _onDownloadPdf(context, order.pdfUrl),
              icon: const Icon(Icons.download),
              label: Text(context.l10n.orders_downloadPdf),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            OutlinedButton.icon(
              onPressed: state.isMarkingSent
                  ? null
                  : () => _onMarkSent(context, ref),
              icon: state.isMarkingSent
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(context.l10n.orders_markAsSent),
            ),
          ],

          // Sent state: Download PDF only
          if (status.isSent)
            ElevatedButton.icon(
              onPressed: () => _onDownloadPdf(context, order.pdfUrl),
              icon: const Icon(Icons.download),
              label: Text(context.l10n.orders_downloadPdf),
            ),
        ],
      ),
    );
  }

  Future<void> _onGeneratePdf(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(orderDetailProvider(orderId).notifier).generatePdf();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_pdfGenerated),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final state = ref.read(orderDetailProvider(orderId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? context.l10n.error_unknown),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _onMarkSent(BuildContext context, WidgetRef ref) async {
    final sentVia = await MarkSentSheet.show(context: context);
    if (sentVia == null) return;

    final success = await ref.read(orderDetailProvider(orderId).notifier).markSent(sentVia);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_markedAsSent),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final state = ref.read(orderDetailProvider(orderId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? context.l10n.error_unknown),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _onDownloadPdf(BuildContext context, String? pdfUrl) async {
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_pdfNotAvailable),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final fullUrl = '${AppConstants.serverUrl}$pdfUrl';
    final uri = Uri.parse(fullUrl);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_pdfNotAvailable),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return context.l10n.common_today;
    } else if (difference.inDays == 1) {
      return context.l10n.common_yesterday;
    } else if (difference.inDays < 7) {
      return context.l10n.common_daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
