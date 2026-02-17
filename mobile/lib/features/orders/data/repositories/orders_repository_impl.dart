/// Orders Repository Implementation
library;

import '../../domain/entities/order.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;

  OrdersRepositoryImpl(this._remoteDataSource);

  @override
  Future<({List<Order> orders, OrderPagination pagination})> getOrders({
    int page = 1,
    int limit = 20,
    String? supplierId,
    String? status,
  }) async {
    final result = await _remoteDataSource.getOrders(
      page: page,
      limit: limit,
      supplierId: supplierId,
      status: status,
    );

    return (
      orders: result.orders.map((m) => m.toEntity()).toList(),
      pagination: result.pagination.toEntity(),
    );
  }

  @override
  Future<Order> createOrder({
    required String supplierId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'supplier_id': supplierId,
      'items': items,
      if (notes != null) 'notes': notes,
    };

    final model = await _remoteDataSource.createOrder(data);
    return model.toEntity();
  }

  @override
  Future<OrderDetail> getOrder(String id) async {
    final model = await _remoteDataSource.getOrder(id);
    return model.toEntity();
  }

  @override
  Future<void> generatePdf(String id) async {
    await _remoteDataSource.generatePdf(id);
  }

  @override
  Future<void> markSent(String id, String sentVia) async {
    await _remoteDataSource.markSent(id, sentVia);
  }
}
