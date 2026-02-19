/// Suppliers Screen
///
/// Main suppliers list with persistent search bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../providers/suppliers_provider.dart';
import '../widgets/supplier_list_tile.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(suppliersProvider.notifier).loadSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.suppliers),
      ),
      body: Column(
        children: [
          // Search bar
          AppSearchBar(
            hintText: context.l10n.suppliers_searchHint,
            onSearch: (query) {
              ref.read(suppliersProvider.notifier).search(query);
            },
          ),

          // Body
          Expanded(child: _buildBody(state)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'suppliers_fab',
        onPressed: () {
          Navigator.of(context).pushNamed('/suppliers/create');
        },
        tooltip: context.l10n.suppliers_add,
        child: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(SuppliersState state) {
    switch (state.status) {
      case SuppliersStatus.initial:
      case SuppliersStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case SuppliersStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedAlertCircle, size: 48, color: AppColors.error),
                const SizedBox(height: AppDimensions.marginMedium),
                Text(
                  state.errorMessage ?? context.l10n.error_generic,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(suppliersProvider.notifier).refresh(),
                  child: Text(context.l10n.common_retry),
                ),
              ],
            ),
          ),
        );

      case SuppliersStatus.loaded:
        final suppliers = state.filteredSuppliers;
        if (suppliers.isEmpty) return _buildEmptyState(state);
        return _buildSuppliersList(suppliers);
    }
  }

  Widget _buildEmptyState(SuppliersState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: state.hasActiveFilters
                  ? HugeIcons.strokeRoundedSearchRemove
                  : HugeIcons.strokeRoundedUserMultiple,
              size: 64,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              state.hasActiveFilters
                  ? context.l10n.suppliers_noResults
                  : context.l10n.suppliers_empty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              state.hasActiveFilters
                  ? context.l10n.suppliers_adjustFilters
                  : context.l10n.suppliers_emptyDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!state.hasActiveFilters) ...[
              const SizedBox(height: AppDimensions.marginLarge),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/suppliers/create');
                },
                icon: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, size: 18, color: Colors.white),
                label: Text(context.l10n.suppliers_add),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliersList(List suppliers) {
    return RefreshIndicator(
      onRefresh: () => ref.read(suppliersProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AppDimensions.paddingSmall,
          bottom: 80,
        ),
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return SupplierListTile(
            supplier: supplier,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/suppliers/detail',
                arguments: supplier.id,
              );
            },
          );
        },
      ),
    );
  }
}
