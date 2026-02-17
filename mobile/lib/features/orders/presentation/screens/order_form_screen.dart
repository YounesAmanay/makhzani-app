/// Order Form Screen
///
/// Create new purchase order with dynamic product line items.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../suppliers/presentation/providers/suppliers_provider.dart';
import '../providers/order_form_provider.dart';
import '../widgets/order_item_row.dart';
import '../widgets/order_summary_card.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset form state when entering
    Future.microtask(() {
      ref.read(orderFormProvider.notifier).reset();
      // Load data if not already loaded
      ref.read(suppliersProvider.notifier).loadSuppliers();
      ref.read(productsProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(orderFormProvider);
    final suppliersState = ref.watch(suppliersProvider);
    final productsState = ref.watch(productsProvider);

    final suppliers = suppliersState.allSuppliers;
    final products = productsState.products;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.orders_createTitle),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Supplier Selector
                    _buildSupplierSelector(suppliers, formState),
                    const SizedBox(height: AppDimensions.marginLarge),

                    // Products Section
                    _buildProductsSection(products, formState),
                    const SizedBox(height: AppDimensions.marginLarge),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: context.l10n.orders_notesOptional,
                        hintText: context.l10n.orders_notesPlaceholder,
                      ),
                      maxLines: 3,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        ref.read(orderFormProvider.notifier).setNotes(value);
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginLarge),

                    // Summary
                    if (formState.items.isNotEmpty)
                      OrderSummaryCard(
                        itemsCount: formState.items.length,
                        totalValue: formState.totalValue,
                      ),
                  ],
                ),
              ),
            ),

            // Submit Button (fixed at bottom)
            _buildSubmitButton(formState),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSelector(suppliers, OrderFormState formState) {
    final theme = Theme.of(context);

    if (suppliers.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  const SizedBox(width: AppDimensions.marginSmall),
                  Expanded(
                    child: Text(
                      context.l10n.orders_noSuppliersAvailable,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.marginSmall),
              Text(
                context.l10n.orders_addSupplierFirst,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.marginMedium),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/suppliers/create');
                },
                icon: const Icon(Icons.add),
                label: Text(context.l10n.suppliers_add),
              ),
            ],
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: formState.supplierId,
      decoration: InputDecoration(
        labelText: '${context.l10n.orders_supplier} *',
        errorText: formState.fieldErrors['supplier_id'],
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            context.l10n.orders_selectSupplier,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        ...suppliers.map((supplier) {
          return DropdownMenuItem<String>(
            value: supplier.id,
            child: Text(supplier.name),
          );
        }),
      ],
      validator: (value) {
        if (value == null) {
          return context.l10n.orders_supplierRequired;
        }
        return null;
      },
      onChanged: (value) {
        ref.read(orderFormProvider.notifier).setSupplier(value);
      },
    );
  }

  Widget _buildProductsSection(products, OrderFormState formState) {
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  const SizedBox(width: AppDimensions.marginSmall),
                  Expanded(
                    child: Text(
                      context.l10n.orders_noProductsAvailable,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.marginSmall),
              Text(
                context.l10n.orders_addProductFirst,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.marginMedium),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/products/create');
                },
                icon: const Icon(Icons.add),
                label: Text(context.l10n.products_add),
              ),
            ],
          ),
        ),
      );
    }

    final excludedIds = formState.items
        .where((i) => i.productId != null)
        .map((i) => i.productId!)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.l10n.orders_products} *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.marginSmall),

        // Product Rows
        ...List.generate(formState.items.length, (index) {
          final item = formState.items[index];
          return OrderItemRow(
            key: ValueKey(index),
            index: index,
            item: item,
            products: products,
            excludedProductIds: excludedIds,
            onChanged: (updatedItem) {
              ref.read(orderFormProvider.notifier).updateItem(index, updatedItem);
            },
            onRemove: () {
              ref.read(orderFormProvider.notifier).removeItem(index);
            },
          );
        }),

        // Add Product Button
        OutlinedButton.icon(
          onPressed: () {
            ref.read(orderFormProvider.notifier).addItem();
          },
          icon: const Icon(Icons.add),
          label: Text(context.l10n.orders_addProduct),
        ),

        // Validation message
        if (formState.items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.marginSmall),
            child: Text(
              context.l10n.orders_atLeastOneProduct,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(OrderFormState formState) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: formState.status == OrderFormStatus.loading
              ? null
              : _onSubmit,
          child: formState.status == OrderFormStatus.loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.orders_createButton),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formState = ref.read(orderFormProvider);

    if (formState.supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_supplierRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (formState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_atLeastOneProduct),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(orderFormProvider.notifier).createOrder();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orders_orderCreated),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final state = ref.read(orderFormProvider);
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
