import '../../domain/entities/top_selling_product.dart';

class TopSellingProductModel {
  final String productId;
  final String name;
  final String unit;
  final double totalSold;
  final double totalRevenue;

  const TopSellingProductModel({
    required this.productId,
    required this.name,
    required this.unit,
    required this.totalSold,
    required this.totalRevenue,
  });

  factory TopSellingProductModel.fromJson(Map<String, dynamic> json) {
    return TopSellingProductModel(
      productId: json['product_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      totalSold: double.parse(json['total_sold'].toString()),
      totalRevenue: double.parse(json['total_revenue'].toString()),
    );
  }

  TopSellingProduct toEntity() => TopSellingProduct(
        productId: productId,
        name: name,
        unit: unit,
        totalSold: totalSold,
        totalRevenue: totalRevenue,
      );
}
