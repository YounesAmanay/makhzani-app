import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/sale_model.dart';
import '../models/sale_summary_model.dart';

class SalesRemoteDatasource {
  final ApiClient _apiClient;

  SalesRemoteDatasource(this._apiClient);

  Future<SaleModel> createSale({
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.sales,
      data: {
        'items': items,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return SaleModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<SaleModel>> getSales({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.sales,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final list = data['sales'] as List<dynamic>;
    return list.map((j) => SaleModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<SaleModel> getSaleById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.saleById(id));
    return SaleModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<SaleSummaryModel> getSummary() async {
    final response = await _apiClient.get(ApiEndpoints.salesSummary);
    return SaleSummaryModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> cancelSale(String id) async {
    await _apiClient.delete(ApiEndpoints.saleById(id));
  }
}
