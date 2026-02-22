import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/sales_chart_point.dart';

class SalesChartWidget extends StatelessWidget {
  final List<SalesChartPoint> data;

  const SalesChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxAmount = data.fold(0.0, (max, p) => p.amount > max ? p.amount : max);
    final hasData = data.any((p) => p.amount > 0);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingSmall,
          AppDimensions.paddingMedium,
          AppDimensions.paddingMedium,
          AppDimensions.paddingSmall,
        ),
        child: AspectRatio(
          aspectRatio: 2.0,
          child: BarChart(
            BarChartData(
              maxY: hasData ? maxAmount * 1.25 : 100,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: hasData ? maxAmount * 1.25 / 4 : 25,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outlineVariant,
                  strokeWidth: 1,
                  dashArray: [4, 4],
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
                    reservedSize: 24,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                      final parts = data[idx].date.split('-');
                      final label = '${parts[2]}/${parts[1]}';
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: data.asMap().entries.map((entry) {
                final idx = entry.key;
                final point = entry.value;
                final isToday = idx == data.length - 1;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: point.amount,
                      color: isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.35),
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  getTooltipItem: (group, _, rod, __) {
                    return BarTooltipItem(
                      '${rod.toY.toStringAsFixed(0)} MAD',
                      theme.textTheme.labelSmall!.copyWith(
                        color: theme.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
