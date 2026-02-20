/// Profile / Settings Screen
///
/// Displays merchant profile info and allows avatar upload.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPlaceholderScreen extends ConsumerStatefulWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  ConsumerState<SettingsPlaceholderScreen> createState() =>
      _SettingsPlaceholderScreenState();
}

class _SettingsPlaceholderScreenState
    extends ConsumerState<SettingsPlaceholderScreen> {
  bool _isUploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);

    try {
      await ref.read(authProvider.notifier).uploadAvatar(image.path);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isNotEmpty ? message : context.l10n.error_generic),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.profile_logoutTitle),
        content: Text(context.l10n.profile_logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.profile_logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final merchant = ref.watch(authProvider).merchant;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  children: [
                    // Avatar with upload overlay
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        merchant?.avatarUrl != null
                            ? CircleAvatar(
                                radius: 44,
                                backgroundImage: NetworkImage(
                                  AppConstants.serverUrl +
                                      merchant!.avatarUrl!,
                                ),
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                              )
                            : CircleAvatar(
                                radius: 44,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  merchant?.businessName?.isNotEmpty == true
                                      ? merchant!.businessName![0].toUpperCase()
                                      : '?',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        GestureDetector(
                          onTap: _isUploadingAvatar
                              ? null
                              : _pickAndUploadAvatar,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: _isUploadingAvatar
                                ? const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Business name
                    if (merchant?.businessName != null)
                      Text(
                        merchant!.businessName!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: AppDimensions.marginXSmall),

                    // Phone number
                    if (merchant?.phoneNumber != null)
                      Text(
                        merchant!.phoneNumber,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: AppDimensions.marginSmall),

                    // Subscription badge
                    if (merchant != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                          vertical: AppDimensions.paddingXSmall,
                        ),
                        decoration: BoxDecoration(
                          color: merchant.hasActiveSubscription
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLarge,
                          ),
                        ),
                        child: Text(
                          merchant.subscriptionStatus.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: merchant.hasActiveSubscription
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Logout button
            OutlinedButton.icon(
              onPressed: _confirmLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium,
                ),
              ),
              icon: const Icon(Icons.logout),
              label: Text(context.l10n.profile_logout),
            ),
          ],
        ),
      ),
    );
  }
}
