/// Products Report Screen
///
/// Best sellers, dead stock, and sales by category.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/widgets/app_error_state.dart';
import '../../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/products_report.dart';
import '../providers/reports_provider.dart';

class ProductsReportScreen extends ConsumerStatefulWidget {
  const ProductsReportScreen({super.key});

  @override
  ConsumerState<ProductsReportScreen> createState() => _ProductsReportScreenState();
}

class _ProductsReportScreenState extends ConsumerState<ProductsReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(productsReportProvider);
      if (state.status == ReportStatus.initial) {
        ref.read(productsReportProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsReportProvider);

    switch (state.status) {
      case ReportStatus.initial:
      case ReportStatus.loading:
        return const AppLoadingScreen();
      case ReportStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_generic,
          onRetry: () => ref.read(productsReportProvider.notifier).refresh(),
        );
      case ReportStatus.loaded:
        return RefreshIndicator(
          onRefresh: () => ref.read(productsReportProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBestSellers(state.report!.bestSellers),
                const SizedBox(height: AppDimensions.marginLarge),
                _buildDeadStock(state.report!.deadStock),
                const SizedBox(height: AppDimensions.marginLarge),
                _buildByCategory(state.report!.byCategory),
                const SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildBestSellers(List<BestSeller> sellers) {
    if (sellers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.l10n.reports_bestSellers),
        const SizedBox(height: AppDimensions.marginSmall),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sellers.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppDimensions.paddingMedium,
            ),
            itemBuilder: (context, index) {
              final s = sellers[index];
              return _BestSellerTile(seller: s, rank: index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeadStock(List<DeadStockItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionTitle(context.l10n.reports_deadStock)),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.warningBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              ),
              child: Text(
                '${items.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppDimensions.paddingMedium,
            ),
            itemBuilder: (context, index) {
              return _DeadStockTile(item: items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildByCategory(List<CategoryRevenue> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.l10n.reports_byCategory),
        const SizedBox(height: AppDimensions.marginSmall),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppDimensions.paddingMedium,
            ),
            itemBuilder: (context, index) {
              return _CategoryRevenueTile(category: categories[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _BestSellerTile extends StatelessWidget {
  final BestSeller seller;
  final int rank;

  const _BestSellerTile({required this.seller, required this.rank});

  @override
  Widget build(BuildContext context) {
    final mad = context.l10n.reports_currency;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall + 2,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AppColors.warning.withAlpha(30)
                  : AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: rank == 1 ? AppColors.warning : AppColors.textTertiary,
                    ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.marginSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${seller.quantitySold.toStringAsFixed(0)} ${context.l10n.reports_quantitySold}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${seller.revenue.toStringAsFixed(0)} $mad',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (seller.marginPct > 0)
                Text(
                  '${seller.marginPct.toStringAsFixed(0)}% ${context.l10n.reports_margin}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeadStockTile extends StatelessWidget {
  final DeadStockItem item;

  const _DeadStockTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final daysLabel = item.daysSinceLastSale != null
        ? context.l10n.reports_daysSinceLastSale(item.daysSinceLastSale!)
        : context.l10n.reports_neverSold;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  daysLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: item.daysSinceLastSale == null
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.currentStock} ${item.unit}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${item.stockValue.toStringAsFixed(0)} ${context.l10n.reports_currency}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRevenueTile extends StatelessWidget {
  final CategoryRevenue category;

  const _CategoryRevenueTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  context.l10n.reports_products_count(category.productCount),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${category.revenue.toStringAsFixed(0)} ${context.l10n.reports_currency}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
