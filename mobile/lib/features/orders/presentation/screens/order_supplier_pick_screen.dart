/// Order Supplier Pick Screen — Step 1 of 3
///
/// Searchable supplier list with recent suppliers shown first.
/// Selecting a supplier moves to the order build screen (Step 2).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../../suppliers/presentation/providers/suppliers_provider.dart';
import '../providers/order_draft_provider.dart';
import '../providers/orders_provider.dart';
import 'order_build_screen.dart';

class OrderSupplierPickScreen extends ConsumerStatefulWidget {
  const OrderSupplierPickScreen({super.key});

  @override
  ConsumerState<OrderSupplierPickScreen> createState() =>
      _OrderSupplierPickScreenState();
}

class _OrderSupplierPickScreenState
    extends ConsumerState<OrderSupplierPickScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(suppliersProvider.notifier).loadSuppliers();
      ref.read(ordersProvider.notifier).loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectSupplier(Supplier supplier) {
    ref.read(orderDraftProvider.notifier).setSupplier(supplier);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrderBuildScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliersState = ref.watch(suppliersProvider);
    final ordersState = ref.watch(ordersProvider);

    // Compute recent supplier IDs from last orders (top 3 unique)
    final recentIds = <String>[];
    for (final order in ordersState.orders) {
      if (!recentIds.contains(order.supplier.id)) {
        recentIds.add(order.supplier.id);
        if (recentIds.length >= 3) break;
      }
    }

    final allSuppliers = suppliersState.allSuppliers;

    // Client-side filter
    final filtered = _query.isEmpty
        ? allSuppliers
        : allSuppliers
            .where((s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) ||
                (s.businessName?.toLowerCase().contains(_query.toLowerCase()) ??
                    false))
            .toList();

    final recentSuppliers =
        filtered.where((s) => recentIds.contains(s.id)).toList();
    final otherSuppliers =
        filtered.where((s) => !recentIds.contains(s.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.orders_newOrderTitle),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.l10n.orders_selectSupplierHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: context.l10n.common_clear,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),

          // List
          Expanded(
            child: suppliersState.status == SuppliersStatus.loading
                ? const AppLoadingScreen()
                : allSuppliers.isEmpty
                    ? AppEmptyState(
                        icon: HugeIcons.strokeRoundedUserGroup,
                        title: context.l10n.orders_noSuppliersAvailable,
                        description: context.l10n.orders_addSupplierFirst,
                        actionLabel: context.l10n.suppliers_add,
                        onAction: () =>
                            Navigator.of(context).pushNamed('/suppliers/create'),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              context.l10n.suppliers_noResults,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView(
                            children: [
                              if (recentSuppliers.isNotEmpty && _query.isEmpty) ...[
                                _buildSectionHeader(
                                    context.l10n.orders_recentSuppliers),
                                ...recentSuppliers.map(
                                  (s) => _SupplierPickTile(
                                    supplier: s,
                                    onTap: () => _onSelectSupplier(s),
                                  ),
                                ),
                                _buildSectionHeader(
                                    context.l10n.orders_allSuppliers),
                              ],
                              ...otherSuppliers.map(
                                (s) => _SupplierPickTile(
                                  supplier: s,
                                  onTap: () => _onSelectSupplier(s),
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingSmall,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SupplierPickTile extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;

  const _SupplierPickTile({
    required this.supplier,
    required this.onTap,
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
          AppConstants.serverUrl + supplier.avatarUrl!,
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
