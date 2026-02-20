/// Products Remote Data Source
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/barcode_result_model.dart';
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

  Future<ProductImageModel> uploadProductImage(String id, String filePath);

  Future<void> deleteProductImage(String productId, String imageId);

  Future<BarcodeResultModel?> lookupBarcode(String barcode);
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

  @override
  Future<ProductImageModel> uploadProductImage(String id, String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.post(
      ApiEndpoints.productImages(id),
      data: formData,
    );
    return ProductImageModel.fromJson(response.data['data']['image']);
  }

  @override
  Future<void> deleteProductImage(String productId, String imageId) async {
    await _apiClient.delete(ApiEndpoints.productImage(productId, imageId));
  }

  @override
  Future<BarcodeResultModel?> lookupBarcode(String barcode) async {
    final response = await _apiClient.get(
      ApiEndpoints.barcodeLookup,
      queryParameters: {'barcode': barcode},
    );
    final data = response.data['data'];
    if (data == null) return null;
    return BarcodeResultModel.fromJson(data as Map<String, dynamic>);
  }
}
