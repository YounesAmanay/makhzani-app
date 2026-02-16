/// Orders Repository Interface
library;

import '../entities/order.dart';
import '../entities/pagination.dart';

abstract class OrdersRepository {
  Future<({List<Order> orders, OrderPagination pagination})> getOrders({
    int page = 1,
    int limit = 20,
    String? supplierId,
    String? status, // 'draft', 'sent', 'all'
  });
}
