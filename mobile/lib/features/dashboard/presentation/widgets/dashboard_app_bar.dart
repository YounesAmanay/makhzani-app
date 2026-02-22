/// Dashboard App Bar
///
/// Custom branded header with logo and profile menu.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Get business name and avatar from auth state
    final merchant = authState.merchant;
    final businessName = merchant?.businessName ?? '';
    final firstLetter = businessName.isNotEmpty ? businessName[0].toUpperCase() : '?';
    final avatarUrl = merchant?.avatarUrl;

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: AppDimensions.paddingMedium,
      title: Row(
        children: [
          // Wordmark
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'M',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: AppColors.primary,
                        fontSize: 22,
                      ),
                ),
                TextSpan(
                  text: 'akhzani',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Notification bell with unread badge
        _NotificationBell(),
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
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(AppConstants.serverUrl + avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          firstLetter,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 4),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  size: 16,
                  color: Theme.of(context).iconTheme.color ?? AppColors.textSecondary,
                ),
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
      builder: (sheetContext) => _ProfileSheet(
        ref: ref,
        parentContext: context,
      ),
    );
  }
}

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return IconButton(
      tooltip: context.l10n.notifications_title,
      onPressed: () => Navigator.of(context).pushNamed('/notifications'),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          HugeIcon(
            icon: unreadCount > 0
                ? HugeIcons.strokeRoundedNotification01
                : HugeIcons.strokeRoundedNotification02,
            size: AppDimensions.iconMedium,
            color: Theme.of(context).iconTheme.color ?? AppColors.textSecondary,
          ),
          if (unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileSheet extends ConsumerWidget {
  final WidgetRef ref;
  final BuildContext parentContext;

  const _ProfileSheet({
    required this.ref,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);


    final merchant = authState.merchant;
    final businessName = merchant?.businessName ?? '';
    final phoneNumber = merchant?.phoneNumber ?? '';
    final firstLetter = businessName.isNotEmpty ? businessName[0].toUpperCase() : '?';
    final avatarUrl = merchant?.avatarUrl;
    final isDark = themeMode == ThemeMode.dark;


    return SafeArea(
      child: SingleChildScrollView(
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
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(AppConstants.serverUrl + avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            firstLetter,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          )
                        : null,
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
              leading: HugeIcon(icon: HugeIcons.strokeRoundedSettings01, size: 22, color: Theme.of(context).iconTheme.color ?? AppColors.textSecondary),
              title: Text(context.l10n.settings),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(parentContext).pushNamed('/settings');
              },
            ),

            // Dark mode toggle
            ListTile(
              leading: HugeIcon(
                icon: isDark ? HugeIcons.strokeRoundedMoon : HugeIcons.strokeRoundedSun01,
                size: 22,
                color: Theme.of(context).iconTheme.color ?? AppColors.textSecondary,
              ),
              title: Text(
                isDark ? context.l10n.theme_dark : context.l10n.theme_light,
              ),
              trailing: Switch.adaptive(
                value: isDark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primary,
              ),
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedLogout01, size: 22, color: AppColors.error),
              title: Text(
                context.l10n.logout,
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => _handleLogout(context, ref),
            ),

            const SizedBox(height: AppDimensions.marginSmall),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext sheetContext, WidgetRef ref) async {
    // Show confirmation dialog first (while sheet is still open)
    final confirmed = await AppConfirmDialog.show(
      context: sheetContext,
      title: sheetContext.l10n.confirm_logoutTitle,
      message: sheetContext.l10n.confirm_logout,
      confirmLabel: sheetContext.l10n.logout,
      isDestructive: true,
      icon: HugeIcons.strokeRoundedLogout01,
    );

    if (!confirmed) return;

    // Close the bottom sheet
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }

    // Perform logout
    await ref.read(authProvider.notifier).logout();

    // Navigate to splash (it will handle routing to login)
    if (parentContext.mounted) {
      Navigator.of(parentContext).pushNamedAndRemoveUntil('/', (r) => false);
    }
  }
}
