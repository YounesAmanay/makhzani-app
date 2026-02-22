import 'package:hive/hive.dart';

import '../../domain/entities/app_notification.dart';

/// Hive TypeAdapter written manually (no hive_generator needed).
/// typeId=1 — must be unique across all registered adapters in the app.
class AppNotificationAdapter extends TypeAdapter<AppNotificationHiveModel> {
  @override
  final int typeId = 1;

  @override
  AppNotificationHiveModel read(BinaryReader reader) {
    return AppNotificationHiveModel(
      id: reader.readString(),
      title: reader.readString(),
      body: reader.readString(),
      data: Map<String, String>.from(reader.readMap()),
      isRead: reader.readBool(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, AppNotificationHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.body);
    writer.writeMap(obj.data);
    writer.writeBool(obj.isRead);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

class AppNotificationHiveModel {
  final String id;
  final String title;
  final String body;
  final Map<String, String> data;
  bool isRead;
  final DateTime createdAt;

  AppNotificationHiveModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationHiveModel.fromEntity(AppNotification n) {
    return AppNotificationHiveModel(
      id: n.id,
      title: n.title,
      body: n.body,
      data: Map<String, String>.from(n.data),
      isRead: n.isRead,
      createdAt: n.createdAt,
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      data: Map<String, String>.from(data),
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}
