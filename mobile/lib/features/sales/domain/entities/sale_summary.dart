class SalePeriodSummary {
  final double amount;
  final int count;

  const SalePeriodSummary({required this.amount, required this.count});
}

class SaleSummary {
  final SalePeriodSummary today;
  final SalePeriodSummary thisMonth;
  final SalePeriodSummary total;

  const SaleSummary({
    required this.today,
    required this.thisMonth,
    required this.total,
  });
}
