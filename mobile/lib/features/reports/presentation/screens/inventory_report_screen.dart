/// Inventory Report Screen
///
/// Stock health overview: value, health score, by category.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/widgets/app_error_state.dart';
import '../../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/inventory_report.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_summary_card.dart';

class InventoryReportScreen extends ConsumerStatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  ConsumerState<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends ConsumerState<InventoryReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(inventoryReportProvider);
      if (state.status == ReportStatus.initial) {
        ref.read(inventoryReportProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryReportProvider);

    switch (state.status) {
      case ReportStatus.initial:
      case ReportStatus.loading:
        return const AppLoadingScreen();
      case ReportStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_generic,
          onRetry: () => ref.read(inventoryReportProvider.notifier).refresh(),
        );
      case ReportStatus.loaded:
        return RefreshIndicator(
          onRefresh: () => ref.read(inventoryReportProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHealthCard(state.report!),
                const SizedBox(height: AppDimensions.marginMedium),
                _buildStockSummary(state.report!),
                const SizedBox(height: AppDimensions.marginLarge),
                _buildByCategory(state.report!.byCategory),
                const SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildHealthCard(InventoryReport report) {
    final score = report.healthScore;
    final color = score >= 80
        ? AppColors.success
        : score >= 50
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Health score circle
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 7,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(
                  '$score%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.reports_healthScore,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.totalStockValue.toStringAsFixed(0)} ${context.l10n.reports_currency}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                ),
                Text(
                  context.l10n.reports_stockValue,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummary(InventoryReport report) {
    final mad = context.l10n.reports_currency;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: context.l10n.reports_healthyStock,
                value: report.healthyStock.toString(),
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                valueColor: AppColors.success,
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: ReportSummaryCard(
                title: context.l10n.reports_lowStock,
                value: report.lowStock.toString(),
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.warning,
                valueColor: report.lowStock > 0 ? AppColors.warning : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: context.l10n.reports_zeroStock,
                value: report.zeroStock.toString(),
                icon: Icons.remove_circle_outline,
                iconColor: AppColors.error,
                valueColor: report.zeroStock > 0 ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: ReportSummaryCard(
                title: context.l10n.reports_reorderImpact,
                value: '${report.reorderImpact.toStringAsFixed(0)} $mad',
                icon: Icons.shopping_cart_outlined,
                iconColor: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildByCategory(List<CategoryStock> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.reports_byCategory,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppDimensions.paddingMedium,
            ),
            itemBuilder: (context, index) {
              return _CategoryStockTile(category: categories[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryStockTile extends StatelessWidget {
  final CategoryStock category;

  const _CategoryStockTile({required this.category});

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
                Row(
                  children: [
                    Text(
                      context.l10n.reports_products_count(category.productCount),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    if (category.lowStockCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.warningBackground,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                        ),
                        child: Text(
                          '${category.lowStockCount} low',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${category.stockValue.toStringAsFixed(0)} ${context.l10n.reports_currency}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
