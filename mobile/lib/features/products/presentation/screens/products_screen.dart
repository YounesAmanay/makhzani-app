/// Products Screen
///
/// Main products list with persistent search, filter chips, and sort.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/app_sort_sheet.dart';
import '../providers/products_provider.dart';
import '../widgets/product_list_tile.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productsProvider.notifier).loadProducts();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  String _sortLabel(BuildContext context, ProductSort sort) {
    switch (sort) {
      case ProductSort.nameAsc:
        return context.l10n.sort_nameAsc;
      case ProductSort.nameDesc:
        return context.l10n.sort_nameDesc;
      case ProductSort.stockLow:
        return context.l10n.sort_stockLow;
      case ProductSort.stockHigh:
        return context.l10n.sort_stockHigh;
      case ProductSort.priceLow:
        return context.l10n.sort_priceLow;
      case ProductSort.priceHigh:
        return context.l10n.sort_priceHigh;
      case ProductSort.newest:
        return context.l10n.sort_newest;
    }
  }

  void _showSortSheet() async {
    final currentSort = ref.read(productsProvider).sortBy;
    final result = await AppSortSheet.show<ProductSort>(
      context: context,
      title: context.l10n.common_sort,
      options: ProductSort.values
          .map((s) => SortOption(value: s, label: _sortLabel(context, s)))
          .toList(),
      currentValue: currentSort,
    );
    if (result != null) {
      ref.read(productsProvider.notifier).setSortBy(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.products),
      ),
      body: Column(
        children: [
          // Search bar
          AppSearchBar(
            hintText: context.l10n.products_searchHint,
            onSearch: (query) {
              ref.read(productsProvider.notifier).search(query);
            },
          ),

          // Filter chips row
          _buildFilterChips(state),

          // Results count
          if (state.status == ProductsStatus.loaded ||
              state.status == ProductsStatus.loadingMore)
            _buildResultsCount(state),

          // Body
          Expanded(child: _buildBody(state)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/products/create');
        },
        tooltip: context.l10n.products_add,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips(ProductsState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        children: [
          // Low stock filter
          AppFilterChip(
            label: context.l10n.products_lowStockOnly,
            icon: Icons.warning_amber_rounded,
            isActive: state.lowStockFilter,
            onTap: () {
              ref.read(productsProvider.notifier).toggleLowStockFilter();
            },
          ),
          const SizedBox(width: AppDimensions.marginSmall),

          // Sort chip
          AppFilterChip(
            label: _sortLabel(context, state.sortBy),
            icon: Icons.sort,
            isActive: state.sortBy != ProductSort.nameAsc,
            onTap: _showSortSheet,
            showClose: false,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCount(ProductsState state) {
    if (state.products.isEmpty) return const SizedBox.shrink();

    final total = state.pagination?.totalItems ?? state.products.length;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          context.l10n.products_resultsCount(total),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildBody(ProductsState state) {
    switch (state.status) {
      case ProductsStatus.initial:
      case ProductsStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ProductsStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppDimensions.marginMedium),
              Text(
                state.errorMessage ?? context.l10n.error_generic,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppDimensions.marginMedium),
              ElevatedButton(
                onPressed: () => ref.read(productsProvider.notifier).refresh(),
                child: Text(context.l10n.common_retry),
              ),
            ],
          ),
        );

      case ProductsStatus.loaded:
      case ProductsStatus.loadingMore:
        if (state.products.isEmpty) return _buildEmptyState(state);
        return _buildProductsList(state);
    }
  }

  Widget _buildEmptyState(ProductsState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.hasActiveFilters
                ? Icons.search_off
                : Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.iconSecondary,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            state.hasActiveFilters
                ? context.l10n.products_noResults
                : context.l10n.products_empty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            state.hasActiveFilters
                ? context.l10n.products_adjustFilters
                : context.l10n.products_emptyDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          if (!state.hasActiveFilters) ...[
            const SizedBox(height: AppDimensions.marginLarge),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/products/create');
                },
                icon: const Icon(Icons.add),
                label: Text(context.l10n.products_add),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductsState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(productsProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AppDimensions.paddingSmall,
          bottom: 80,
        ),
        itemCount: state.products.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = state.products[index];
          return ProductListTile(
            product: product,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/products/detail',
                arguments: product.id,
              );
            },
          );
        },
      ),
    );
  }
}
