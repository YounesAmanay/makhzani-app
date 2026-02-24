/// Order Review / Detail Screen
///
/// Unified detail view for any order — new or existing.
/// Always receives an [orderId] and loads via [orderDetailProvider].
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/url_helper.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/entities/order_status.dart';
import '../providers/order_detail_provider.dart';

class OrderReviewScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderReviewScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends ConsumerState<OrderReviewScreen> {
  bool _isSendingWhatsApp = false;
  bool _isGeneratingPdf = false;
  bool _isReceiving = false;

  // ── WhatsApp ──────────────────────────────────────────────────────────────

  Future<void> _onSendWhatsApp(OrderDetail order) async {
    final phone =
        order.supplier.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final l10n = context.l10n;
    final buffer = StringBuffer();
    buffer.writeln(l10n.orders_whatsappGreeting(order.supplier.name));
    buffer.writeln();
    buffer.writeln(l10n.orders_whatsappIntro(order.orderNumber));
    for (final item in order.items) {
      final qtyStr = item.quantity
          .toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1);
      buffer.writeln('- ${item.productName} x$qtyStr ${item.productUnit}');
    }
    buffer.writeln();
    buffer.writeln(l10n.orders_whatsappTotal(order.totalValue.toStringAsFixed(2)));
    buffer.writeln();
    buffer.write(l10n.orders_whatsappClosing);

    final encoded = Uri.encodeComponent(buffer.toString());
    final uri = Uri.parse('https://wa.me/$phone?text=$encoded');

    final canOpen = await canLaunchUrl(uri);
    if (!mounted) return;

