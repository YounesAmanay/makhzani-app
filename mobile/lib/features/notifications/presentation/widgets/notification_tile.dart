import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_provider.dart';

class NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notification.isRead;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingXSmall,
      ),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsetsDirectional.only(end: AppDimensions.paddingLarge),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedDelete02,
            size: AppDimensions.iconMedium,
            color: Colors.white,
          ),
        ),
        onDismissed: (_) {
          ref.read(notificationsProvider.notifier).delete(notification.id);
        },
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: InkWell(
            onTap: () {
              ref.read(notificationsProvider.notifier).markRead(notification.id);
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedPackage,
                      size: AppDimensions.iconMedium,
                      color: isUnread ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: AppDimensions.marginSmall),
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.body,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(context, notification.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return context.l10n.notifications_justNow;
    if (diff.inMinutes < 60) return context.l10n.notifications_minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return context.l10n.notifications_hoursAgo(diff.inHours);
    return context.l10n.notifications_daysAgo(diff.inDays);
  }
}
