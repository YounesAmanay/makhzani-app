/// Suppliers Repository Implementation
library;

import '../../domain/entities/supplier.dart';
import '../../domain/repositories/suppliers_repository.dart';
import '../datasources/suppliers_remote_datasource.dart';

class SuppliersRepositoryImpl implements SuppliersRepository {
  final SuppliersRemoteDataSource _remoteDataSource;

  SuppliersRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Supplier>> getSuppliers() async {
    final models = await _remoteDataSource.getSuppliers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Supplier> getSupplierById(String id) async {
    final model = await _remoteDataSource.getSupplierById(id);
    return model.toEntity();
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _remoteDataSource.deleteSupplier(id);
  }
}
