import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notifications_local_datasource.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsLocalDatasource _datasource;

  NotificationsNotifier(this._datasource) : super(const NotificationsState()) {
    _load();
  }

  void _load() {
    final all = _datasource.getAll();
    state = NotificationsState(
      notifications: all,
      unreadCount: _datasource.unreadCount,
    );
  }

  /// Called by NotificationService when a new message arrives.
  Future<void> onNewNotification(AppNotification notification) async {
    await _datasource.save(notification);
    _load();
  }

  Future<void> markRead(String id) async {
    await _datasource.markRead(id);
    _load();
  }

  Future<void> markAllRead() async {
    await _datasource.markAllRead();
    _load();
  }

  Future<void> delete(String id) async {
    await _datasource.delete(id);
    _load();
  }

  Future<void> clearAll() async {
    await _datasource.clearAll();
    _load();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(notificationsLocalDatasource);
});

/// Convenience provider for just the unread count — used by the bell badge.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});
