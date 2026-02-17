/// Supplier Detail Screen
///
/// Displays supplier info, relationship details, and recent order history.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_order.dart';
import '../providers/suppliers_provider.dart';

class SupplierDetailScreen extends ConsumerStatefulWidget {
  final String supplierId;

  const SupplierDetailScreen({
    super.key,
    required this.supplierId,
  });

  @override
  ConsumerState<SupplierDetailScreen> createState() =>
      _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {
  Supplier? _supplier;
  List<SupplierOrder> _recentOrders = [];
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSupplier();
  }

  Future<void> _loadSupplier() async {
    setState(() {
      _isLoading = _supplier == null;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(suppliersRepositoryProvider);
      final result = await repository.getSupplierDetail(widget.supplierId);

      if (mounted) {
        setState(() {
          _supplier = result.supplier;
          _recentOrders = result.recentOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = context.l10n.error_generic;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_supplier?.name ?? context.l10n.suppliers),
        actions: [
          if (_supplier != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: context.l10n.common_edit,
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  '/suppliers/edit',
                  arguments: widget.supplierId,
                );
                _loadSupplier();
              },
            ),
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: context.l10n.common_delete,
              onPressed: _isDeleting ? null : _showDeleteDialog,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _supplier == null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadSupplier,
                  child: _buildContent(_supplier!),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              _errorMessage ?? context.l10n.error_generic,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            ElevatedButton(
              onPressed: _loadSupplier,
              child: Text(context.l10n.common_retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Supplier supplier) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(supplier),
          const SizedBox(height: AppDimensions.marginMedium),

          // Contact info card
          _buildContactCard(supplier),
          const SizedBox(height: AppDimensions.marginMedium),

          // Relationship card
          if (supplier.relationship != null)
            _buildRelationshipCard(supplier.relationship!),
          if (supplier.relationship != null)
            const SizedBox(height: AppDimensions.marginMedium),

          // Recent orders
          _buildRecentOrdersCard(),
        ],
      ),
    );
  }

  Widget _buildHeader(Supplier supplier) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                supplier.name.isNotEmpty
                    ? supplier.name[0].toUpperCase()
                    : '?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // Name
            Text(
              supplier.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            // Business name
            if (supplier.businessName != null) ...[
              const SizedBox(height: AppDimensions.marginXSmall),
              Text(
                supplier.businessName!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // City chip
            if (supplier.city != null) ...[
              const SizedBox(height: AppDimensions.marginSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingXSmall,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLarge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      supplier.city!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Stats row
            if (supplier.relationship != null) ...[
              const SizedBox(height: AppDimensions.marginMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem(
                    context.l10n.orders,
                    supplier.relationship!.totalOrders.toString(),
                  ),
                  if (supplier.relationship!.linkedSince != null) ...[
                    Container(
                      width: 1,
                      height: 32,
                      color: theme.dividerColor,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge,
                      ),
                    ),
                    _buildStatItem(
                      context.l10n.suppliers_linkedSince,
                      DateFormat.yMMMd().format(
                        supplier.relationship!.linkedSince!,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(Supplier supplier) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.suppliers_contactInfo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // Phone
            _buildContactRow(
              icon: Icons.phone_outlined,
              label: supplier.phoneNumber,
              onTap: () => _launchPhone(supplier.phoneNumber),
            ),

            // WhatsApp
            _buildContactRow(
              icon: Icons.chat_outlined,
              label: context.l10n.suppliers_contactWhatsApp,
              onTap: () => _launchWhatsApp(supplier.phoneNumber),
              color: const Color(0xFF25D366),
            ),

            // Email
            if (supplier.email != null)
              _buildContactRow(
                icon: Icons.email_outlined,
                label: supplier.email!,
                onTap: () => _launchEmail(supplier.email!),
              ),

            // Address
            if (supplier.address != null)
              _buildContactRow(
                icon: Icons.location_on_outlined,
                label: supplier.address!,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingSmall,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: color ?? AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onTap != null ? AppColors.primary : null,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.iconSecondary,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _buildRelationshipCard(SupplierRelationship relationship) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.suppliers_relationship,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // Preferred contact method
            if (relationship.preferredContactMethod != null)
              _buildDetailRow(
                context.l10n.suppliers_preferredContact,
                _contactMethodLabel(relationship.preferredContactMethod!),
              ),

            // Payment terms
            if (relationship.paymentTerms != null)
              _buildDetailRow(
                context.l10n.suppliers_paymentTerms,
                relationship.paymentTerms!,
              ),

            // Last order date
            if (relationship.lastOrderDate != null)
              _buildDetailRow(
                context.l10n.suppliers_lastOrder,
                DateFormat.yMMMd().format(relationship.lastOrderDate!),
              ),

            // Notes
            if (relationship.merchantNotes != null)
              _buildDetailRow(
                context.l10n.suppliers_notes,
                relationship.merchantNotes!,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _buildRecentOrdersCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.suppliers_recentOrders,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            if (_recentOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium,
                ),
                child: Center(
                  child: Text(
                    context.l10n.suppliers_noOrders,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_recentOrders.length, (index) {
                final order = _recentOrders[index];
                return _buildOrderTile(
                  order,
                  isLast: index == _recentOrders.length - 1,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(SupplierOrder order, {bool isLast = false}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            children: [
              // Order number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMMMd().format(order.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status chips
              if (order.pdfGenerated)
                _buildStatusChip(
                  context.l10n.suppliers_orderPdf,
                  AppColors.primary,
                ),
              if (order.sent) ...[
                const SizedBox(width: AppDimensions.marginXSmall),
                _buildStatusChip(
                  context.l10n.suppliers_orderSent,
                  AppColors.success,
                ),
              ],
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
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

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    // Remove + for WhatsApp API
    final cleaned = phoneNumber.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.confirm_deleteTitle,
      message: context.l10n.suppliers_deleteConfirm,
      confirmLabel: context.l10n.common_delete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final repository = ref.read(suppliersRepositoryProvider);
      await repository.deleteSupplier(widget.supplierId);

      if (!mounted) return;

      ref.read(suppliersProvider.notifier).removeSupplierFromList(
            widget.supplierId,
          );
      ref.read(dashboardProvider.notifier).refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.suppliers_deleted),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);

      String message = context.l10n.error_generic;

      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        final code = data['code'];
        if (code == 'SUPPLIER_HAS_ORDERS') {
          message = context.l10n.suppliers_deleteBlockedOrders;
        } else {
          message = data['message'] ?? message;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.error_generic),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
