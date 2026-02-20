/// Suppliers Repository Implementation
library;

import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_order.dart';
import '../../domain/repositories/suppliers_repository.dart';
import '../datasources/suppliers_remote_datasource.dart';

class SuppliersRepositoryImpl implements SuppliersRepository {
  final SuppliersRemoteDataSource _remoteDataSource;

  SuppliersRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Supplier>> getSuppliers({String? search, String? city}) async {
    final models = await _remoteDataSource.getSuppliers(search: search, city: city);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<({Supplier supplier, List<SupplierOrder> recentOrders})>
      getSupplierDetail(String id) async {
    final result = await _remoteDataSource.getSupplierDetail(id);
    return (
      supplier: result.supplier.toEntity(),
      recentOrders: result.recentOrders.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<Supplier> createSupplier({
    required String name,
    required String phoneNumber,
    String? businessName,
    String? email,
    String? address,
    String? city,
    String? preferredContactMethod,
    String? paymentTerms,
    String? merchantNotes,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'phone_number': phoneNumber,
      if (businessName != null) 'business_name': businessName,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (preferredContactMethod != null)
        'preferred_contact_method': preferredContactMethod,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      if (merchantNotes != null) 'merchant_notes': merchantNotes,
    };

    final model = await _remoteDataSource.createSupplier(data);
    return model.toEntity();
  }

  @override
  Future<Supplier> updateSupplier({
    required String id,
    String? name,
    String? phoneNumber,
    String? businessName,
    String? email,
    String? address,
    String? city,
    String? preferredContactMethod,
    String? paymentTerms,
    String? merchantNotes,
  }) async {
    final data = <String, dynamic>{
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (businessName != null) 'business_name': businessName,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (preferredContactMethod != null)
        'preferred_contact_method': preferredContactMethod,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      if (merchantNotes != null) 'merchant_notes': merchantNotes,
    };

    final model = await _remoteDataSource.updateSupplier(id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _remoteDataSource.deleteSupplier(id);
  }

  @override
  Future<void> uploadSupplierAvatar(String id, String filePath) async {
    await _remoteDataSource.uploadSupplierAvatar(id, filePath);
  }
}
