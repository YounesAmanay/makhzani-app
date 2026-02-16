/// Suppliers Remote Data Source
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/supplier_model.dart';

abstract class SuppliersRemoteDataSource {
  Future<List<SupplierModel>> getSuppliers();

  Future<({SupplierModel supplier, List<SupplierOrderModel> recentOrders})>
      getSupplierDetail(String id);

  Future<SupplierModel> createSupplier(Map<String, dynamic> data);

  Future<SupplierModel> updateSupplierRelationship(
    String id,
    Map<String, dynamic> data,
  );

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
  Future<SupplierModel> updateSupplierRelationship(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _apiClient.put(ApiEndpoints.supplierById(id), data: data);
    // Backend returns supplier_id, supplier_name, relationship
    // We need to reconstruct SupplierModel or fetch again
    // For simplicity, fetch full supplier detail
    final detailResult = await getSupplierDetail(id);
    return detailResult.supplier;
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _apiClient.delete(ApiEndpoints.supplierById(id));
  }
}
