/// Order Detail Screen
///
/// WhatsApp-first layout: primary action is sharing via WhatsApp,
/// secondary is generate PDF → opens in native viewer in one tap.
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

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(state.order?.orderNumber ?? context.l10n.orders_orderDetails),
        actions: [
          if (state.order != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(orderDetailProvider(widget.orderId).notifier).refresh();
              },
              tooltip: context.l10n.common_refresh,
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(OrderDetailState state) {
    switch (state.status) {
      case OrderDetailStatus.loading:
        return const AppLoadingScreen();
      case OrderDetailStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_unknown,
          onRetry: () {
            ref.read(orderDetailProvider(widget.orderId).notifier).refresh();
          },
        );
      case OrderDetailStatus.loaded:
        if (state.order == null) {
          return AppErrorState(
            message: context.l10n.orders_orderNotFound,
            onRetry: () {
              ref.read(orderDetailProvider(widget.orderId).notifier).refresh();
            },
          );
        }
        return _buildContent(state);
    }
  }

  Widget _buildContent(OrderDetailState state) {
    final order = state.order!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusSection(order),
                const SizedBox(height: AppDimensions.marginMedium),
                _buildSupplierCard(order),
                const SizedBox(height: AppDimensions.marginMedium),
                _buildItemsList(order),
                const SizedBox(height: AppDimensions.marginMedium),
                if (order.notes != null) ...[
                  _buildNotesCard(order),
                  const SizedBox(height: AppDimensions.marginMedium),
                ],
                _buildSummaryCard(order),
              ],
            ),
          ),
        ),
        _buildActionButtons(state),
      ],
    );
  }

  Widget _buildStatusSection(OrderDetail order) {
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
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              _formatDate(order.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final (label, color) = _getStatusData(status);

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

  (String, Color) _getStatusData(OrderStatus status) {
    if (status.isSent) {
      return (context.l10n.orders_statusSent, AppColors.success);
    }
    if (status.isGenerated) {
      return (context.l10n.orders_statusGenerated, AppColors.info);
    }
    return (context.l10n.orders_statusDraft, AppColors.textSecondary);
  }

  Widget _buildSupplierCard(OrderDetail order) {
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
                Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
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
                  Icon(Icons.business_outlined, size: 16, color: AppColors.textSecondary),
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

  Widget _buildItemsList(OrderDetail order) {
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
            ...order.items.map((item) => _buildItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
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

  Widget _buildNotesCard(OrderDetail order) {
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
            Text(order.notes!, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(OrderDetail order) {
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

  Widget _buildActionButtons(OrderDetailState state) {
    final order = state.order!;

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
          // PRIMARY: WhatsApp (always shown)
          ElevatedButton.icon(
            onPressed: state.isMarkingSent ? null : () => _onSendWhatsApp(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
            ),
            icon: state.isMarkingSent
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.chat_outlined),
            label: Text(context.l10n.orders_sendViaWhatsApp),
          ),

          const SizedBox(height: AppDimensions.marginSmall),

          // SECONDARY: Generate PDF → open in viewer
          OutlinedButton.icon(
            onPressed: state.isGeneratingPdf ? null : () => _onGenerateAndOpenPdf(order),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
            ),
            icon: state.isGeneratingPdf
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(context.l10n.orders_generateAndOpen),
          ),
        ],
      ),
    );
  }

  Future<void> _onSendWhatsApp(OrderDetail order) async {
    final phone = order.supplier.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Compose WhatsApp message
    final buffer = StringBuffer();
    buffer.writeln('*${order.orderNumber}*');
    buffer.writeln();
    for (final item in order.items) {
      buffer.writeln(
        '• ${item.productName}: ${item.quantity.toStringAsFixed(2)} ${item.productUnit}',
      );
    }
    buffer.writeln();
    buffer.writeln('*Total: ${order.totalValue.toStringAsFixed(2)} MAD*');

    final encoded = Uri.encodeComponent(buffer.toString());
    final uri = Uri.parse('https://wa.me/$phone?text=$encoded');

    final canOpen = await canLaunchUrl(uri);
    if (!mounted) return;

    if (!canOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_noWhatsapp),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Launch WhatsApp — fire-and-forget; then mark as sent in background
    await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!mounted) return;

    // Mark as sent in background (no await — user is already in WhatsApp)
    ref
        .read(orderDetailProvider(widget.orderId).notifier)
        .markSent('whatsapp')
        .then((_) {
      // Silently refresh — no SnackBar needed, user is in WhatsApp
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.orders_whatsappSent),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _onGenerateAndOpenPdf(OrderDetail order) async {
    final pdfUrl = await ref
        .read(orderDetailProvider(widget.orderId).notifier)
        .generateAndOpenPdf();

    if (!mounted) return;

    if (pdfUrl == null) {
      final errorMessage =
          ref.read(orderDetailProvider(widget.orderId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? context.l10n.orders_pdfError),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_pdfError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Also mark as sent via pdf in background
    if (!mounted) return;
    ref.read(orderDetailProvider(widget.orderId).notifier).markSent('pdf');
  }

  String _formatDate(DateTime date) {
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
