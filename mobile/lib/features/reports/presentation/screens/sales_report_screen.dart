/// Sales Report Screen
///
/// Shows revenue, profit, daily chart, top products, best/worst day.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/widgets/app_error_state.dart';
import '../../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/sales_report.dart';
import '../providers/reports_provider.dart';
import '../widgets/period_picker_widget.dart';
import '../widgets/report_summary_card.dart';

class SalesReportScreen extends ConsumerStatefulWidget {
  const SalesReportScreen({super.key});

  @override
  ConsumerState<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(salesReportProvider);
      if (state.status == ReportStatus.initial) {
        ref.read(salesReportProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesReportProvider);

    return Column(
      children: [
        const SizedBox(height: AppDimensions.marginMedium),
        PeriodPickerWidget(
          selectedPeriod: state.selectedPeriod,
          onPeriodChanged: (p) => ref.read(salesReportProvider.notifier).load(period: p),
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        Expanded(child: _buildBody(state)),
      ],
    );
  }

  Widget _buildBody(SalesReportState state) {
    switch (state.status) {
      case ReportStatus.initial:
      case ReportStatus.loading:
        return const AppLoadingScreen();
      case ReportStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_generic,
          onRetry: () => ref.read(salesReportProvider.notifier).refresh(),
        );
      case ReportStatus.loaded:
        final report = state.report!;
        return RefreshIndicator(
          onRefresh: () => ref.read(salesReportProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryGrid(report.summary),
                const SizedBox(height: AppDimensions.marginLarge),
                _buildChart(report.chart),
                const SizedBox(height: AppDimensions.marginLarge),
                _buildBestWorstDays(report),
                const SizedBox(height: AppDimensions.marginLarge),
                _buildTopProducts(report.topProducts),
                const SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildSummaryGrid(SalesReportSummary s) {
    final mad = context.l10n.reports_currency;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: context.l10n.reports_totalRevenue,
                value: '${s.totalRevenue.toStringAsFixed(0)} $mad',
                icon: Icons.monetization_on_outlined,
                iconColor: AppColors.success,
                valueColor: AppColors.success,
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: ReportSummaryCard(
                title: context.l10n.reports_totalSales,
                value: s.totalSales.toString(),
                icon: Icons.receipt_long_outlined,
                iconColor: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: context.l10n.reports_totalProfit,
                value: '${s.totalProfit.toStringAsFixed(0)} $mad',
                icon: Icons.trending_up_outlined,
                iconColor: AppColors.primary,
                valueColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            Expanded(
              child: ReportSummaryCard(
                title: context.l10n.reports_avgSaleValue,
                value: '${s.avgSaleValue.toStringAsFixed(0)} $mad',
                icon: Icons.bar_chart_outlined,
                iconColor: AppColors.iconSecondary,
              ),
            ),
          ],
        ),
        if (s.cancelledCount > 0) ...[
          const SizedBox(height: AppDimensions.marginSmall),
          Row(
            children: [
              Expanded(
                child: ReportSummaryCard(
                  title: context.l10n.reports_cancelledCount,
                  value: s.cancelledCount.toString(),
                  icon: Icons.cancel_outlined,
                  iconColor: AppColors.error,
                  valueColor: AppColors.error,
                ),
              ),
              const SizedBox(width: AppDimensions.marginSmall),
              Expanded(
                child: ReportSummaryCard(
                  title: context.l10n.reports_cancelledValue,
                  value: '${s.cancelledValue.toStringAsFixed(0)} $mad',
                  icon: Icons.money_off_outlined,
                  iconColor: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildChart(List<SalesChartPoint> chart) {
    if (chart.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
        child: Center(
          child: Text(
            context.l10n.reports_noData,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ),
      );
    }

    final maxY = chart.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    final spots = chart.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.revenue);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.reports_revenue,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY * 1.2,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.divider,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: chart.length > 7 ? (chart.length / 5).ceilToDouble() : 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= chart.length) return const SizedBox.shrink();
                      final date = chart[index].date;
                      final day = date.length >= 10 ? date.substring(8, 10) : date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryLight.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBestWorstDays(SalesReport report) {
    if (report.bestDay == null && report.worstDay == null) return const SizedBox.shrink();
    final mad = context.l10n.reports_currency;

    return Row(
      children: [
        if (report.bestDay != null)
          Expanded(
            child: ReportSummaryCard(
              title: context.l10n.reports_bestDay,
              value: '${report.bestDay!.revenue.toStringAsFixed(0)} $mad',
              icon: Icons.emoji_events_outlined,
              iconColor: AppColors.warning,
              valueColor: AppColors.success,
            ),
          ),
        if (report.bestDay != null && report.worstDay != null)
          const SizedBox(width: AppDimensions.marginSmall),
        if (report.worstDay != null)
          Expanded(
            child: ReportSummaryCard(
              title: context.l10n.reports_worstDay,
              value: '${report.worstDay!.revenue.toStringAsFixed(0)} $mad',
              icon: Icons.trending_down_outlined,
              iconColor: AppColors.error,
            ),
          ),
      ],
    );
  }

  Widget _buildTopProducts(List<TopProduct> products) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.reports_topProducts,
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
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppDimensions.paddingMedium,
            ),
            itemBuilder: (context, index) {
              final p = products[index];
              return _TopProductTile(product: p, rank: index + 1);
            },
          ),
        ),
      ],
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final TopProduct product;
  final int rank;

  const _TopProductTile({required this.product, required this.rank});

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
                  product.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${product.quantity.toStringAsFixed(0)} ${context.l10n.reports_quantitySold}',
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
                '${product.revenue.toStringAsFixed(0)} $mad',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              if (product.profit > 0)
                Text(
                  '+${product.profit.toStringAsFixed(0)} $mad',
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
