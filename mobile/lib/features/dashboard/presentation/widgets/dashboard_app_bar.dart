/// Dashboard App Bar
///
/// Custom branded header with logo and profile menu.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Get business name from auth state
    final businessName = authState.merchant?.businessName ?? '';
    final firstLetter = businessName.isNotEmpty ? businessName[0].toUpperCase() : '?';

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: AppDimensions.paddingMedium,
      title: Row(
        children: [
          // App logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2,
              size: 20,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: AppDimensions.marginSmall),
          // App name
          Text(
            context.l10n.appName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      actions: [
        // Profile avatar - opens bottom sheet
        GestureDetector(
          onTap: () => _showProfileSheet(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showProfileSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => _ProfileSheet(ref: ref),
    );
  }
}

class _ProfileSheet extends ConsumerWidget {
  final WidgetRef ref;

  const _ProfileSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    final businessName = authState.merchant?.businessName ?? '';
    final phoneNumber = authState.merchant?.phoneNumber ?? '';
    final firstLetter = businessName.isNotEmpty ? businessName[0].toUpperCase() : '?';
    final isDark = themeMode == ThemeMode.dark;
    final isArabic = currentLocale.languageCode == 'ar';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // Profile header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessName.isNotEmpty
                              ? businessName
                              : context.l10n.profile,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (phoneNumber.isNotEmpty)
                          Text(
                            phoneNumber,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),
            const Divider(),

            // Settings
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(context.l10n.settings),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/settings');
              },
            ),

            // Dark mode toggle
            ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode_outlined,
              ),
              title: Text(
                isDark ? context.l10n.theme_dark : context.l10n.theme_light,
              ),
              trailing: Switch.adaptive(
                value: isDark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primary,
              ),
            ),

            // Language toggle
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(context.l10n.settings_language),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? 'AR' : 'EN',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              onTap: () {
                if (isArabic) {
                  ref.read(localeProvider.notifier).state = const Locale('en');
                } else {
                  ref.read(localeProvider.notifier).state = const Locale('ar');
                }
                Navigator.of(context).pop();
              },
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.error),
              title: Text(
                context.l10n.logout,
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final confirmed = await _showLogoutConfirmation(context);
                if (confirmed && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (r) => false);
                  }
                }
              },
            ),

            const SizedBox(height: AppDimensions.marginSmall),
          ],
        ),
      ),
    );
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirm_logoutTitle),
        content: Text(context.l10n.confirm_logout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(context.l10n.logout),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
