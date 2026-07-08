import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/schdeuled_notification_permission_builder.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:permission_handler/permission_handler.dart";

final Logger _log = Logger("SchdeuledNotificationPermissionMissingReminder");

class SchdeuledNotificationPermissionMissingReminder extends StatefulWidget {
  final SchdeuledNotificationPermission permissions;

  const SchdeuledNotificationPermissionMissingReminder({
    super.key,
    required this.permissions,
  });

  @override
  State<SchdeuledNotificationPermissionMissingReminder> createState() =>
      _SchdeuledNotificationPermissionMissingReminderState();
}

class _SchdeuledNotificationPermissionMissingReminderState
    extends State<SchdeuledNotificationPermissionMissingReminder> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    if (!widget.permissions.hasNotificationPermission) {
      children.add(
        _buildWarningBanner(
          context: context,
          icon: Symbols.warning_rounded,
          text: "notifications.permissionNotGranted".t(context),
        ),
      );
      children.add(const SizedBox(height: 12.0));
    }

    if (!widget.permissions.hasAlarmPermission) {
      children.add(
        _buildWarningBanner(
          context: context,
          icon: Symbols.alarm_off_rounded,
          text: "notifications.alarm.permissionNotGranted".t(context),
        ),
      );
      children.add(const SizedBox(height: 12.0));
      
      if (Platform.isAndroid) {
        children.add(
          Frame(
            child: InfoText(
              child: Text("notifications.alarm.androidDescription".t(context)),
            ),
          ),
        );
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildWarningBanner({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        color: context.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: openNotificationsSettings,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  fill: 0,
                  color: context.colorScheme.onErrorContainer,
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: DefaultTextStyle(
                    style: context.textTheme.bodyMedium!
                        .semi(context)
                        .copyWith(color: context.colorScheme.onErrorContainer),
                    child: Text(text),
                  ),
                ),
                const SizedBox(width: 12.0),
                busy
                    ? const SizedBox(width: 24.0, height: 24.0, child: Spinner())
                    : Icon(
                        Symbols.open_in_new_rounded,
                        fill: 0,
                        size: 24.0,
                        color: context.colorScheme.onErrorContainer,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openNotificationsSettings() async {
    try {
      await openAppSettings();
    } catch (error) {
      _log.warning("Failed to open app settings: $error", error);
    }
  }
}
