import '../../domain/entities/sales_report.dart';
import '../../domain/entities/products_report.dart';
import '../../domain/entities/inventory_report.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepository {
  final ReportsRemoteDatasource _datasource;

  ReportsRepository(this._datasource);

  Future<SalesReport> getSalesReport({
    String period = 'month',
    String? from,
    String? to,
  }) async {
    final model = await _datasource.getSalesReport(
      period: period,
      from: from,
      to: to,
    );
    return model.toEntity();
  }

  Future<ProductsReport> getProductsReport({int deadStockDays = 30}) async {
    final model = await _datasource.getProductsReport(deadStockDays: deadStockDays);
    return model.toEntity();
  }

  Future<InventoryReport> getInventoryReport() async {
    final model = await _datasource.getInventoryReport();
    return model.toEntity();
  }
}
