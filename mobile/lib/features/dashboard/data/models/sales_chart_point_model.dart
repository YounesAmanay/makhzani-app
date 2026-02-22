import '../../domain/entities/sales_chart_point.dart';

class SalesChartPointModel {
  final String date;
  final double amount;
  final int count;

  const SalesChartPointModel({
    required this.date,
    required this.amount,
    required this.count,
  });

  factory SalesChartPointModel.fromJson(Map<String, dynamic> json) {
    return SalesChartPointModel(
      date: json['date'] as String,
      amount: double.parse(json['amount'].toString()),
      count: int.parse(json['count'].toString()),
    );
  }

  SalesChartPoint toEntity() => SalesChartPoint(
        date: date,
        amount: amount,
        count: count,
      );
}
