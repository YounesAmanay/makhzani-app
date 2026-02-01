/// Products Screen
///
/// Main products list with search, filter, and infinite scroll.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/products_provider.dart';
import '../widgets/product_list_tile.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _showSearch = false;

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
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch ? _buildSearchField() : Text(context.l10n.products),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            tooltip: context.l10n.common_search,
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(productsProvider.notifier).search(null);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              state.lowStockFilter
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: state.lowStockFilter ? AppColors.warning : null,
            ),
            tooltip: context.l10n.products_lowStockOnly,
            onPressed: () {
              ref.read(productsProvider.notifier).toggleLowStockFilter();
            },
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/products/create');
        },
        tooltip: context.l10n.products_add,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: context.l10n.products_searchHint,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: (value) {
        ref.read(productsProvider.notifier).search(value);
      },
      onChanged: (value) {
        // Debounced search
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_searchController.text == value) {
            ref.read(productsProvider.notifier).search(value);
          }
        });
      },
    );
  }

  Widget _buildBody(ProductsState state) {
    switch (state.status) {
      case ProductsStatus.initial:
      case ProductsStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case ProductsStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? context.l10n.error_generic,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(productsProvider.notifier).refresh();
                },
                child: Text(context.l10n.common_retry),
              ),
            ],
          ),
        );

      case ProductsStatus.loaded:
      case ProductsStatus.loadingMore:
        if (state.products.isEmpty) {
          return _buildEmptyState();
        }
        return _buildProductsList(state);
    }
  }

  Widget _buildEmptyState() {
    final state = ref.read(productsProvider);
    final hasFilters = state.search != null || state.lowStockFilter;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.iconSecondary,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            hasFilters ? context.l10n.products_noResults : context.l10n.products_empty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            hasFilters
                ? context.l10n.products_adjustFilters
                : context.l10n.products_emptyDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          if (!hasFilters) ...[
            const SizedBox(height: AppDimensions.marginLarge),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/products/create');
              },
              icon: const Icon(Icons.add),
              label: Text(context.l10n.products_add),
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
          bottom: 80, // Space for FAB
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
