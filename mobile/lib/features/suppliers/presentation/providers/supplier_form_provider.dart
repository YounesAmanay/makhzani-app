/// Supplier Form Provider
///
/// Riverpod provider for supplier create/update operations.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/supplier.dart';
import '../../domain/repositories/suppliers_repository.dart';
import 'suppliers_provider.dart';

enum SupplierFormStatus { initial, loading, success, error }

class SupplierFormState {
  final SupplierFormStatus status;
  final Supplier? supplier;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const SupplierFormState({
    this.status = SupplierFormStatus.initial,
    this.supplier,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  SupplierFormState copyWith({
    SupplierFormStatus? status,
    Supplier? supplier,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return SupplierFormState(
      status: status ?? this.status,
      supplier: supplier ?? this.supplier,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class SupplierFormNotifier extends StateNotifier<SupplierFormState> {
  final SuppliersRepository _repository;
  final Ref _ref;

  SupplierFormNotifier(this._repository, this._ref)
      : super(const SupplierFormState());

  void reset() {
    state = const SupplierFormState();
  }

  Future<bool> createSupplier({
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
    state = state.copyWith(
      status: SupplierFormStatus.loading,
      errorMessage: null,
      fieldErrors: {},
    );

    try {
      final supplier = await _repository.createSupplier(
        name: name,
        phoneNumber: phoneNumber,
        businessName: businessName,
        email: email,
        address: address,
        city: city,
        preferredContactMethod: preferredContactMethod,
        paymentTerms: paymentTerms,
        merchantNotes: merchantNotes,
      );

      state = state.copyWith(
        status: SupplierFormStatus.success,
        supplier: supplier,
      );

      // Refresh suppliers list
      _ref.read(suppliersProvider.notifier).refresh();

      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> updateSupplierRelationship({
    required String id,
    String? preferredContactMethod,
    String? paymentTerms,
    String? merchantNotes,
  }) async {
    state = state.copyWith(
      status: SupplierFormStatus.loading,
      errorMessage: null,
      fieldErrors: {},
    );

    try {
      final supplier = await _repository.updateSupplierRelationship(
        id: id,
        preferredContactMethod: preferredContactMethod,
        paymentTerms: paymentTerms,
        merchantNotes: merchantNotes,
      );

      state = state.copyWith(
        status: SupplierFormStatus.success,
        supplier: supplier,
      );

      // Refresh suppliers list
      _ref.read(suppliersProvider.notifier).refresh();

      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  void _handleError(dynamic e) {
    String errorMessage = 'Failed to save supplier';
    Map<String, String> fieldErrors = {};

    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        // Parse field-level validation errors
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          for (final error in errors) {
            if (error is Map) {
              final field = error['path'] as String?;
              final msg = error['msg'] as String?;
              if (field != null && msg != null) {
                fieldErrors[field] = msg;
              }
            }
          }
        }
        errorMessage = data['message'] ?? errorMessage;
      }
    }

    state = state.copyWith(
      status: SupplierFormStatus.error,
      errorMessage: fieldErrors.isEmpty ? errorMessage : null,
      fieldErrors: fieldErrors,
    );
  }
}

// Provider
final supplierFormProvider =
    StateNotifierProvider<SupplierFormNotifier, SupplierFormState>((ref) {
  return SupplierFormNotifier(
    ref.read(suppliersRepositoryProvider),
    ref,
  );
});
