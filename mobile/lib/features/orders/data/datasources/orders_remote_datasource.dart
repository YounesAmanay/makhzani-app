/// Orders Remote Data Source
library;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_detail_model.dart';
import '../models/order_model.dart';
import '../models/pagination_model.dart';

abstract class OrdersRemoteDataSource {
  Future<({List<OrderModel> orders, OrderPaginationModel pagination})> getOrders({
    int page = 1,
    int limit = 20,
    String? supplierId,
    String? status,
    String? search,
  });

  Future<OrderModel> createOrder(Map<String, dynamic> data);

  Future<OrderDetailModel> getOrder(String id);

  /// Returns the pdf_url from the server response
  Future<String> generatePdf(String id);

  Future<void> markSent(String id, String sentVia);

  /// Marks the order as received and auto-updates stock for all items.
  Future<void> receiveOrder(String id);
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
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (supplierId != null) 'supplier_id': supplierId,
      if (status != null) 'status': status,
      if (search != null) 'search': search,
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

  @override
  Future<OrderDetailModel> getOrder(String id) async {
    final response = await _apiClient.get(ApiEndpoints.orderById(id));

    final orderJson = response.data['data']['order'] as Map<String, dynamic>;
    return OrderDetailModel.fromJson(orderJson);
  }

  @override
  Future<String> generatePdf(String id) async {
    final response = await _apiClient.post(ApiEndpoints.generatePdf(id));
    return response.data['data']['pdf_url'] as String;
  }

  @override
  Future<void> markSent(String id, String sentVia) async {
    await _apiClient.post(
      ApiEndpoints.markSent(id),
      data: {'sent_via': sentVia},
    );
  }

  @override
  Future<void> receiveOrder(String id) async {
    await _apiClient.post(ApiEndpoints.receiveOrder(id));
  }
}
