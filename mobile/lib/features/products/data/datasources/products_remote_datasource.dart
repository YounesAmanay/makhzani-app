/// Products Remote Data Source
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/pagination_model.dart';

abstract class ProductsRemoteDataSource {
  Future<({List<ProductModel> products, PaginationModel pagination})> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? lowStock,
  });

  Future<ProductModel> getProductById(String id);

  Future<ProductModel> createProduct(Map<String, dynamic> data);

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data);

  Future<void> deleteProduct(String id);

  Future<int> adjustStock(String id, int adjustment, String? reason);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient _apiClient;

  ProductsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<ProductModel> products, PaginationModel pagination})> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? lowStock,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (lowStock == true) {
      queryParams['low_stock'] = 'true';
    }

    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    final data = response.data['data'];
    final products = (data['products'] as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
    final pagination = PaginationModel.fromJson(data['pagination']);

    return (products: products, pagination: pagination);
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.productById(id));
    return ProductModel.fromJson(response.data['data']['product']);
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.products, data: data);
    return ProductModel.fromJson(response.data['data']['product']);
  }

  @override
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiEndpoints.productById(id), data: data);
    return ProductModel.fromJson(response.data['data']['product']);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _apiClient.delete(ApiEndpoints.productById(id));
  }

  @override
  Future<int> adjustStock(String id, int adjustment, String? reason) async {
    final response = await _apiClient.post(
      ApiEndpoints.adjustStock(id),
      data: {
        'adjustment': adjustment,
        if (reason != null) 'reason': reason,
      },
    );
    return response.data['data']['product']['new_stock'] as int;
  }
}
