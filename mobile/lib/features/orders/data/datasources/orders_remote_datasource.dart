/// Orders Remote Data Source
library;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/pagination_model.dart';

abstract class OrdersRemoteDataSource {
  Future<({List<OrderModel> orders, OrderPaginationModel pagination})> getOrders({
    int page = 1,
    int limit = 20,
    String? supplierId,
    String? status,
  });

  Future<OrderModel> createOrder(Map<String, dynamic> data);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient _apiClient;

  OrdersRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<OrderModel> orders, OrderPaginationModel pagination})> getOrders({
    int page = 1,
    int limit = 20,
    String? supplierId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (supplierId != null) 'supplier_id': supplierId,
      if (status != null) 'status': status,
    };

    final response = await _apiClient.get(
      ApiEndpoints.orders,
      queryParameters: queryParams,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final ordersJson = data['orders'] as List;
    final paginationJson = data['pagination'] as Map<String, dynamic>;

    return (
      orders: ordersJson
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: OrderPaginationModel.fromJson(paginationJson),
    );
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: data,
    );

    final orderJson = response.data['data']['order'] as Map<String, dynamic>;
    return OrderModel.fromJson(orderJson);
  }
}
