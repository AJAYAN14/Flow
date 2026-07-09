import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/sync.dart";
import "package:flow/widgets/export/export_history/backup_entry_card.dart";
import "package:flow/widgets/general/empty_state.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:path/path.dart" as path;

class ExportHistoryPage extends StatefulWidget {
  const ExportHistoryPage({super.key});

  @override
  State<ExportHistoryPage> createState() => _ExportHistoryPageState();
}

class _ExportHistoryPageState extends State<ExportHistoryPage> {
  bool uploadBusy = false;
  late final bool uploadEnabled;

  // Query for today's transaction, newest to oldest
  QueryBuilder<BackupEntry> qb() => ObjectBox()
      .box<BackupEntry>()
      .query()
      .order(BackupEntry_.createdDate, flags: Order.descending);

  @override
  void initState() {
    super.initState();
    uploadEnabled = false; // iCloud sync removed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.export.history".t(context))),
      body: SafeArea(
        child: StreamBuilder<List<BackupEntry>>(
          stream: qb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            final List<BackupEntry>? backupEntries = snapshot.data;

            const Widget separator = SizedBox(height: 16.0);

            return switch ((backupEntries?.length ?? 0, snapshot.hasData)) {
              (0, true) => EmptyState(
                icon: FlowIconData.icon(Symbols.history_rounded),
                title: Text("sync.export.history.empty".t(context)),
                subtitle: Text(
                  "sync.export.history.empty.description".t(context),
                ),
              ),
              (_, true) => Column(
                children: [
                  Expanded(
                    child: SlidableAutoCloseBehavior(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          final BackupEntry entry = backupEntries![index];

                          return BackupEntryCard(
                            entry: entry,
                            dismissibleKey: ValueKey(entry.id),
                            onUpload: null,
                            uploadProgress: null,
                          );
                        },
                        separatorBuilder: (context, index) => separator,
                        itemCount: backupEntries!.length,
                      ),
                    ),
                  ),
                ],
              ),
              (_, false) => const Spinner.center(),
            };
          },
        ),
      ),
    );
  }


}
