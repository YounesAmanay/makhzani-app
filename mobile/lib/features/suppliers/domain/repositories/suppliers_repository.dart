/// Suppliers Repository Interface
library;

import '../entities/supplier.dart';
import '../entities/supplier_order.dart';

abstract class SuppliersRepository {
  Future<List<Supplier>> getSuppliers({String? search, String? city});

  Future<({Supplier supplier, List<SupplierOrder> recentOrders})>
      getSupplierDetail(String id);

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
  });

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
  });

  Future<void> deleteSupplier(String id);

  Future<void> uploadSupplierAvatar(String id, String filePath);
}