    if (!canOpen) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.orders_noWhatsapp),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _isSendingWhatsApp = true);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;

    // Mark as sent in background — non-fatal
    ref
        .read(orderDetailProvider(widget.orderId).notifier)
        .markSent('whatsapp');

    setState(() => _isSendingWhatsApp = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.l10n.orders_whatsappSent),
      backgroundColor: AppColors.success,
    ));
  }

  // ── Share PDF ─────────────────────────────────────────────────────────────

  Future<void> _onSharePdf(OrderDetail order) async {
    setState(() => _isGeneratingPdf = true);

    // Step 1: generate PDF on server, get relative URL back
    final pdfUrl = await ref
        .read(orderDetailProvider(widget.orderId).notifier)
        .generateAndOpenPdf();

    if (!mounted) return;

    if (pdfUrl == null) {
      setState(() => _isGeneratingPdf = false);
      final errorMsg =
          ref.read(orderDetailProvider(widget.orderId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMsg ?? context.l10n.orders_pdfError),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    // Step 2: download to temp storage
    try {
      final fullUrl = UrlHelper.resolve(pdfUrl);
      final fileName = pdfUrl.split('/').last;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';

      await Dio().download(fullUrl, filePath);

      if (!mounted) return;
      setState(() => _isGeneratingPdf = false);

      // Step 3: open OS share sheet — user picks WhatsApp, email, etc.
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'application/pdf')],
          subject: order.orderNumber,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isGeneratingPdf = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.orders_pdfError),
        backgroundColor: AppColors.error,
      ));
    }
  }

  // ── Receive Order ─────────────────────────────────────────────────────────

  Future<void> _onReceiveOrder(OrderDetail order) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.orders_receiveConfirmTitle,
      message: context.l10n.orders_receiveConfirmMessage,
      confirmLabel: context.l10n.orders_receiveOrder,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isReceiving = true);

    final success = await ref
        .read(orderDetailProvider(widget.orderId).notifier)
        .receiveOrder();

    if (!mounted) return;
    setState(() => _isReceiving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        success
            ? context.l10n.orders_receiveSuccess
            : context.l10n.orders_receiveError,
      ),
      backgroundColor: success ? AppColors.success : AppColors.error,
    ));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _appCard({required Widget child}) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: child,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.order?.orderNumber ?? context.l10n.orders_orderDetails,
        ),
        actions: [
          if (state.order != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: context.l10n.common_refresh,
              onPressed: () => ref
                  .read(orderDetailProvider(widget.orderId).notifier)
                  .refresh(),
            ),
        ],
      ),
      body: switch (state.status) {
        OrderDetailStatus.loading => const AppLoadingScreen(),
        OrderDetailStatus.error => AppErrorState(
            message: state.errorMessage ?? context.l10n.error_unknown,
            onRetry: () => ref
                .read(orderDetailProvider(widget.orderId).notifier)
                .refresh(),
          ),
        OrderDetailStatus.loaded when state.order == null => AppErrorState(
            message: context.l10n.orders_orderNotFound,
            onRetry: () => ref
                .read(orderDetailProvider(widget.orderId).notifier)
                .refresh(),
          ),
        OrderDetailStatus.loaded => _buildContent(state.order!),
      },
    );
  }

  Widget _buildContent(OrderDetail order) {
    final isAnyLoading = _isSendingWhatsApp || _isGeneratingPdf || _isReceiving;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(order),
                const SizedBox(height: AppDimensions.marginMedium),
                _buildSupplierCard(order),
                const SizedBox(height: AppDimensions.marginMedium),
                _buildItemsAndTotalCard(order),
                if (order.notes != null) ...[
                  const SizedBox(height: AppDimensions.marginMedium),
                  _buildNotesCard(order.notes!),
                ],
              ],
            ),
          ),
        ),
        _buildActionBar(order, isAnyLoading),
      ],
    );
  }

  // ── Cards ─────────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(OrderDetail order) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) = _statusData(order.status);

    return _appCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall + 2, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginXSmall),
            Text(
              _formatDate(order.createdAt),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierCard(OrderDetail order) {
    final theme = Theme.of(context);
    final supplier = order.supplier;
    final initials =
        supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?';

    return _appCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
              child: Text(
                initials,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    supplier.phoneNumber,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  if (supplier.businessName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      supplier.businessName!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsAndTotalCard(OrderDetail order) {
    final theme = Theme.of(context);

    return _appCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              AppDimensions.paddingMedium,
              AppDimensions.paddingMedium,
              AppDimensions.marginSmall,
            ),
            child: Text(
              context.l10n.orders_items,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Divider(height: 1),

          ...order.items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == order.items.length - 1;
            final qtyStr = item.quantity
                .toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.marginSmall + 2,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$qtyStr ${item.productUnit}'
                              ' × ${item.unitPrice.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.total.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                      height: 1, indent: AppDimensions.paddingMedium),
              ],
            );
          }),

          const Divider(height: 1, thickness: 1),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.marginSmall + 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.orders_totalValue,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${order.totalValue.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    final theme = Theme.of(context);
    return _appCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.orders_notes,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(notes, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  // ── Action bar ────────────────────────────────────────────────────────────

  Widget _buildActionBar(OrderDetail order, bool isAnyLoading) {
    final isReceived = order.status.received;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingMedium,
                AppDimensions.marginSmall,
                AppDimensions.paddingMedium,
                AppDimensions.marginSmall,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Receive Order button — primary action when not yet received
                  if (!isReceived)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isAnyLoading
                            ? null
                            : () => _onReceiveOrder(order),
                        icon: _isReceiving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.inventory_2_outlined),
                        label: Text(context.l10n.orders_receiveOrder),
                      ),
                    ),
                  if (!isReceived)
                    const SizedBox(height: AppDimensions.marginSmall),

                  // WhatsApp button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          isAnyLoading ? null : () => _onSendWhatsApp(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium),
                        ),
                      ),
                      icon: _isSendingWhatsApp
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.chat_outlined),
                      label: Text(context.l10n.orders_sendViaWhatsApp),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),

                  // Share PDF button
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed:
                          isAnyLoading ? null : () => _onSharePdf(order),
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_outlined),
                      label: Text(context.l10n.orders_sharePdf),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return context.l10n.common_today;
    if (diff.inDays == 1) return context.l10n.common_yesterday;
    if (diff.inDays < 7) return context.l10n.common_daysAgo(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }

  (String, Color) _statusData(OrderStatus status) {
    if (status.received) {
      return (context.l10n.orders_statusReceived, AppColors.primary);
    }
    if (status.isSent) {
      return (context.l10n.orders_statusSent, AppColors.success);
    }
    if (status.isGenerated) {
      return (context.l10n.orders_statusGenerated, AppColors.info);
    }
    return (context.l10n.orders_statusDraft, AppColors.textSecondary);
  }
}
