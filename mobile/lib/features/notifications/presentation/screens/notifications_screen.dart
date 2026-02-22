import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notifications_title),
        actions: [
          if (state.notifications.isNotEmpty) ...[
            if (state.unreadCount > 0)
              TextButton(
                onPressed: () =>
                    ref.read(notificationsProvider.notifier).markAllRead(),
                child: Text(
                  context.l10n.notifications_markAllRead,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                size: AppDimensions.iconMedium,
                color: AppColors.error,
              ),
              tooltip: context.l10n.notifications_clearAll,
              onPressed: () => _confirmClearAll(context, ref),
            ),
          ],
        ],
      ),
      body: state.notifications.isEmpty
          ? AppEmptyState(
              icon: HugeIcons.strokeRoundedNotification02,
              title: context.l10n.notifications_empty,
              description: context.l10n.notifications_emptyDescription,
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: AppDimensions.paddingSmall,
                bottom: AppDimensions.paddingLarge,
              ),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => _handleTap(context, notification.data),
                );
              },
            ),
    );
  }

  void _handleTap(BuildContext context, Map<String, String> data) {
    final screen = data['screen'];
    final productId = data['product_id'];

    if (screen == 'product_detail' && productId != null) {
      Navigator.of(context).pushNamed('/products/detail', arguments: productId);
    }
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.notifications_clearConfirmTitle,
      message: context.l10n.notifications_clearConfirmMessage,
      isDestructive: true,
    );
    if (confirmed == true) {
      ref.read(notificationsProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.notifications_cleared)),
        );
      }
    }
  }
}
