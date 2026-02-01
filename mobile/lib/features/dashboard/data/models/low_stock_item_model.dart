/// Low Stock Item Model (Data Layer)
///
/// JSON serialization for low stock items from API.
library;

import '../../domain/entities/low_stock_item.dart';

class LowStockItemModel {
  final String id;
  final String name;
  final int currentStock;
  final int reorderThreshold;
  final String unit;
  final int shortage;

  const LowStockItemModel({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.reorderThreshold,
    required this.unit,
    required this.shortage,
  });

  factory LowStockItemModel.fromJson(Map<String, dynamic> json) {
    return LowStockItemModel(
      id: json['id'],
      name: json['name'],
      currentStock: json['current_stock'] ?? 0,
      reorderThreshold: json['reorder_threshold'] ?? 0,
      unit: json['unit'] ?? 'pcs',
      shortage: json['shortage'] ?? 0,
    );
  }

  LowStockItem toEntity() => LowStockItem(
    id: id,
    name: name,
    currentStock: currentStock,
    reorderThreshold: reorderThreshold,
    unit: unit,
    shortage: shortage,
  );
}
