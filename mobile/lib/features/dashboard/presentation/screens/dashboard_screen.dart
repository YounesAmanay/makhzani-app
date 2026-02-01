/// Dashboard Screen
///
/// Main dashboard displaying merchant statistics and quick actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/low_stock_list.dart';
import '../widgets/recent_orders_list.dart';

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

  Future<void> _onLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onLogout,
          ),
        ],
      ),
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
                state.errorMessage ?? 'Something went wrong',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(dashboardProvider.notifier).refresh();
                },
                child: const Text('Retry'),
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
                _buildSectionHeader('Low Stock Items'),
                const SizedBox(height: AppDimensions.marginSmall),
                LowStockList(
                  items: state.lowStockItems,
                  onSeeAll: () {
                    // TODO: Navigate to products with low stock filter
                  },
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Recent Orders Section
                _buildSectionHeader('Recent Orders'),
                const SizedBox(height: AppDimensions.marginSmall),
                RecentOrdersList(
                  orders: state.recentOrders,
                  onSeeAll: () {
                    // TODO: Navigate to orders
                  },
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
      mainAxisSpacing: AppDimensions.marginMedium,
      crossAxisSpacing: AppDimensions.marginMedium,
      childAspectRatio: 1.5,
      children: [
        StatsCard(
          title: 'Products',
          value: stats.totalProducts.toString(),
          icon: Icons.inventory_2_outlined,
          iconColor: AppColors.primary,
          onTap: () {
            // TODO: Navigate to products
          },
        ),
        StatsCard(
          title: 'Low Stock',
          value: stats.lowStockProducts.toString(),
          icon: Icons.warning_amber_outlined,
          iconColor: stats.lowStockProducts > 0 ? AppColors.warning : AppColors.success,
          onTap: () {
            // TODO: Navigate to low stock products
          },
        ),
        StatsCard(
          title: 'Suppliers',
          value: stats.totalSuppliers.toString(),
          icon: Icons.people_outline,
          iconColor: AppColors.info,
          onTap: () {
            // TODO: Navigate to suppliers
          },
        ),
        StatsCard(
          title: 'Orders',
          value: stats.totalOrders.toString(),
          icon: Icons.receipt_long_outlined,
          iconColor: AppColors.primary,
          onTap: () {
            // TODO: Navigate to orders
          },
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
