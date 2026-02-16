/// Suppliers Remote Data Source
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/supplier_model.dart';

abstract class SuppliersRemoteDataSource {
  Future<List<SupplierModel>> getSuppliers();

  Future<SupplierModel> getSupplierById(String id);

  Future<void> deleteSupplier(String id);
}

class SuppliersRemoteDataSourceImpl implements SuppliersRemoteDataSource {
  final ApiClient _apiClient;

  SuppliersRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<SupplierModel>> getSuppliers() async {
    final response = await _apiClient.get(ApiEndpoints.suppliers);

    final data = response.data['data'];
    final suppliers = (data['suppliers'] as List)
        .map((json) => SupplierModel.fromJson(json))
        .toList();

    return suppliers;
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.supplierById(id));
    return SupplierModel.fromJson(response.data['data']['supplier']);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _apiClient.delete(ApiEndpoints.supplierById(id));
  }
}
