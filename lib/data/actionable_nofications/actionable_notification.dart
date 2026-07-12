import "package:flow/data/flow_icon.dart";
import "package:flow/entity/backup_entry.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:simple_icons_flow/simple_icons_flow.dart";

enum ActionableNotificationPriority {
  low(0),
  medium(10),
  high(20),
  critical(30);

  final int value;

  const ActionableNotificationPriority(this.value);
}

abstract class ActionableNotification<T> {
  FlowIconData get icon;

  T get payload;

  /// Higher priority notifications will be shown first
  ActionableNotificationPriority get priority;
}




class AutoBackupReminder extends ActionableNotification<BackupEntry?> {
  @override
  final FlowIconData icon = const IconFlowIcon(Symbols.cloud_upload);

  @override
  final BackupEntry? payload;

  @override
  final ActionableNotificationPriority priority =
      ActionableNotificationPriority.high;

  AutoBackupReminder({required this.payload});
}
