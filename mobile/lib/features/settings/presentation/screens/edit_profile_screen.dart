/// Edit Profile Screen
///
/// Form for updating merchant profile: owner name, shop name, address, region.
/// Calls PUT /api/merchants/profile and patches auth state on success.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerNameController;
  late final TextEditingController _shopNameController;
  late final TextEditingController _addressController;

  static const List<String> _regions = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Agadir',
    'Tangier',
    'Fes',
    'Meknes',
    'Other',
  ];

  String? _selectedRegion;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    final merchant = ref.read(authProvider).merchant;
    _ownerNameController = TextEditingController(text: merchant?.ownerName ?? '');
    _shopNameController = TextEditingController(text: merchant?.shopName ?? '');
    _addressController = TextEditingController(text: merchant?.address ?? '');
    _selectedRegion = merchant?.region;
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _fieldErrors = {};
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final merchant = ref.read(authProvider).merchant;

    // Only send changed fields
    final ownerName = _ownerNameController.text.trim();
    final shopName = _shopNameController.text.trim();
    final address = _addressController.text.trim();

    final changedOwnerName = ownerName != (merchant?.ownerName ?? '') ? ownerName : null;
    final changedShopName = shopName != (merchant?.shopName ?? '') ? shopName : null;
    final changedAddress = address != (merchant?.address ?? '') ? address : null;
    final changedRegion = _selectedRegion != merchant?.region ? _selectedRegion : null;

    // Nothing changed — just pop
    if (changedOwnerName == null &&
        changedShopName == null &&
        changedAddress == null &&
        changedRegion == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    try {
      await ref.read(authProvider.notifier).updateProfile(
            ownerName: changedOwnerName,
            shopName: changedShopName,
            address: changedAddress,
            region: changedRegion,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profile_updated),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } on ProfileUpdateException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _fieldErrors = e.fieldErrors;
        _errorMessage = e.fieldErrors.isEmpty ? e.message : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = context.l10n.error_generic;
      });
    }

    if (mounted && _isSubmitting) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile_editProfile),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Owner name
              TextFormField(
                controller: _ownerNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.profile_ownerName,
                  errorText: _fieldErrors['name'],
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (_fieldErrors['name'] != null) return null;
                  if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                    return context.l10n.validation_required;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Shop name
              TextFormField(
                controller: _shopNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.profile_shopName,
                  errorText: _fieldErrors['shop_name'],
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (_fieldErrors['shop_name'] != null) return null;
                  if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                    return context.l10n.validation_required;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: context.l10n.profile_address,
                  errorText: _fieldErrors['address'],
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLines: 2,
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Region dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedRegion,
                decoration: InputDecoration(
                  labelText: context.l10n.profile_region,
                  errorText: _fieldErrors['region'],
                ),
                hint: Text(context.l10n.profile_selectRegion),
                items: _regions.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (value) => setState(() => _selectedRegion = value),
              ),

              const SizedBox(height: AppDimensions.marginXLarge),

              // Generic error container
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: AppDimensions.marginSmall),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Save button
              SizedBox(
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(context.l10n.common_save),
                ),
              ),

              const SizedBox(height: AppDimensions.marginMedium),
            ],
          ),
        ),
      ),
    );
  }
}
