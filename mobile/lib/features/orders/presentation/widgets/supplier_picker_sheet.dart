/// Supplier Picker Sheet
///
/// Simple bottom sheet listing suppliers for selection in the orders filter.
library;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../suppliers/domain/entities/supplier.dart';

class SupplierPickerSheet extends StatelessWidget {
  final List<Supplier> suppliers;
  final String? selectedSupplierId;

  const SupplierPickerSheet({
    super.key,
    required this.suppliers,
    this.selectedSupplierId,
  });

  static Future<String?> show({
    required BuildContext context,
    required List<Supplier> suppliers,
    String? selectedSupplierId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => SupplierPickerSheet(
        suppliers: suppliers,
        selectedSupplierId: selectedSupplierId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingMedium),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginMedium),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.l10n.orders_filterAllSuppliers,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginSmall),
              ],
            ),
          ),

          // Supplier list
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...suppliers.map((supplier) {
                    final isSelected = supplier.id == selectedSupplierId;
                    return ListTile(
                      title: Text(
                        supplier.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected ? AppColors.primary : null,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.of(context).pop(supplier.id),
                    );
                  }),
                  const SizedBox(height: AppDimensions.marginSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
