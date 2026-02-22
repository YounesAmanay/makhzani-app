import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_summary.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_datasource.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDatasource _datasource;

  SalesRepositoryImpl(this._datasource);

  @override
  Future<Sale> createSale({required List<Map<String, dynamic>> items, String? notes}) async {
    final model = await _datasource.createSale(items: items, notes: notes);
    return model.toEntity();
  }

  @override
  Future<List<Sale>> getSales({int page = 1, int limit = 20}) async {
    final models = await _datasource.getSales(page: page, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Sale> getSaleById(String id) async {
    final model = await _datasource.getSaleById(id);
    return model.toEntity();
  }

  @override
  Future<SaleSummary> getSummary() async {
    final model = await _datasource.getSummary();
    return model.toEntity();
  }

  @override
  Future<void> cancelSale(String id) => _datasource.cancelSale(id);
}
