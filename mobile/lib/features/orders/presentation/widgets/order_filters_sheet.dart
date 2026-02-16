/// Order Filters Bottom Sheet
///
/// Bottom sheet for filtering orders by supplier and status.
library;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../suppliers/domain/entities/supplier.dart';

class OrderFiltersSheet extends StatefulWidget {
  final String? selectedSupplierId;
  final String selectedStatus;
  final List<Supplier> suppliers;
  final Function(String? supplierId, String status) onApply;

  const OrderFiltersSheet({
    super.key,
    this.selectedSupplierId,
    required this.selectedStatus,
    required this.suppliers,
    required this.onApply,
  });

  @override
  State<OrderFiltersSheet> createState() => _OrderFiltersSheetState();

  static Future<void> show({
    required BuildContext context,
    String? selectedSupplierId,
    required String selectedStatus,
    required List<Supplier> suppliers,
    required Function(String? supplierId, String status) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => OrderFiltersSheet(
        selectedSupplierId: selectedSupplierId,
        selectedStatus: selectedStatus,
        suppliers: suppliers,
        onApply: onApply,
      ),
    );
  }
}

class _OrderFiltersSheetState extends State<OrderFiltersSheet> {
  late String? _selectedSupplierId;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedSupplierId = widget.selectedSupplierId;
    _selectedStatus = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.orders_filterStatus,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: context.l10n.common_cancel,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // Status Filter
          Text(
            context.l10n.orders_status,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Wrap(
            spacing: AppDimensions.marginSmall,
            children: [
              _buildStatusChip(
                context,
                label: context.l10n.orders_filterAll,
                value: 'all',
              ),
              _buildStatusChip(
                context,
                label: context.l10n.orders_statusDraft,
                value: 'draft',
              ),
              _buildStatusChip(
                context,
                label: context.l10n.orders_statusSent,
                value: 'sent',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // Supplier Filter
          Text(
            context.l10n.orders_filterSupplier,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          DropdownButtonFormField<String?>(
            // ignore: deprecated_member_use
            value: _selectedSupplierId,
            decoration: InputDecoration(
              hintText: context.l10n.orders_filterAllSuppliers,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.l10n.orders_filterAllSuppliers),
              ),
              ...widget.suppliers.map((supplier) {
                return DropdownMenuItem<String?>(
                  value: supplier.id,
                  child: Text(supplier.name),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedSupplierId = value);
            },
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              widget.onApply(_selectedSupplierId, _selectedStatus);
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.common_filter),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final isSelected = _selectedStatus == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = value);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
      showCheckmark: true,
    );
  }
}
