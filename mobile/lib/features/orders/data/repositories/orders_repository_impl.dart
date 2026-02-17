/// Orders Repository Implementation
library;

import '../../domain/entities/order.dart';
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
}
