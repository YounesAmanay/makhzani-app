/// Dashboard Screen
///
/// Main dashboard displaying merchant statistics and quick actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../shell/presentation/providers/navigation_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/low_stock_list.dart';
import '../widgets/recent_orders_list.dart';
import '../widgets/stats_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data on screen open
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  void _navigateToProducts({bool lowStockFilter = false}) {
    if (lowStockFilter) {
      ref.read(productsProvider.notifier).setLowStockFilter(true);
    }
    ref.read(bottomNavIndexProvider.notifier).state = 1;
  }

  void _navigateToSuppliers() {
    ref.read(bottomNavIndexProvider.notifier).state = 2;
  }

  void _navigateToOrders() {
    ref.read(bottomNavIndexProvider.notifier).state = 3;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(DashboardState state) {
    switch (state.status) {
      case DashboardStatus.initial:
      case DashboardStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case DashboardStatus.error:
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
                  ref.read(dashboardProvider.notifier).refresh();
                },
                child: Text(context.l10n.common_retry),
              ),
            ],
          ),
        );

      case DashboardStatus.loaded:
        return RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Grid
                _buildStatsGrid(state),

                const SizedBox(height: AppDimensions.marginLarge),

                // Low Stock Section
                _buildSectionHeader(context.l10n.dashboard_lowStock),
                const SizedBox(height: AppDimensions.marginSmall),
                LowStockList(
                  items: state.lowStockItems,
                  onSeeAll: () => _navigateToProducts(lowStockFilter: true),
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Recent Orders Section
                _buildSectionHeader(context.l10n.dashboard_recentOrders),
                const SizedBox(height: AppDimensions.marginSmall),
                RecentOrdersList(
                  orders: state.recentOrders,
                  onSeeAll: _navigateToOrders,
                ),

                const SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildStatsGrid(DashboardState state) {
    final stats = state.stats;
    if (stats == null) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimensions.marginSmall,
      crossAxisSpacing: AppDimensions.marginSmall,
      childAspectRatio: 1.3,
      children: [
        StatsCard(
          title: context.l10n.nav_products,
          value: stats.totalProducts.toString(),
          icon: Icons.inventory_2_outlined,
          iconColor: AppColors.primary,
          onTap: _navigateToProducts,
        ),
        StatsCard(
          title: context.l10n.dashboard_lowStock,
          value: stats.lowStockProducts.toString(),
          icon: Icons.warning_amber_outlined,
          iconColor: stats.lowStockProducts > 0 ? AppColors.warning : AppColors.success,
          onTap: () => _navigateToProducts(lowStockFilter: true),
        ),
        StatsCard(
          title: context.l10n.nav_suppliers,
          value: stats.totalSuppliers.toString(),
          icon: Icons.people_outline,
          iconColor: AppColors.info,
          onTap: _navigateToSuppliers,
        ),
        StatsCard(
          title: context.l10n.nav_orders,
          value: stats.totalOrders.toString(),
          icon: Icons.receipt_long_outlined,
          iconColor: AppColors.primary,
          onTap: _navigateToOrders,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
