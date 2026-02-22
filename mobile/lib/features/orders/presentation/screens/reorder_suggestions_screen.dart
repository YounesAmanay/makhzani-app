/// Reorder Suggestions Screen
///
/// Shows low-stock products grouped by their last-ordered supplier.
/// Each group has a "Create Order" button that pre-fills the order draft.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../domain/entities/reorder_suggestion.dart';
import '../providers/order_draft_provider.dart';
import '../providers/reorder_suggestions_provider.dart';
import 'order_screen.dart';

class ReorderSuggestionsScreen extends ConsumerStatefulWidget {
  const ReorderSuggestionsScreen({super.key});

  @override
  ConsumerState<ReorderSuggestionsScreen> createState() =>
      _ReorderSuggestionsScreenState();
}

class _ReorderSuggestionsScreenState
    extends ConsumerState<ReorderSuggestionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(reorderSuggestionsProvider.notifier).load(),
    );
  }

  void _createOrder(ReorderSuggestion suggestion) {
    final supplier = Supplier(
      id: suggestion.supplier.id,
      name: suggestion.supplier.name,
      businessName: suggestion.supplier.businessName,
      phoneNumber: suggestion.supplier.phoneNumber ?? '',
    );

    final items = suggestion.products
        .map(
          (p) => OrderDraftItem(
            productId: p.id,
            productName: p.name,
            productUnit: p.unit,
            quantity: p.shortage.toDouble(),
            unitPrice: p.lastOrderPrice ?? 0.0,
          ),
        )
        .toList();

    ref.read(orderDraftProvider.notifier).reset();
    ref.read(orderDraftProvider.notifier).setSupplier(supplier);
    ref.read(orderDraftProvider.notifier).setItems(items);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reorderSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.orders_reorderSuggestions),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ReorderSuggestionsState state) {
    switch (state.status) {
      case ReorderSuggestionsStatus.initial:
      case ReorderSuggestionsStatus.loading:
        return const AppLoadingScreen();

      case ReorderSuggestionsStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_generic,
          onRetry: () => ref.read(reorderSuggestionsProvider.notifier).load(),
        );

      case ReorderSuggestionsStatus.loaded:
        final result = state.result!;
        if (result.isEmpty) {
          return AppEmptyState(
            icon: HugeIcons.strokeRoundedPackage,
            title: context.l10n.orders_allStocked,
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(reorderSuggestionsProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            children: [
              ...result.suggestions.map(
                (suggestion) => _SupplierGroupCard(
                  suggestion: suggestion,
                  onCreateOrder: () => _createOrder(suggestion),
                ),
              ),
            ],
          ),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Supplier group card
// ---------------------------------------------------------------------------

class _SupplierGroupCard extends StatelessWidget {
  final ReorderSuggestion suggestion;
  final VoidCallback onCreateOrder;

  const _SupplierGroupCard({
    required this.suggestion,
    required this.onCreateOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = suggestion.products.length;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier name + product count subtitle
            Text(
              suggestion.supplier.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count == 1
                  ? context.l10n.orders_reorderProductCount1
                  : context.l10n.orders_reorderProductCount(count),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppDimensions.marginSmall),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: AppDimensions.marginSmall),

            // Product rows
            ...suggestion.products.map(
              (product) => _ProductRow(product: product),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Create order button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightMedium,
              child: ElevatedButton.icon(
                onPressed: onCreateOrder,
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                label: Text(context.l10n.orders_createOrder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product row — two lines: name + labelled stock info
// ---------------------------------------------------------------------------

class _ProductRow extends StatelessWidget {
  final ReorderSuggestionProduct product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = product.currentStock <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock status dot
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOutOfStock ? AppColors.error : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.marginSmall),

          // Name + stock info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.orders_stockInfo(
                    product.currentStock,
                    product.unit,
                    product.shortage,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
