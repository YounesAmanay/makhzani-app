import '../entities/sale.dart';
import '../entities/sale_summary.dart';

abstract class SalesRepository {
  Future<Sale> createSale({
    required List<Map<String, dynamic>> items,
    String? notes,
  });

  Future<List<Sale>> getSales({int page = 1, int limit = 20});

  Future<Sale> getSaleById(String id);

  Future<SaleSummary> getSummary();

  Future<void> cancelSale(String id);
}
