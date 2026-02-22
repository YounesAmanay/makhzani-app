import '../../domain/entities/sale_summary.dart';

class SaleSummaryModel {
  factory SaleSummaryModel.fromJson(Map<String, dynamic> json) {
    SalePeriodSummary parsePeriod(Map<String, dynamic> p) => SalePeriodSummary(
          amount: (p['amount'] as num).toDouble(),
          count: (p['count'] as num).toInt(),
        );

    return SaleSummaryModel._(
      SaleSummary(
        today: parsePeriod(json['today'] as Map<String, dynamic>),
        thisMonth: parsePeriod(json['this_month'] as Map<String, dynamic>),
        total: parsePeriod(json['total'] as Map<String, dynamic>),
      ),
    );
  }

  SaleSummaryModel._(this._entity);
  final SaleSummary _entity;

  SaleSummary toEntity() => _entity;
}
