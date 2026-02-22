/// Dashboard Screen
///
/// Main dashboard displaying merchant statistics and quick actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../sales/presentation/providers/sales_provider.dart';
import '../../../shell/presentation/providers/navigation_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/low_stock_list.dart';
import '../widgets/recent_orders_list.dart';
import '../widgets/sales_chart_widget.dart';
import '../widgets/top_selling_list.dart';
import '../../../../shared/widgets/stats_card.dart';
import '../../../products/presentation/screens/product_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).loadDashboard();
      ref.read(saleSummaryProvider.notifier).load();
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
        return const AppLoadingScreen();

      case DashboardStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_generic,
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
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

                // Revenue cards
                _buildRevenueRow(),

                const SizedBox(height: AppDimensions.marginLarge),

                // 7-day Sales Chart
                _buildSectionHeader(context.l10n.dashboard_salesChart),
                const SizedBox(height: AppDimensions.marginSmall),
                SalesChartWidget(data: state.chartData),

                const SizedBox(height: AppDimensions.marginLarge),

                // Top Selling Products
                _buildSectionHeader(context.l10n.dashboard_topSelling),
                const SizedBox(height: AppDimensions.marginSmall),
                TopSellingList(
                  items: state.topSelling,
                  onTap: (productId) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: productId),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Low Stock Section
                _buildSectionHeader(
                  context.l10n.dashboard_lowStock,
                  onSeeAll: () => _navigateToProducts(lowStockFilter: true),
                ),
                const SizedBox(height: AppDimensions.marginSmall),
                LowStockList(
                  items: state.lowStockItems,
                  onSeeAll: () => _navigateToProducts(lowStockFilter: true),
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Recent Orders Section
                _buildSectionHeader(
                  context.l10n.dashboard_recentOrders,
                  onSeeAll: _navigateToOrders,
                ),
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: context.l10n.nav_products,
                value: stats.totalProducts.toString(),
                icon: HugeIcons.strokeRoundedPackage,
                iconColor: AppColors.primary,
                onTap: _navigateToProducts,
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: StatsCard(
                title: context.l10n.dashboard_lowStock,
                value: stats.lowStockProducts.toString(),
                icon: HugeIcons.strokeRoundedAlertDiamond,
                iconColor: stats.lowStockProducts > 0 ? AppColors.warning : AppColors.success,
                onTap: () => _navigateToProducts(lowStockFilter: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: context.l10n.nav_suppliers,
                value: stats.totalSuppliers.toString(),
                icon: HugeIcons.strokeRoundedUserMultiple,
                iconColor: AppColors.info,
                onTap: _navigateToSuppliers,
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: StatsCard(
                title: context.l10n.nav_orders,
                value: stats.totalOrders.toString(),
                icon: HugeIcons.strokeRoundedInvoice02,
                iconColor: AppColors.primary,
                onTap: _navigateToOrders,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueRow() {
    final summaryState = ref.watch(saleSummaryProvider);
    final summary = summaryState.summary;
    final today = summary?.today.amount ?? 0.0;
    final month = summary?.thisMonth.amount ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: context.l10n.dashboard_todayRevenue,
            value: '${today.toStringAsFixed(0)} ${context.l10n.currency_mad}',
            icon: HugeIcons.strokeRoundedSaleTag01,
            iconColor: AppColors.success,
            onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
          ),
        ),
        const SizedBox(width: AppDimensions.marginSmall),
        Expanded(
          child: StatsCard(
            title: context.l10n.dashboard_monthRevenue,
            value: '${month.toStringAsFixed(0)} ${context.l10n.currency_mad}',
            icon: HugeIcons.strokeRoundedChart,
            iconColor: AppColors.info,
            onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(context.l10n.common_seeAll),
          ),
      ],
    );
  }
}
