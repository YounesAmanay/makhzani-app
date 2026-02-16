/// Supplier Form Screen
///
/// Create new supplier or edit relationship details.
/// Create mode: all fields editable
/// Edit mode: only relationship fields editable (contact method, payment, notes)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/supplier.dart';
import '../providers/supplier_form_provider.dart';
import '../providers/suppliers_provider.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final String? supplierId;

  const SupplierFormScreen({
    super.key,
    this.supplierId,
  });

  bool get isEditing => supplierId != null;

  @override
  ConsumerState<SupplierFormScreen> createState() =>
      _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCity;
  String _selectedContactMethod = 'whatsapp';
  bool _isLoading = false;
  bool _isSubmitting = false;
  Map<String, String> _fieldErrors = {};
  Supplier? _supplier;

  static const List<String> _cities = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Agadir',
    'Tangier',
    'Fes',
    'Meknes',
    'Other',
  ];

  static const List<String> _contactMethods = [
    'whatsapp',
    'phone',
    'email',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadSupplier();
    }
  }

  Future<void> _loadSupplier() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(suppliersRepositoryProvider);
      final result = await repository.getSupplierDetail(widget.supplierId!);
      final supplier = result.supplier;

      if (mounted) {
        setState(() {
          _supplier = supplier;
          // Populate all fields (but will disable supplier info fields in edit mode)
          _nameController.text = supplier.name;
          _phoneController.text = supplier.phoneNumber;
          _businessNameController.text = supplier.businessName ?? '';
          _emailController.text = supplier.email ?? '';
          _addressController.text = supplier.address ?? '';
          _selectedCity = supplier.city;
          _selectedContactMethod =
              supplier.relationship?.preferredContactMethod ?? 'whatsapp';
          _paymentTermsController.text =
              supplier.relationship?.paymentTerms ?? '';
          _notesController.text = supplier.relationship?.merchantNotes ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _paymentTermsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? context.l10n.suppliers_edit
              : context.l10n.suppliers_add,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Supplier Info Section
                    if (!widget.isEditing || _supplier != null) ...[
                      Text(
                        context.l10n.suppliers_contactInfo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),
                    ],

                    // Name
                    TextFormField(
                      controller: _nameController,
                      enabled: !widget.isEditing,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.suppliers_name} *',
                        errorText: _fieldErrors['name'],
                        filled: widget.isEditing,
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (_fieldErrors['name'] != null) return null;
                        if (!widget.isEditing &&
                            (value == null || value.trim().isEmpty)) {
                          return context.l10n.validation_required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      enabled: !widget.isEditing,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.suppliers_phone} *',
                        hintText: '+212600000000',
                        helperText: context.l10n.suppliers_phoneHelper,
                        errorText: _fieldErrors['phone_number'],
                        filled: widget.isEditing,
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (_fieldErrors['phone_number'] != null) return null;
                        if (!widget.isEditing) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.validation_required;
                          }
                          // Morocco phone format validation
                          final phoneRegex = RegExp(r'^\+212[5-7]\d{8}$');
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return context.l10n.validation_phoneFormat;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Business Name
                    TextFormField(
                      controller: _businessNameController,
                      enabled: !widget.isEditing,
                      decoration: InputDecoration(
                        labelText: context.l10n.suppliers_businessName,
                        errorText: _fieldErrors['business_name'],
                        filled: widget.isEditing,
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      enabled: !widget.isEditing,
                      decoration: InputDecoration(
                        labelText: context.l10n.suppliers_email,
                        hintText: 'supplier@example.com',
                        errorText: _fieldErrors['email'],
                        filled: widget.isEditing,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (_fieldErrors['email'] != null) return null;
                        if (value != null && value.trim().isNotEmpty) {
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return context.l10n.validation_emailFormat;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      enabled: !widget.isEditing,
                      decoration: InputDecoration(
                        labelText: context.l10n.suppliers_address,
                        errorText: _fieldErrors['address'],
                        filled: widget.isEditing,
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // City
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: context.l10n.suppliers_city,
                        errorText: _fieldErrors['city'],
                        filled: widget.isEditing,
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            context.l10n.suppliers_citySelect,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        ..._cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            enabled: !widget.isEditing,
                            child: Text(city),
                          );
                        }),
                      ],
                      onChanged: widget.isEditing
                          ? null
                          : (value) {
                              setState(() => _selectedCity = value);
                            },
                    ),
                    const SizedBox(height: AppDimensions.marginLarge),

                    // Relationship Section
                    Text(
                      context.l10n.suppliers_relationship,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Preferred Contact Method
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedContactMethod,
                      decoration: InputDecoration(
                        labelText: context.l10n.suppliers_preferredContact,
                        errorText: _fieldErrors['preferred_contact_method'],
                      ),
                      items: _contactMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(_contactMethodLabel(method)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedContactMethod = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Payment Terms
                    TextFormField(
                      controller: _paymentTermsController,
                      decoration: InputDecoration(
                        labelText: context.l10n.suppliers_paymentTerms,
                        hintText: 'Net 30',
                        errorText: _fieldErrors['payment_terms'],
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Merchant Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: context.l10n.suppliers_notes,
                        hintText: 'Reliable supplier, quick delivery',
                        errorText: _fieldErrors['merchant_notes'],
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppDimensions.marginLarge),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _onSubmit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(context.l10n.common_save),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _contactMethodLabel(String method) {
    switch (method) {
      case 'whatsapp':
        return context.l10n.suppliers_contactWhatsApp;
      case 'phone':
        return context.l10n.suppliers_contactPhone;
      case 'email':
        return context.l10n.suppliers_contactEmail;
      default:
        return method;
    }
  }

  Future<void> _onSubmit() async {
    // Clear previous field errors
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    bool success;
    if (widget.isEditing) {
      success = await ref.read(supplierFormProvider.notifier).updateSupplierRelationship(
            id: widget.supplierId!,
            preferredContactMethod: _selectedContactMethod,
            paymentTerms: _paymentTermsController.text.trim().isEmpty
                ? null
                : _paymentTermsController.text.trim(),
            merchantNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
    } else {
      success = await ref.read(supplierFormProvider.notifier).createSupplier(
            name: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            businessName: _businessNameController.text.trim().isEmpty
                ? null
                : _businessNameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            city: _selectedCity,
            preferredContactMethod: _selectedContactMethod,
            paymentTerms: _paymentTermsController.text.trim().isEmpty
                ? null
                : _paymentTermsController.text.trim(),
            merchantNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
    }

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? context.l10n.suppliers_updated
                : context.l10n.suppliers_created,
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      // Handle field errors from provider
      final formState = ref.read(supplierFormProvider);
      if (formState.fieldErrors.isNotEmpty) {
        setState(() {
          _fieldErrors = formState.fieldErrors;
        });
        // Re-validate to show inline errors
        _formKey.currentState!.validate();
      } else if (formState.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formState.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
