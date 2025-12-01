class Product {
  final String id;
  final String name;
  final String? description;
  final String? unit;
  final double? salePrice;
  final double? purchasePrice;
  final int currentStock;
  final int? minStockLevel;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.unit,
    this.salePrice,
    this.purchasePrice,
    required this.currentStock,
    this.minStockLevel,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      unit: json['unit'],
      salePrice: json['sale_price']?.toDouble(),
      purchasePrice: json['purchase_price']?.toDouble(),
      currentStock: json['current_stock'] ?? 0,
      minStockLevel: json['min_stock_level'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit': unit,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isLowStock => minStockLevel != null && currentStock <= minStockLevel!;
}