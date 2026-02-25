import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/sales_report_model.dart';
import '../models/products_report_model.dart';
import '../models/inventory_report_model.dart';

class ReportsRemoteDatasource {
  final ApiClient _apiClient;

  ReportsRemoteDatasource(this._apiClient);

  Future<SalesReportModel> getSalesReport({
    String period = 'month',
    String? from,
    String? to,
  }) async {
    final params = <String, dynamic>{'period': period};
    if (period == 'custom' && from != null && to != null) {
      params['from'] = from;
      params['to'] = to;
    }
    final response = await _apiClient.get(
      ApiEndpoints.reportsSales,
      queryParameters: params,
    );
    return SalesReportModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<ProductsReportModel> getProductsReport({int deadStockDays = 30}) async {
    final response = await _apiClient.get(
      ApiEndpoints.reportsProducts,
      queryParameters: {'dead_stock_days': deadStockDays},
    );
    return ProductsReportModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<InventoryReportModel> getInventoryReport() async {
    final response = await _apiClient.get(ApiEndpoints.reportsInventory);
    return InventoryReportModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
