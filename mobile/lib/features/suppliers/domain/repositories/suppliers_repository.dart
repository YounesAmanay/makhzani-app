/// Suppliers Repository Interface
library;

import '../entities/supplier.dart';

abstract class SuppliersRepository {
  Future<List<Supplier>> getSuppliers();

  Future<Supplier> getSupplierById(String id);

  Future<void> deleteSupplier(String id);
}
