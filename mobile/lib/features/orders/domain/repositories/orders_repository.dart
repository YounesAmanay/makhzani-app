/// Orders Repository Interface
library;

import '../entities/order.dart';
import '../entities/order_detail.dart';
import '../entities/pagination.dart';
import '../entities/reorder_suggestion.dart';

abstract class OrdersRepository {
  Future<({List<Order> orders, OrderPagination pagination})> getOrders({
    int page = 1,
    int limit = 20,
    String? supplierId,
    String? status, // 'draft', 'sent', 'all'
    String? search,
  });

  Future<Order> createOrder({
    required String supplierId,
    required List<Map<String, dynamic>> items,
    String? notes,
  });

  Future<OrderDetail> getOrder(String id);

  /// Returns the pdf_url to open immediately after generation
  Future<String> generatePdf(String id);

  Future<void> markSent(String id, String sentVia);

  /// Marks the order as received and auto-increments product stock.
  Future<void> receiveOrder(String id);

  Future<ReorderSuggestionsResult> getReorderSuggestions();
}
