// import "package:flow/constants.dart";
import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/premium_list_tile.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class SyncPreferencesPage extends StatefulWidget {
  const SyncPreferencesPage({super.key});

  @override
  State<SyncPreferencesPage> createState() => _SyncPreferencesPageState();
}

class _SyncPreferencesPageState extends State<SyncPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final int? autobackupIntervalInHours =
        UserPreferencesService().autoBackupIntervalInHours;
        
    final int? autoBackupRetentionDays = 
        UserPreferencesService().autoBackupRetentionDays;

    final List<int?> options = [null, 12, 24, 48, 72, 168, 336, 720];
    final List<int?> retentionOptions = [null, 7, 30, 90, 180, 365];

    if (autobackupIntervalInHours != null &&
        !options.contains(autobackupIntervalInHours)) {
      options.add(autobackupIntervalInHours);
    }
    
    if (autoBackupRetentionDays != null && 
        !retentionOptions.contains(autoBackupRetentionDays)) {
      retentionOptions.add(autoBackupRetentionDays);
    }

    return Scaffold(
      appBar: AppBar(title: Text("preferences.sync".t(context))),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              PremiumListGroup(
                children: [
                  PremiumListTile(
                    title: Text("preferences.sync.autoBackup.interval".t(context)),
                    subtitle: Text(
                      autobackupIntervalInHours == null
                          ? "preferences.sync.autoBackup.disabled".t(context)
                          : Duration(hours: autobackupIntervalInHours).toDurationString(
                              dropPrefixOrSuffix: true,
                              format: autobackupIntervalInHours >= 24
                                  ? DurationFormat.dh
                                  : DurationFormat.hm,
                            ),
                    ),
                    leading: Symbols.schedule_rounded,
                    accent: Theme.of(context).colorScheme.primary,
                    onTap: () => _showPicker(
                      context: context,
                      title: "preferences.sync.autoBackup.interval".t(context),
                      options: options,
                      currentValue: autobackupIntervalInHours,
                      onSelected: updateAutoBackupIntervalInHours,
                      labelBuilder: (value) => value == null
                          ? "preferences.sync.autoBackup.disabled".t(context)
                          : Duration(hours: value).toDurationString(
                              dropPrefixOrSuffix: true,
                              format: value >= 24
                                  ? DurationFormat.dh
                                  : DurationFormat.hm,
                            ),
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
                  PremiumListTile(
                    title: Text("preferences.sync.autoBackup.retention".t(context)),
                    subtitle: Text(
                      autoBackupRetentionDays == null
                          ? "preferences.sync.autoBackup.retention.keepForever".t(context)
                          : "preferences.sync.autoBackup.retention.days".t(context, {"days": autoBackupRetentionDays}),
                    ),
                    leading: Symbols.history_rounded,
                    accent: Theme.of(context).colorScheme.primary,
                    onTap: () => _showPicker(
                      context: context,
                      title: "preferences.sync.autoBackup.retention".t(context),
                      options: retentionOptions,
                      currentValue: autoBackupRetentionDays,
                      onSelected: updateAutoBackupRetentionDays,
                      labelBuilder: (value) => value == null
                          ? "preferences.sync.autoBackup.retention.keepForever".t(context)
                          : "preferences.sync.autoBackup.retention.days".t(context, {"days": value}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Frame.standalone(
                child: InfoText(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("preferences.sync.autoBackup.interval.description".t(context)),
                      const SizedBox(height: 12.0),
                      Text("preferences.sync.autoBackup.retention.description".t(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker({
    required BuildContext context,
    required String title,
    required List<int?> options,
    required int? currentValue,
    required ValueChanged<int?> onSelected,
    required String Function(int?) labelBuilder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ModalSheet.scrollable(
          title: Text(title),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = option == currentValue;
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  onSelected(option);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          labelBuilder(option),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              );
            }).toList(),
            ),
          ),
        );
      },
    );
  }

  void updateAutoBackupIntervalInHours(int? newIntervalInHours) async {
    UserPreferencesService().autoBackupIntervalInHours = newIntervalInHours;
    if (mounted) setState(() {});
  }
  
  void updateAutoBackupRetentionDays(int? newRetentionDays) async {
    UserPreferencesService().autoBackupRetentionDays = newRetentionDays;
    if (mounted) setState(() {});
  }
}
