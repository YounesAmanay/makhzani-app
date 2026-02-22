/// Reorder Suggestion Entities
///
/// Represents the result of the GET /orders/suggestions endpoint.
/// Products grouped by the supplier they were last ordered from.
library;

class ReorderSuggestionProduct {
  final String id;
  final String name;
  final int currentStock;
  final int reorderThreshold;
  final String unit;
  final int shortage;
  final double? lastOrderPrice;

  const ReorderSuggestionProduct({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.reorderThreshold,
    required this.unit,
    required this.shortage,
    this.lastOrderPrice,
  });
}

class ReorderSuggestionSupplier {
  final String id;
  final String name;
  final String? businessName;
  final String? phoneNumber;

  const ReorderSuggestionSupplier({
    required this.id,
    required this.name,
    this.businessName,
    this.phoneNumber,
  });

  String get displayName => businessName?.isNotEmpty == true ? businessName! : name;
}

class ReorderSuggestion {
  final ReorderSuggestionSupplier supplier;
  final List<ReorderSuggestionProduct> products;

  const ReorderSuggestion({
    required this.supplier,
    required this.products,
  });
}

class ReorderSuggestionsResult {
  final List<ReorderSuggestion> suggestions;
  final List<ReorderSuggestionProduct> unassigned;

  const ReorderSuggestionsResult({
    required this.suggestions,
    required this.unassigned,
  });

  bool get isEmpty => suggestions.isEmpty;

  int get totalProductCount =>
      suggestions.fold(0, (s, g) => s + g.products.length);
}
