/// Reorder Suggestion Models
///
/// JSON deserialization for GET /orders/suggestions response.
library;

import '../../domain/entities/reorder_suggestion.dart';

class ReorderSuggestionProductModel {
  final String id;
  final String name;
  final int currentStock;
  final int reorderThreshold;
  final String unit;
  final int shortage;
  final double? lastOrderPrice;

  const ReorderSuggestionProductModel({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.reorderThreshold,
    required this.unit,
    required this.shortage,
    this.lastOrderPrice,
  });

  factory ReorderSuggestionProductModel.fromJson(Map<String, dynamic> json) {
    return ReorderSuggestionProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      currentStock: (json['current_stock'] as num).toInt(),
      reorderThreshold: (json['reorder_threshold'] as num).toInt(),
      unit: json['unit'] as String? ?? 'piece',
      shortage: (json['shortage'] as num).toInt(),
      lastOrderPrice: json['last_order_price'] != null
          ? double.tryParse(json['last_order_price'].toString())
          : null,
    );
  }

  ReorderSuggestionProduct toEntity() => ReorderSuggestionProduct(
        id: id,
        name: name,
        currentStock: currentStock,
        reorderThreshold: reorderThreshold,
        unit: unit,
        shortage: shortage,
        lastOrderPrice: lastOrderPrice,
      );
}

class ReorderSuggestionSupplierModel {
  final String id;
  final String name;
  final String? businessName;
  final String? phoneNumber;

  const ReorderSuggestionSupplierModel({
    required this.id,
    required this.name,
    this.businessName,
    this.phoneNumber,
  });

  factory ReorderSuggestionSupplierModel.fromJson(Map<String, dynamic> json) {
    return ReorderSuggestionSupplierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      businessName: json['business_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  ReorderSuggestionSupplier toEntity() => ReorderSuggestionSupplier(
        id: id,
        name: name,
        businessName: businessName,
        phoneNumber: phoneNumber,
      );
}

class ReorderSuggestionModel {
  final ReorderSuggestionSupplierModel supplier;
  final List<ReorderSuggestionProductModel> products;

  const ReorderSuggestionModel({
    required this.supplier,
    required this.products,
  });

  factory ReorderSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ReorderSuggestionModel(
      supplier: ReorderSuggestionSupplierModel.fromJson(
          json['supplier'] as Map<String, dynamic>),
      products: (json['products'] as List)
          .map((p) => ReorderSuggestionProductModel.fromJson(
              p as Map<String, dynamic>))
          .toList(),
    );
  }

  ReorderSuggestion toEntity() => ReorderSuggestion(
        supplier: supplier.toEntity(),
        products: products.map((p) => p.toEntity()).toList(),
      );
}

class ReorderSuggestionsResultModel {
  final List<ReorderSuggestionModel> suggestions;
  final List<ReorderSuggestionProductModel> unassigned;

  const ReorderSuggestionsResultModel({
    required this.suggestions,
    required this.unassigned,
  });

  factory ReorderSuggestionsResultModel.fromJson(Map<String, dynamic> json) {
    return ReorderSuggestionsResultModel(
      suggestions: (json['suggestions'] as List)
          .map((s) => ReorderSuggestionModel.fromJson(
              s as Map<String, dynamic>))
          .toList(),
      unassigned: (json['unassigned'] as List)
          .map((p) => ReorderSuggestionProductModel.fromJson(
              p as Map<String, dynamic>))
          .toList(),
    );
  }

  ReorderSuggestionsResult toEntity() => ReorderSuggestionsResult(
        suggestions: suggestions.map((s) => s.toEntity()).toList(),
        unassigned: unassigned.map((p) => p.toEntity()).toList(),
      );
}
