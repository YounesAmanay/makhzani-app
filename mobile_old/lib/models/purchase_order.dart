import 'product.dart';
import 'supplier.dart';

class PurchaseOrder {
  final String id;
  final String orderNumber;
  final String supplierId;
  final Supplier? supplier;
  final List<PurchaseOrderItem> items;
  final String? notes;
  final DateTime? pdfGeneratedAt;
  final DateTime? sentAt;
  final String? sentVia;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseOrder({
    required this.id,
    required this.orderNumber,
    required this.supplierId,
    this.supplier,
    required this.items,
    this.notes,
    this.pdfGeneratedAt,
    this.sentAt,
    this.sentVia,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      orderNumber: json['order_number'],
      supplierId: json['supplier_id'],
      supplier: json['supplier'] != null ? Supplier.fromJson(json['supplier']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((item) => PurchaseOrderItem.fromJson(item)).toList()
          : [],
      notes: json['notes'],
      pdfGeneratedAt: json['pdf_generated_at'] != null ? DateTime.parse(json['pdf_generated_at']) : null,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      sentVia: json['sent_via'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'supplier_id': supplierId,
      'supplier': supplier?.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'pdf_generated_at': pdfGeneratedAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'sent_via': sentVia,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  double get totalValue => items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isPdfGenerated => pdfGeneratedAt != null;
  bool get isSent => sentAt != null;
}

class PurchaseOrderItem {
  final String id;
  final String productId;
  final Product? product;
  final String? productNameSnapshot;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  PurchaseOrderItem({
    required this.id,
    required this.productId,
    this.product,
    this.productNameSnapshot,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'],
      productId: json['product_id'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      productNameSnapshot: json['product_name_snapshot'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product': product?.toJson(),
      'product_name_snapshot': productNameSnapshot,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}