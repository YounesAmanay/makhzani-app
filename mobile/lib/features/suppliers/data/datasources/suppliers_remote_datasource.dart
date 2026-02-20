/// Suppliers Remote Data Source
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/supplier_model.dart';

abstract class SuppliersRemoteDataSource {
  Future<List<SupplierModel>> getSuppliers({String? search, String? city});

  Future<({SupplierModel supplier, List<SupplierOrderModel> recentOrders})>
      getSupplierDetail(String id);

  Future<SupplierModel> createSupplier(Map<String, dynamic> data);

  Future<SupplierModel> updateSupplier(
    String id,
    Map<String, dynamic> data,
  );

  Future<void> deleteSupplier(String id);

  Future<void> uploadSupplierAvatar(String id, String filePath);
}

class SuppliersRemoteDataSourceImpl implements SuppliersRemoteDataSource {
  final ApiClient _apiClient;

  SuppliersRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<SupplierModel>> getSuppliers({String? search, String? city}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (city != null) 'city': city,
    };

    final response = await _apiClient.get(
      ApiEndpoints.suppliers,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final data = response.data['data'];
    final suppliers = (data['suppliers'] as List)
        .map((json) => SupplierModel.fromJson(json))
        .toList();

    return suppliers;
  }

  @override
  Future<({SupplierModel supplier, List<SupplierOrderModel> recentOrders})>
      getSupplierDetail(String id) async {
    final response = await _apiClient.get(ApiEndpoints.supplierById(id));
    final data = response.data['data'];

    final supplier = SupplierModel.fromJson(data['supplier']);
    final recentOrders = (data['recent_orders'] as List?)
            ?.map((json) => SupplierOrderModel.fromJson(json))
            .toList() ??
        [];

    return (supplier: supplier, recentOrders: recentOrders);
  }

  @override
  Future<SupplierModel> createSupplier(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.suppliers, data: data);
    return SupplierModel.fromJson(response.data['data']['supplier']);
  }

  @override
  Future<SupplierModel> updateSupplier(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(ApiEndpoints.supplierById(id), data: data);
    return SupplierModel.fromJson(response.data['data']['supplier']);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _apiClient.delete(ApiEndpoints.supplierById(id));
  }

  @override
  Future<void> uploadSupplierAvatar(String id, String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    await _apiClient.post(
      ApiEndpoints.supplierAvatar(id),
      data: formData,
    );
  }
}
