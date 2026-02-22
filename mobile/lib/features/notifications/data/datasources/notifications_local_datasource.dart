import 'package:hive/hive.dart';

import '../../domain/entities/app_notification.dart';
import '../models/app_notification_hive_model.dart';

const _boxName = 'notifications';
// Keep at most 100 notifications to prevent unbounded growth
const _maxNotifications = 100;

class NotificationsLocalDatasource {
  Box<AppNotificationHiveModel> get _box =>
      Hive.box<AppNotificationHiveModel>(_boxName);

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<AppNotificationHiveModel>(_boxName);
    }
  }

  /// Save a new notification. Trims oldest entries if over limit.
  Future<void> save(AppNotification notification) async {
    final model = AppNotificationHiveModel.fromEntity(notification);
    await _box.put(notification.id, model);

    // Trim if over limit — remove oldest (first inserted keys)
    if (_box.length > _maxNotifications) {
      final oldestKey = _box.keys.first;
      await _box.delete(oldestKey);
    }
  }

  /// All notifications, newest first.
  List<AppNotification> getAll() {
    return _box.values
        .map((m) => m.toEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Unread count.
  int get unreadCount =>
      _box.values.where((m) => !m.isRead).length;

  /// Mark a single notification as read.
  Future<void> markRead(String id) async {
    final model = _box.get(id);
    if (model != null && !model.isRead) {
      model.isRead = true;
      await _box.put(id, model);
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllRead() async {
    for (final entry in _box.toMap().entries) {
      if (!entry.value.isRead) {
        entry.value.isRead = true;
        await _box.put(entry.key, entry.value);
      }
    }
  }

  /// Delete a single notification.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all notifications.
  Future<void> clearAll() async {
    await _box.clear();
  }
}

/// Singleton instance — safe to use across services and providers.
final notificationsLocalDatasource = NotificationsLocalDatasource();
