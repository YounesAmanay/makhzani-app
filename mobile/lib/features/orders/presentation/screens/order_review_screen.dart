/// Order Review Screen — Step 3 of 3
///
/// Read-only summary of the draft order.
/// Primary action: Send via WhatsApp.
/// Secondary: Generate PDF → opens in native viewer.
/// Tertiary: Save as Draft.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/order_draft_provider.dart';
import '../providers/orders_provider.dart';

class OrderReviewScreen extends ConsumerStatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  ConsumerState<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends ConsumerState<OrderReviewScreen> {
  final _notesController = TextEditingController();
  bool _isSendingWhatsApp = false;
  bool _isGeneratingPdf = false;
  bool _isSavingDraft = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(orderDraftProvider);
    if (draft.notes != null) _notesController.text = draft.notes!;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── WhatsApp ────────────────────────────────────────────────────────────────

  Future<void> _onSendWhatsApp() async {
    final draft = ref.read(orderDraftProvider);
    final phone =
        draft.supplierPhone?.replaceAll(RegExp(r'[^\d+]'), '') ?? '';

    final buffer = StringBuffer();
    buffer.writeln('Bonjour ${draft.supplierName},');
    buffer.writeln();
    buffer.writeln('Voici ma commande:');
    for (final item in draft.items) {
      buffer.writeln(
          '- ${item.productName} x${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.productUnit}');
    }
    buffer.writeln();
    buffer.writeln('Total: ${draft.totalValue.toStringAsFixed(2)} MAD');
    buffer.writeln();
    buffer.write('Merci');

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

    setState(() => _isSendingWhatsApp = true);

    // Sync notes to draft before creating order
    ref
        .read(orderDraftProvider.notifier)
        .setNotes(_notesController.text);

    // Open WhatsApp immediately — don't wait for order creation
    await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!mounted) return;

    // Create order in background after WhatsApp opens
    final success =
        await ref.read(orderDraftProvider.notifier).createOrder();

    if (!mounted) return;
    setState(() => _isSendingWhatsApp = false);

    if (success) {
      // Mark as sent via whatsapp
      final createdOrder = ref.read(orderDraftProvider).createdOrder;
      if (createdOrder != null) {
        final repository = ref.read(ordersRepositoryProvider);
        try {
          await repository.markSent(createdOrder.id, 'whatsapp');
        } catch (_) {
          // Non-fatal — order is already created
        }
      }

      ref.read(orderDraftProvider.notifier).reset();
      // Pop all three order screens back to the orders list
      if (mounted) {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == '/orders' || route.isFirst,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.orders_whatsappSent),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (!mounted) return;
      final errorMsg = ref.read(orderDraftProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? context.l10n.error_unknown),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── Generate PDF ─────────────────────────────────────────────────────────────

  Future<void> _onGeneratePdf() async {
    setState(() => _isGeneratingPdf = true);

    ref.read(orderDraftProvider.notifier).setNotes(_notesController.text);

    final success = await ref.read(orderDraftProvider.notifier).createOrder();

    if (!mounted) return;

    if (!success) {
      setState(() => _isGeneratingPdf = false);
      final errorMsg = ref.read(orderDraftProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? context.l10n.error_unknown),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Generate PDF for the created order
    final createdOrder = ref.read(orderDraftProvider).createdOrder;
    if (createdOrder == null) {
      setState(() => _isGeneratingPdf = false);
      return;
    }

    try {
      final repository = ref.read(ordersRepositoryProvider);
      final pdfUrl = await repository.generatePdf(createdOrder.id);

      ref.read(ordersProvider.notifier).refresh();
      ref.read(orderDraftProvider.notifier).reset();

      if (!mounted) return;
      setState(() => _isGeneratingPdf = false);

      final fullUrl = '${AppConstants.serverUrl}$pdfUrl';
      final uri = Uri.parse(fullUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!mounted) return;
      Navigator.of(context).popUntil(
        (route) => route.settings.name == '/orders' || route.isFirst,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_pdfGenerated),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGeneratingPdf = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_pdfError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── Save as Draft ─────────────────────────────────────────────────────────────

  Future<void> _onSaveAsDraft() async {
    setState(() => _isSavingDraft = true);

    ref.read(orderDraftProvider.notifier).setNotes(_notesController.text);

    final success = await ref.read(orderDraftProvider.notifier).createOrder();

    if (!mounted) return;
    setState(() => _isSavingDraft = false);

    if (success) {
      ref.read(orderDraftProvider.notifier).reset();
      Navigator.of(context).popUntil(
        (route) => route.settings.name == '/orders' || route.isFirst,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_draftSaved),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final errorMsg = ref.read(orderDraftProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? context.l10n.error_unknown),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(orderDraftProvider);
    final isAnyLoading =
        _isSendingWhatsApp || _isGeneratingPdf || _isSavingDraft;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.orders_reviewTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Supplier card
                  _buildSupplierCard(draft),
                  const SizedBox(height: AppDimensions.marginMedium),

                  // Items list
                  _buildItemsCard(draft),
                  const SizedBox(height: AppDimensions.marginMedium),

                  // Notes
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: context.l10n.orders_notesOptional,
                      hintText: context.l10n.orders_notesPlaceholder,
                    ),
                    maxLines: 3,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (v) =>
                        ref.read(orderDraftProvider.notifier).setNotes(v),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),

                  // Total card
                  _buildTotalCard(draft),
                ],
              ),
            ),
          ),

          // Action buttons
          _buildActionButtons(draft, isAnyLoading),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(OrderDraftState draft) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                draft.supplierName?.isNotEmpty == true
                    ? draft.supplierName![0].toUpperCase()
                    : '?',
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
                    draft.supplierName ?? '',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (draft.supplierPhone != null)
                    Text(
                      draft.supplierPhone!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(OrderDraftState draft) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.orders_items,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            ...draft.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(
                    bottom: AppDimensions.marginSmall),
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
                          Text(
                            '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.productUnit}'
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(OrderDraftState draft) {
    final theme = Theme.of(context);
    return Card(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.orders_totalValue,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${draft.totalValue.toStringAsFixed(2)} ${context.l10n.currency_mad}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderDraftState draft, bool isAnyLoading) {
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
          // PRIMARY: WhatsApp
          ElevatedButton.icon(
            onPressed: isAnyLoading ? null : _onSendWhatsApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium),
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

          const SizedBox(height: AppDimensions.marginSmall),

          // SECONDARY: Generate PDF
          OutlinedButton.icon(
            onPressed: isAnyLoading ? null : _onGeneratePdf,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium),
            ),
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(context.l10n.orders_generateAndOpen),
          ),

          const SizedBox(height: AppDimensions.marginXSmall),

          // TERTIARY: Save as draft
          TextButton(
            onPressed: isAnyLoading ? null : _onSaveAsDraft,
            child: _isSavingDraft
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.orders_saveAsDraft),
          ),
        ],
      ),
    );
  }
}
